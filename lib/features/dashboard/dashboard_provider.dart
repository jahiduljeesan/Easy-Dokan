import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories_impl/product_repository_impl.dart';
import '../../data/repositories_impl/sale_repository_impl.dart';
import '../../data/repositories_impl/customer_repository_impl.dart';
import '../../data/repositories_impl/debt_repository_impl.dart';

class DashboardStats {
  final double todaySales;
  final double totalProfit;
  final double totalDebt;
  final int totalCustomers;
  final int totalProducts;
  final int lowStockCount;

  DashboardStats({
    this.todaySales = 0.0,
    this.totalProfit = 0.0,
    this.totalDebt = 0.0,
    this.totalCustomers = 0,
    this.totalProducts = 0,
    this.lowStockCount = 0,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final products = ref.watch(productRepositoryProvider).getAllProducts();
  final sales = ref.watch(saleRepositoryProvider).getAllSales();
  final customers = ref.watch(customerRepositoryProvider).getAllCustomers();
  final debts = ref.watch(debtRepositoryProvider).getAllDebts();

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  double todaySales = 0.0;
  double totalProfit = 0.0;
  
  for (var sale in sales) {
    totalProfit += sale.profit;
    if (sale.date.isAfter(todayStart)) {
      todaySales += sale.total;
    }
  }

  double totalDebt = 0.0;
  for (var debt in debts) {
    if (debt.type == 'GIVEN') {
      totalDebt += debt.amount;
    } else {
      totalDebt -= debt.amount;
    }
  }

  int lowStock = products.where((p) => p.quantity <= 5).length;

  return DashboardStats(
    todaySales: todaySales,
    totalProfit: totalProfit,
    totalDebt: totalDebt,
    totalCustomers: customers.length,
    totalProducts: products.length,
    lowStockCount: lowStock,
  );
});
