import '../../data/models/sale_model.dart';

abstract class SaleRepository {
  List<SaleModel> getAllSales();
  Future<void> addSale(SaleModel sale);
}
