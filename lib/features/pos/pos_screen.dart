import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'cart_provider.dart';
import '../products/products_provider.dart';
import '../../data/models/product_model.dart';
import '../../core/widgets/calculator_dialog.dart';
import '../products/barcode_scanner_screen.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  void _handleBarcodeScan(String barcode) {
    final products = ref.read(productsProvider);
    final match = products.cast<ProductModel?>().firstWhere(
          (p) => p?.barcodeId == barcode,
          orElse: () => null,
        );
    if (match != null) {
      _showSelectionDialog(match);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product not found!')));
    }
  }

  void _showSelectionDialog(ProductModel p) {
    if (p.isMeasurable != true && (p.attributes == null || p.attributes!.isEmpty)) {
      ref.read(cartProvider.notifier).addProduct(p);
      return;
    }

    final selectedOptions = <String, String>{};
    if (p.attributes != null) {
      p.attributes!.forEach((key, values) {
        if (values.isNotEmpty) selectedOptions[key] = values.first;
      });
    }

    double measurement = 1.0;
    final measurementController = TextEditingController(text: '1.0');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: Text(p.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (p.isMeasurable == true) ...[
                  TextField(
                    controller: measurementController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Measurement (${p.unit ?? 'qty'})',
                      suffixText: p.unit,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setLocalState(() {
                        measurement = double.tryParse(val) ?? 0.0;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: ৳${(measurement * p.sellingPrice).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const Divider(),
                ],
                if (p.attributes != null)
                  ...p.attributes!.keys.map((key) {
                    final values = p.attributes![key]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text('$key:')),
                          DropdownButton<String>(
                            value: selectedOptions[key],
                            items: values
                                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setLocalState(() => selectedOptions[key] = val);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).addProduct(
                      p,
                      selectedAttributes: selectedOptions.isEmpty ? null : selectedOptions,
                      quantity: measurement,
                    );
                Navigator.pop(context);
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final allProducts = ref.watch(productsProvider);

    final categories = [
      'All',
      ...allProducts
          .map((p) => p.category ?? 'Uncategorized')
          .toSet()
          .where((c) => c.isNotEmpty),
    ];

    final products = allProducts.where((p) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          p.name.toLowerCase().contains(query) ||
          (p.barcodeId != null && p.barcodeId!.contains(query));
      final matchesCategory =
          _selectedCategory == 'All' ||
          (p.category ?? 'Uncategorized') == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final isWideScreen = MediaQuery.of(context).size.width > 600;

    Widget productsGrid = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Products',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final barcode = await showDialog<String>(
                    context: context,
                    builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                        child: SizedBox(
                          width: 400,
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const BarcodeScannerScreen(isPopup: true),
                        ),
                      ),
                    ),
                  );
                  if (barcode != null) _handleBarcodeScan(barcode);
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Quick Scan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final cat = categories.elementAt(index);
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${p.category ?? 'Uncategorized'} | Stock: ${p.quantity % 1 == 0 ? p.quantity.toInt() : p.quantity.toStringAsFixed(2)} ${p.unit ?? ''}',
                  ),
                  trailing: Text(
                    '৳${p.sellingPrice}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => _showSelectionDialog(p),
                ),
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CalculatorDialog(),
              );
            },
          ),
          InkWell(
            onTap: () async {
              final barcode = await context.push<String>('/scanner');
              if (barcode != null) {
                _handleBarcodeScan(barcode);
              }
            },
            onLongPress: () async {
              final barcode = await showDialog<String>(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: SizedBox(
                      width: 400,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const BarcodeScannerScreen(isPopup: true),
                    ),
                  ),
                ),
              );
              if (barcode != null) {
                _handleBarcodeScan(barcode);
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.qr_code_scanner),
            ),
          ),
        ],
      ),
      body: isWideScreen
          ? Row(
              children: [
                Expanded(flex: 3, child: productsGrid),
                const VerticalDivider(width: 1),
                const Expanded(flex: 2, child: CartPanel()),
              ],
            )
          : productsGrid,
      floatingActionButton: isWideScreen
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const FractionallySizedBox(
                    heightFactor: 0.8,
                    child: CartPanel(),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                '${cartState.items.length} items | ৳${cartState.total.toStringAsFixed(2)}',
              ),
            ),
    );
  }
}

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            children: [
              const Icon(Icons.shopping_cart),
              const SizedBox(width: 8),
              Text(
                'Cart (${cartState.items.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (cartState.items.isNotEmpty)
                TextButton.icon(
                  onPressed: () => ref.read(cartProvider.notifier).clearCart(),
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  label:
                      const Text('Clear', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
        Expanded(
          child: cartState.items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Your cart is empty',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: cartState.items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = cartState.items[index];
                    return ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      title: Text(
                        item.product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '৳${item.product.sellingPrice} x ${item.quantity} = ৳${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          if (item.selectedAttributes != null && item.selectedAttributes!.isNotEmpty)
                            Text(
                              item.selectedAttributes!.values.join(', '),
                              style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.orange, size: 20),
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .updateQuantity(
                                    item.product.uid, item.quantity - 1,
                                    selectedAttributes: item.selectedAttributes),
                          ),
                          SizedBox(
                            width: 40,
                            child: InkWell(
                              onTap: () {
                                final controller = TextEditingController(text: item.quantity.toString());
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Update Quantity'),
                                    content: TextField(
                                      controller: controller,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      autofocus: true,
                                      decoration: const InputDecoration(border: OutlineInputBorder()),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () {
                                          final q = double.tryParse(controller.text) ?? item.quantity;
                                          ref.read(cartProvider.notifier).updateQuantity(
                                                item.product.uid,
                                                q,
                                                selectedAttributes: item.selectedAttributes,
                                              );
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Update'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text(
                                item.quantity % 1 == 0
                                    ? item.quantity.toInt().toString()
                                    : item.quantity.toStringAsFixed(2),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.green, size: 20),
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .updateQuantity(
                                    item.product.uid, item.quantity + 1,
                                    selectedAttributes: item.selectedAttributes),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .removeProduct(item.product.uid,
                                    selectedAttributes: item.selectedAttributes),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Disc (%)',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.percent, size: 18),
                      ),
                      onChanged: (val) => ref
                          .read(cartProvider.notifier)
                          .setDiscountPercentage(double.tryParse(val) ?? 0.0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Disc (৳)',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.money_off, size: 18),
                      ),
                      onChanged: (val) => ref
                          .read(cartProvider.notifier)
                          .setDiscountFixed(double.tryParse(val) ?? 0.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSummaryRow(context, 'Subtotal', cartState.subtotal),
              _buildSummaryRow(context, 'Discount', -cartState.totalDiscount,
                  color: Colors.red),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Payable',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '৳${cartState.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: cartState.items.isEmpty
                      ? null
                      : () => context.push('/checkout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text('PROCEED TO CHECKOUT',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double amount,
      {bool isBold = false, double fontSize = 16, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
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
}
