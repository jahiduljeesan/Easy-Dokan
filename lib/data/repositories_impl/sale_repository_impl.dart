import 'package:hive/hive.dart';
import '../../domain/repositories/sale_repository.dart';
import '../models/sale_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepositoryImpl(Hive.box<SaleModel>('sales'));
});

class SaleRepositoryImpl implements SaleRepository {
  final Box<SaleModel> _box;

  SaleRepositoryImpl(this._box);

  @override
  List<SaleModel> getAllSales() {
    return _box.values.toList();
  }

  @override
  Future<void> addSale(SaleModel sale) async {
    await _box.put(sale.id, sale);
  }
}
