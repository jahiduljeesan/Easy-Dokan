import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';
import '../models/customer_model.dart';
import '../models/supplier_model.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../models/inventory_log_model.dart';
import '../models/settings_model.dart';
import '../models/debt_model.dart';

class HiveService {
  static Future<void> init() async {
    // Adapters are registered here after generating them
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(CustomerModelAdapter());
    Hive.registerAdapter(SupplierModelAdapter());
    Hive.registerAdapter(SaleModelAdapter());
    Hive.registerAdapter(SaleItemModelAdapter());
    Hive.registerAdapter(ExpenseModelAdapter());
    Hive.registerAdapter(InventoryLogModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
    Hive.registerAdapter(DebtModelAdapter());

    // Open boxes
    await Hive.openBox<ProductModel>('products');
    await Hive.openBox<CustomerModel>('customers');
    await Hive.openBox<SupplierModel>('suppliers');
    await Hive.openBox<SaleModel>('sales');
    await Hive.openBox<ExpenseModel>('expenses');
    await Hive.openBox<InventoryLogModel>('inventory_logs');
    await Hive.openBox<SettingsModel>('settings');
    await Hive.openBox<DebtModel>('debts');
  }
}
