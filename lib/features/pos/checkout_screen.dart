import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cart_provider.dart';
import '../products/products_provider.dart';
import '../../data/models/product_model.dart';
import '../../data/models/sale_model.dart';
import '../../data/repositories_impl/sale_repository_impl.dart';
import '../../core/services/pdf_service.dart';
import '../customers/customers_provider.dart';
import '../../data/models/customer_model.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _paidController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _discountPercentController = TextEditingController();
  final _discountFixedController = TextEditingController();

  CustomerModel? _selectedCustomer;
  bool _isNewCustomer = false;

  @override
  void initState() {
    super.initState();
    final cart = ref.read(cartProvider);
    _paidController.text = cart.total.toStringAsFixed(2);
    _discountPercentController.text = cart.discountPercentage.toString();
    _discountFixedController.text = cart.discountFixed.toString();
  }

  @override
  void dispose() {
    _paidController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _discountPercentController.dispose();
    _discountFixedController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String phone) {
    if (phone.length >= 11) {
      final customers = ref.read(customersProvider);
      final match = customers.where((c) => c.phone == phone).toList();
      if (match.isNotEmpty) {
        setState(() {
          _selectedCustomer = match.first;
          _isNewCustomer = false;
        });
      } else {
        setState(() {
          _selectedCustomer = null;
          _isNewCustomer = true;
        });
      }
    } else {
      setState(() {
        _selectedCustomer = null;
        _isNewCustomer = false;
      });
    }
  }

  Future<void> _completeSale() async {
    final cart = ref.read(cartProvider);
    final paidAmount = double.tryParse(_paidController.text) ?? 0.0;
    final now = DateTime.now();

    // Handle Customer
    String? customerId;
    if (_selectedCustomer != null) {
      customerId = _selectedCustomer!.id;
      // Update existing customer due if needed
      final due = (cart.total - paidAmount).clamp(0.0, double.infinity);
      if (due > 0) {
        final updatedCustomer = CustomerModel(
          id: _selectedCustomer!.id,
          name: _selectedCustomer!.name,
          phone: _selectedCustomer!.phone,
          address: _selectedCustomer!.address,
          dueAmount: _selectedCustomer!.dueAmount + due,
          createdDate: _selectedCustomer!.createdDate,
        );
        await ref
            .read(customersProvider.notifier)
            .updateCustomer(updatedCustomer);
      }
    } else if (_isNewCustomer && _nameController.text.isNotEmpty) {
      final due = (cart.total - paidAmount).clamp(0.0, double.infinity);
      final newCustomer = CustomerModel(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        phone: _phoneController.text,
        dueAmount: due,
        createdDate: now,
      );
      await ref.read(customersProvider.notifier).addCustomer(newCustomer);
      customerId = newCustomer.id;
    }

    // Create Sale
    final saleItems = cart.items
        .map(
          (i) => SaleItemModel(
            productId: i.product.uid,
            productName: i.product.name,
            quantity: i.quantity,
            unitPrice: i.product.sellingPrice,
            total: i.totalPrice,
            buyingPrice: i.product.buyingPrice,
            selectedAttributes: i.selectedAttributes,
            category: i.product.category,
          ),
        )
        .toList();

    final sale = SaleModel(
      id: now.millisecondsSinceEpoch.toString(),
      customerId: customerId,
      items: saleItems,
      subtotal: cart.subtotal,
      discount: cart.totalDiscount,
      vat: cart.vat,
      total: cart.total,
      paidAmount: paidAmount,
      dueAmount: (cart.total - paidAmount).clamp(0.0, double.infinity),
      profit: cart.totalProfit,
      paymentMethod: 'CASH',
      date: now,
    );

    await ref.read(saleRepositoryProvider).addSale(sale);

    // Update Stock
    for (var item in cart.items) {
      final updatedProduct = ProductModel(
        uid: item.product.uid,
        barcodeId: item.product.barcodeId,
        name: item.product.name,
        buyingPrice: item.product.buyingPrice,
        sellingPrice: item.product.sellingPrice,
        quantity: item.product.quantity - item.quantity,
        createdDate: item.product.createdDate,
        updatedDate: now,
        category: item.product.category,
      );
      ref.read(productsProvider.notifier).updateProduct(updatedProduct);
    }

    // Clear Cart and Show Success
    ref.read(cartProvider.notifier).clearCart();

    if (mounted) {
      _showPostSaleDialog(sale);
    }
  }

  void _showPostSaleDialog(SaleModel sale) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Sale Completed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: ৳${sale.total.toStringAsFixed(2)}'),
            Text('Paid: ৳${sale.paidAmount.toStringAsFixed(2)}'),
            if (sale.dueAmount > 0)
              Text(
                'Due: ৳${sale.dueAmount.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            const Text('What would you like to do next?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/pos');
            },
            child: const Text('New Sale'),
          ),
          if (_phoneController.text.isNotEmpty || _selectedCustomer != null)
            ElevatedButton.icon(
              onPressed: () async {
                final phone = _selectedCustomer?.phone ?? _phoneController.text;
                final buffer = StringBuffer();
                buffer.writeln('Easy Dokan - Invoice: ${sale.id}');
                buffer.writeln('Date: ${sale.date.toString().split(' ')[0]}');
                buffer.writeln('---');
                for (var item in sale.items) {
                  buffer.writeln(
                    '${item.productName} x${item.quantity}: ৳${item.total.toStringAsFixed(0)}',
                  );
                }
                buffer.writeln('---');
                buffer.writeln(
                  'Subtotal: ৳${sale.subtotal.toStringAsFixed(0)}',
                );
                if (sale.discount > 0)
                  buffer.writeln(
                    'Discount: ৳${sale.discount.toStringAsFixed(0)}',
                  );
                buffer.writeln('Total: ৳${sale.total.toStringAsFixed(0)}');
                buffer.writeln('Paid: ৳${sale.paidAmount.toStringAsFixed(0)}');
                if (sale.dueAmount > 0)
                  buffer.writeln('Due: ৳${sale.dueAmount.toStringAsFixed(0)}');
                buffer.writeln('Thank you!');

                final msg = buffer.toString();
                final uri = Uri.parse(
                  'sms:$phone?body=${Uri.encodeComponent(msg)}',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              icon: const Icon(Icons.sms),
              label: const Text('SMS'),
            ),
          ElevatedButton.icon(
            onPressed: () => PdfService.generateAndPrintInvoice(sale),
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
        ],
      ),
    );
  }

  void _showCustomerSelectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final allCustomers = ref.watch(customersProvider);
            String searchDialogQuery = '';

            return StatefulBuilder(builder: (context, setLocalState) {
              final filteredCustomers = allCustomers.where((c) {
                final q = searchDialogQuery.toLowerCase();
                return c.name.toLowerCase().contains(q) || c.phone.contains(q);
              }).toList();

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: 500,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Customer',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by name or phone...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          setLocalState(() {
                            searchDialogQuery = val;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredCustomers.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text('No customers found'),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: filteredCustomers.length,
                                separatorBuilder: (c, i) => const Divider(),
                                itemBuilder: (context, index) {
                                  final c = filteredCustomers[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      child: Text(c.name[0].toUpperCase()),
                                    ),
                                    title: Text(c.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(c.phone),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '৳${c.dueAmount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: c.dueAmount > 0
                                                ? Colors.red
                                                : Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Text('Due',
                                            style: TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedCustomer = c;
                                        _phoneController.text = c.phone;
                                        _isNewCustomer = false;
                                      });
                                      Navigator.pop(ctx);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final paidAmount = double.tryParse(_paidController.text) ?? 0.0;
    final saleDue = (cart.total - paidAmount).clamp(0.0, double.infinity);
    final totalDue = (_selectedCustomer?.dueAmount ?? 0.0) + saleDue;
    final returnAmount = (paidAmount - cart.total).clamp(0.0, double.infinity);

    final isWide = MediaQuery.of(context).size.width > 900;

    final summaryPanel = Container(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (isWide)
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '৳${item.product.sellingPrice} x ${item.quantity}',
                        ),
                        if (item.selectedAttributes != null && item.selectedAttributes!.isNotEmpty)
                          Text(
                            item.selectedAttributes!.values.join(', '),
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                      ],
                    ),
                    trailing: Text(
                      '৳${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            )
          else
            ...cart.items.map(
              (item) => ListTile(
                title: Text(item.product.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '৳${item.product.sellingPrice} x ${item.quantity}',
                    ),
                    if (item.selectedAttributes != null && item.selectedAttributes!.isNotEmpty)
                      Text(
                        item.selectedAttributes!.values.join(', '),
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                  ],
                ),
                trailing: Text(
                  '৳${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', cart.subtotal),
                _buildSummaryRow(
                  'Discount',
                  -cart.totalDiscount,
                  color: Colors.red,
                ),
                if (cart.vat > 0) _buildSummaryRow('VAT', cart.vat),
                const Divider(),
                _buildSummaryRow(
                  'Total',
                  cart.total,
                  isBold: true,
                  fontSize: 24,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final paymentPanel = SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onPhoneChanged,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _showCustomerSelectionDialog,
                  icon: const Icon(Icons.person_search),
                  label: const Text('Select'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedCustomer != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected: ${_selectedCustomer!.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Phone: ${_selectedCustomer!.phone}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedCustomer = null;
                        _phoneController.clear();
                        _isNewCustomer = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
          if (_isNewCustomer) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                prefixIcon: Icon(Icons.person_add),
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 32),
          const Text(
            'Discounts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discountPercentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount (%)',
                    prefixIcon: Icon(Icons.percent),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    final oldTotal = ref.read(cartProvider).total;
                    final wasMatching =
                        double.tryParse(_paidController.text) == oldTotal;

                    ref
                        .read(cartProvider.notifier)
                        .setDiscountPercentage(double.tryParse(val) ?? 0.0);

                    if (wasMatching) {
                      _paidController.text = ref
                          .read(cartProvider)
                          .total
                          .toStringAsFixed(2);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _discountFixedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fixed Discount (৳)',
                    prefixIcon: Icon(Icons.money_off),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    final oldTotal = ref.read(cartProvider).total;
                    final wasMatching =
                        double.tryParse(_paidController.text) == oldTotal;

                    ref
                        .read(cartProvider.notifier)
                        .setDiscountFixed(double.tryParse(val) ?? 0.0);

                    if (wasMatching) {
                      _paidController.text = ref
                          .read(cartProvider)
                          .total
                          .toStringAsFixed(2);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Payment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _paidController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              labelText: 'Paid Amount',
              prefixIcon: Icon(Icons.payments, size: 30),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoCard('Return', returnAmount, Colors.green),
              const SizedBox(width: 8),
              _buildInfoCard('Sale Due', saleDue, Colors.orange),
              const SizedBox(width: 8),
              _buildInfoCard('Total Due', totalDue, Colors.red),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: cart.items.isEmpty ? null : _completeSale,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CONFIRM SALE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: isWide
          ? Row(
              children: [
                Expanded(flex: 2, child: summaryPanel),
                Expanded(flex: 3, child: paymentPanel),
              ],
            )
          : SingleChildScrollView(
              child: Column(children: [summaryPanel, paymentPanel]),
            ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 16,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '৳${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
