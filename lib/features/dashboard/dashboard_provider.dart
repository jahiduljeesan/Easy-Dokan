import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories_impl/product_repository_impl.dart';
import '../../data/repositories_impl/sale_repository_impl.dart';
import '../../data/repositories_impl/customer_repository_impl.dart';

class DashboardStats {
  final double todaySales;
  final double weekSales;
  final double monthSales;
  final double totalProfit;
  final double totalDebt;
  final int totalCustomers;
  final int totalProducts;
  final int lowStockCount;
  
  // Analytics
  final Map<String, double> categorySales;
  final List<MapEntry<String, double>> topProducts;
  final List<MapEntry<String, double>> topCustomers;
  
  // Chart Data
  final List<double> weeklySalesData;
  final List<double> monthlySalesData;

  DashboardStats({
    this.todaySales = 0.0,
    this.weekSales = 0.0,
    this.monthSales = 0.0,
    this.totalProfit = 0.0,
    this.totalDebt = 0.0,
    this.totalCustomers = 0,
    this.totalProducts = 0,
    this.lowStockCount = 0,
    this.categorySales = const {},
    this.topProducts = const [],
    this.topCustomers = const [],
    this.weeklySalesData = const [],
    this.monthlySalesData = const [],
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final products = ref.watch(productRepositoryProvider).getAllProducts();
  final sales = ref.watch(saleRepositoryProvider).getAllSales();
  final customers = ref.watch(customerRepositoryProvider).getAllCustomers();
  
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekStart = now.subtract(const Duration(days: 7));
  final monthStart = DateTime(now.year, now.month, 1);

  double todaySales = 0.0;
  double weekSales = 0.0;
  double monthSales = 0.0;
  double totalProfit = 0.0;
  
  Map<String, double> catSales = {};
  Map<String, double> prodCounts = {};
  Map<String, double> custSpending = {};
  
  List<double> weekData = List.filled(7, 0.0);
  List<double> monthData = List.filled(30, 0.0);

  for (var sale in sales) {
    totalProfit += sale.profit;
    
    // Time periods
    if (sale.date.isAfter(todayStart)) {
      todaySales += sale.total;
    }
    if (sale.date.isAfter(weekStart)) {
      weekSales += sale.total;
      int dayIdx = 6 - now.difference(sale.date).inDays;
      if (dayIdx >= 0 && dayIdx < 7) weekData[dayIdx] += sale.total;
    }
    if (sale.date.isAfter(monthStart)) {
      monthSales += sale.total;
    }
    
    // Chart data (Monthly - last 30 days)
    int monthDayIdx = 29 - now.difference(sale.date).inDays;
    if (monthDayIdx >= 0 && monthDayIdx < 30) monthData[monthDayIdx] += sale.total;

    // Category and Product analytics
    for (var item in sale.items) {
      // Find category for this product
      final product = products.where((p) => p.uid == item.productId).firstOrNull;
      final category = product?.category ?? 'Uncategorized';
      catSales[category] = (catSales[category] ?? 0) + item.total;
      prodCounts[item.productName] = (prodCounts[item.productName] ?? 0) + item.quantity.toDouble();
    }
    
    // Customer analytics
    if (sale.customerId != null) {
      final customer = customers.where((c) => c.id == sale.customerId).firstOrNull;
      if (customer != null) {
        custSpending[customer.name] = (custSpending[customer.name] ?? 0) + sale.total;
      }
    }
  }

  // Calculate Total Debt directly from customers
  double totalDebt = customers.fold(0.0, (sum, c) => sum + c.dueAmount);

  // Sort analytics
  final topProds = prodCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topCusts = custSpending.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return DashboardStats(
    todaySales: todaySales,
    weekSales: weekSales,
    monthSales: monthSales,
    totalProfit: totalProfit,
    totalDebt: totalDebt,
    totalCustomers: customers.length,
    totalProducts: products.length,
    lowStockCount: products.where((p) => p.quantity <= 5).length,
    categorySales: catSales,
    topProducts: topProds.take(5).toList(),
    topCustomers: topCusts.take(5).toList(),
    weeklySalesData: weekData,
    monthlySalesData: monthData,
  );
});
