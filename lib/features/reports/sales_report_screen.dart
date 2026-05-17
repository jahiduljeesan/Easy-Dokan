import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pos/sales_provider.dart';
import '../../core/services/pdf_service.dart';
import '../settings/settings_provider.dart';
import '../customers/customers_provider.dart';
import '../../data/models/customer_model.dart';

class SalesReportScreen extends ConsumerStatefulWidget {
  const SalesReportScreen({super.key});

  @override
  ConsumerState<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends ConsumerState<SalesReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String _filterType = 'Weekly';
  String _selectedCategory = 'All';

  void _updateFilter(String type) {
    final now = DateTime.now();
    setState(() {
      _filterType = type;
      if (type == 'Today') {
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
      } else if (type == 'Monthly') {
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
      } else if (type == 'Yearly') {
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
      } else if (type == 'Weekly') {
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
      }
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _filterType = 'Custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSales = ref.watch(salesProvider);
    
    // Filter by date
    var filteredSales = allSales.where((s) {
      return s.date.isAfter(_startDate) &&
          s.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();

    // Filter by category if selected
    if (_selectedCategory != 'All') {
      filteredSales = filteredSales.where((s) {
        return s.items.any((item) => (item.category ?? 'Uncategorized') == _selectedCategory);
      }).toList();
    }

    filteredSales.sort((a, b) => b.date.compareTo(a.date));

    // Stats calculation
    final totalSales = filteredSales.fold(0.0, (sum, s) => sum + s.total);
    final totalProfit = filteredSales.fold(0.0, (sum, s) => sum + s.profit);

    final productQty = <String, double>{};
    final categoryRev = <String, double>{};
    for (var sale in filteredSales) {
      for (var item in sale.items) {
        productQty[item.productName] = (productQty[item.productName] ?? 0) + item.quantity;
        final cat = item.category ?? 'Uncategorized';
        categoryRev[cat] = (categoryRev[cat] ?? 0.0) + item.total;
      }
    }

    String topProduct = 'N/A';
    if (productQty.isNotEmpty) {
      topProduct = productQty.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    String topCategory = 'N/A';
    if (categoryRev.isNotEmpty) {
      topCategory = categoryRev.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    // Get all unique categories for filter
    final categories = ['All', ...categoryRev.keys];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () =>
                PdfService.generateSalesReport(_startDate, _endDate, filteredSales),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(categories),
          _buildSummaryCards(totalSales, totalProfit, filteredSales.length, topProduct, topCategory),
          Expanded(
            child: filteredSales.isEmpty
                ? const Center(child: Text('No sales found for this period'))
                : ListView.separated(
                    itemCount: filteredSales.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final sale = filteredSales[index];
                      return ListTile(
                        title: Text('Invoice: ${sale.id}'),
                        subtitle: Text(sale.date.toString().substring(0, 16)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('৳${sale.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Profit: ৳${sale.profit.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: Colors.green)),
                          ],
                        ),
                        onTap: () {
                          final settings = ref.read(settingsNotifierProvider);
                          final customers = ref.read(customersProvider);
                          CustomerModel? customer;
                          if (sale.customerId != null) {
                            final matches = customers.where((c) => c.id == sale.customerId).toList();
                            if (matches.isNotEmpty) {
                              customer = matches.first;
                            }
                          }
                          PdfService.generateAndPrintInvoice(sale, settings, customer: customer);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(List<String> categories) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Today', 'Weekly', 'Monthly', 'Yearly'].map((type) {
                final isSelected = _filterType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (val) => _updateFilter(type),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    backgroundColor: Colors.blue.withOpacity(0.05),
                    selectedColor: Colors.blue.withOpacity(0.2),
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            label: Text('${_startDate.toString().split(' ')[0]} to ${_endDate.toString().split(' ')[0]}'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double total, double profit, int count, String topProd, String topCat) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard('Total Sales', '৳${total.toStringAsFixed(0)}', Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard('Total Profit', '৳${profit.toStringAsFixed(0)}', Colors.green),
              const SizedBox(width: 12),
              _buildStatCard('Orders', '$count', Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Top Product', topProd, Colors.purple),
              const SizedBox(width: 12),
              _buildStatCard('Top Category', topCat, Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
