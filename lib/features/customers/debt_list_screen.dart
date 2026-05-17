import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'customers_provider.dart';

class DebtListScreen extends ConsumerWidget {
  const DebtListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCustomers = ref.watch(customersProvider);
    final debtCustomers = allCustomers.where((c) => c.dueAmount > 0).toList();
    debtCustomers.sort((a, b) => b.dueAmount.compareTo(a.dueAmount));

    final totalDebt = debtCustomers.fold(0.0, (sum, c) => sum + c.dueAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Management'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.orange.withOpacity(0.1),
            child: Column(
              children: [
                const Text(
                  'TOTAL RECEIVABLE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '৳${totalDebt.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  'from ${debtCustomers.length} customers',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: debtCustomers.isEmpty
                ? const Center(
                    child: Text('No outstanding debts found.'),
                  )
                : ListView.builder(
                    itemCount: debtCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = debtCustomers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(0.2),
                            child: Text(
                              customer.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                          title: Text(
                            customer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(customer.phone),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '৳${customer.dueAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text('Due', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                          onTap: () => context.push('/customers/detail', extra: customer),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
