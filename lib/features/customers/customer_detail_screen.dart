import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/debt_model.dart';
import '../pos/sales_provider.dart';
import 'customers_provider.dart';
import 'debt_provider.dart';
import '../../core/services/pdf_service.dart';
import '../settings/settings_provider.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final CustomerModel customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showTransactionDialog(bool isPayment) {
    _amountController.clear();
    _noteController.clear();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isPayment ? 'Receive Payment' : 'Add Manual Debt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '৳ ',
                border: const OutlineInputBorder(),
                fillColor: isPayment ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(_amountController.text) ?? 0.0;
              if (amount > 0) {
                // 1. Create Debt Entry
                final debt = DebtModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  customerId: widget.customer.id,
                  amount: amount,
                  date: DateTime.now(),
                  type: isPayment ? 'RECEIVED' : 'GIVEN',
                  note: _noteController.text.isEmpty ? null : _noteController.text,
                );
                await ref.read(debtProvider.notifier).addDebt(debt);

                // 2. Update Customer Balance
                final currentCustomer = ref.read(customersProvider).firstWhere((c) => c.id == widget.customer.id);
                final newDue = isPayment 
                    ? (currentCustomer.dueAmount - amount).clamp(0.0, double.infinity)
                    : currentCustomer.dueAmount + amount;

                final updatedCustomer = CustomerModel(
                  id: currentCustomer.id,
                  name: currentCustomer.name,
                  phone: currentCustomer.phone,
                  address: currentCustomer.address,
                  dueAmount: newDue,
                  createdDate: currentCustomer.createdDate,
                );
                await ref.read(customersProvider.notifier).updateCustomer(updatedCustomer);

                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isPayment ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isPayment ? 'Receive' : 'Add Debt'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sales = ref.watch(salesProvider);
    final customerSales = sales.where((s) => s.customerId == widget.customer.id).toList();
    customerSales.sort((a, b) => b.date.compareTo(a.date));

    final debts = ref.watch(debtProvider);
    final customerDebts = debts.where((d) => d.customerId == widget.customer.id).toList();
    customerDebts.sort((a, b) => b.date.compareTo(a.date));

    final currentCustomer = ref.watch(customersProvider).firstWhere(
      (c) => c.id == widget.customer.id,
      orElse: () => widget.customer,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentCustomer.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Statement',
              onPressed: () => PdfService.generateCustomerStatement(currentCustomer, customerSales),
            ),
            IconButton(
              icon: const Icon(Icons.sms),
              tooltip: 'SMS Reminder',
              onPressed: () async {
                final settings = ref.read(settingsNotifierProvider);
                final buffer = StringBuffer();
                buffer.writeln('${settings.shopName}');
                if (settings.address != null && settings.address!.isNotEmpty) {
                  buffer.writeln('Address: ${settings.address}');
                }
                if (settings.phone != null && settings.phone!.isNotEmpty) {
                  buffer.writeln('Phone: ${settings.phone}');
                }
                buffer.writeln('---');
                buffer.writeln('Hello ${currentCustomer.name},');
                buffer.writeln('Your outstanding balance is ৳${currentCustomer.dueAmount.toStringAsFixed(2)}.');
                buffer.writeln('Please clear it soon. Thank you!');
                buffer.writeln('---');
                buffer.writeln('Receipt was generated by Easy Dokan Software');

                final msg = buffer.toString();
                final uri = Uri.parse('sms:${currentCustomer.phone}?body=${Uri.encodeComponent(msg)}');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Purchases', icon: Icon(Icons.shopping_bag)),
              Tab(text: 'Transactions', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildCustomerInfo(currentCustomer),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPurchaseList(customerSales),
                  _buildTransactionList(customerDebts),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showTransactionDialog(false),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('ADD DEBT'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: currentCustomer.dueAmount > 0 ? () => _showTransactionDialog(true) : null,
                    icon: const Icon(Icons.payment),
                    label: const Text('RECEIVE'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerListTile(SaleModel sale) {
    return ListTile(
      title: Text('Invoice: ${sale.id}'),
      subtitle: Text(sale.date.toString().substring(0, 16)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('৳${sale.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          if (sale.dueAmount > 0)
            Text('Due: ৳${sale.dueAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontSize: 10)),
        ],
      ),
      onTap: () {
        final settings = ref.read(settingsNotifierProvider);
        final currentCustomer = ref.read(customersProvider).firstWhere(
          (c) => c.id == widget.customer.id,
          orElse: () => widget.customer,
        );
        PdfService.generateAndPrintInvoice(sale, settings, customer: currentCustomer);
      },
    );
  }

  Widget _buildPurchaseList(List<SaleModel> sales) {
    if (sales.isEmpty) return const Center(child: Text('No purchases yet'));
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sales.length,
      separatorBuilder: (ctx, i) => const Divider(height: 1),
      itemBuilder: (ctx, i) => _buildCustomerListTile(sales[i]),
    );
  }

  Widget _buildTransactionList(List<DebtModel> debts) {
    if (debts.isEmpty) return const Center(child: Text('No manual transactions'));
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: debts.length,
      separatorBuilder: (ctx, i) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final d = debts[i];
        final isReceived = d.type == 'RECEIVED';
        return ListTile(
          leading: Icon(
            isReceived ? Icons.arrow_downward : Icons.arrow_upward,
            color: isReceived ? Colors.green : Colors.red,
          ),
          title: Text(isReceived ? 'Payment Received' : 'Debt Added'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.date.toString().substring(0, 16)),
              if (d.note != null)
                Text('Note: ${d.note}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
            ],
          ),
          trailing: Text(
            '${isReceived ? "-" : "+"}৳${d.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isReceived ? Colors.green : Colors.red,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerInfo(CustomerModel customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(customer.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(customer.phone, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: customer.dueAmount > 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: customer.dueAmount > 0 ? Colors.red : Colors.green),
            ),
            child: Column(
              children: [
                const Text('DUE BALANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Text(
                  '৳${customer.dueAmount.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: customer.dueAmount > 0 ? Colors.red : Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
