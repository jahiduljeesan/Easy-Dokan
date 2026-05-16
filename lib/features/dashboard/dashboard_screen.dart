import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../localization/app_localizations.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedPeriod = 'Weekly';

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard'.tr(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardStatsProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(context, stats),
            const SizedBox(height: 24),
            _buildPeriodSwitcher(),
            const SizedBox(height: 16),
            _buildSalesChart(context, stats),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildCategorySalesChart(context, stats)),
              ],
            ),
            const SizedBox(height: 24),
            _buildTopSection(
              title: 'Top Selling Products',
              icon: Icons.star,
              color: Colors.amber,
              items: stats.topProducts.map((e) => _TopItem(e.key, '${e.value} sold')).toList(),
            ),
            const SizedBox(height: 24),
            _buildTopSection(
              title: 'Top Customers',
              icon: Icons.person,
              color: Colors.blue,
              items: stats.topCustomers.map((e) => _TopItem(e.key, '৳${e.value.toStringAsFixed(0)} spent')).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Daily', 'Weekly', 'Monthly'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, DashboardStats stats) {
    double currentSales = stats.todaySales;
    if (_selectedPeriod == 'Weekly') currentSales = stats.weekSales;
    if (_selectedPeriod == 'Monthly') currentSales = stats.monthSales;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _buildCard(
          context,
          'Sales ($_selectedPeriod)',
          '৳${currentSales.toStringAsFixed(0)}',
          Icons.point_of_sale,
          Colors.blue,
        ),
        _buildCard(
          context,
          'Total Profit',
          '৳${stats.totalProfit.toStringAsFixed(0)}',
          Icons.trending_up,
          Colors.green,
        ),
        _buildCard(
          context,
          'Total Debt',
          '৳${stats.totalDebt.toStringAsFixed(0)}',
          Icons.money_off,
          Colors.orange,
          onTap: () => context.push('/customers/debts'),
        ),
        _buildCard(
          context,
          'Low Stock',
          '${stats.lowStockCount}',
          Icons.warning_amber,
          Colors.red,
          onTap: () => context.push('/products'),
        ),
      ],
    );
  }

  Widget _buildSalesChart(BuildContext context, DashboardStats stats) {
    final data = _selectedPeriod == 'Monthly' ? stats.monthlySalesData : stats.weeklySalesData;
    if (data.isEmpty) return const SizedBox();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sales Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySalesChart(BuildContext context, DashboardStats stats) {
    if (stats.categorySales.isEmpty) return const SizedBox();
    
    final entries = stats.categorySales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sales by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...entries.take(5).map((e) {
              final percent = e.value / stats.categorySales.values.fold(0.0, (a, b) => a + b);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key),
                        Text('৳${e.value.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<_TopItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text('No data available')
        else
          ...items.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Text(item.subtitle, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
              )),
      ],
    );
  }

  Widget _buildCard(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopItem {
  final String title;
  final String subtitle;
  _TopItem(this.title, this.subtitle);
}
