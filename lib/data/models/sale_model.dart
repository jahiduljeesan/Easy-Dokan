import 'package:hive/hive.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 3)
class SaleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  List<SaleItemModel> items;

  @HiveField(2)
  double subtotal;

  @HiveField(3)
  double discount;

  @HiveField(4)
  double vat;

  @HiveField(5)
  double total;

  @HiveField(6)
  double paidAmount;

  @HiveField(7)
  double dueAmount;

  @HiveField(8)
  double profit;

  @HiveField(9)
  String paymentMethod;

  @HiveField(10)
  DateTime date;

  @HiveField(11)
  String? customerId;

  SaleModel({
    required this.id,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.vat = 0.0,
    required this.total,
    required this.paidAmount,
    this.dueAmount = 0.0,
    required this.profit,
    required this.paymentMethod,
    required this.date,
    this.customerId,
  });
}

@HiveType(typeId: 4)
class SaleItemModel {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String productName;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double unitPrice;

  @HiveField(4)
  double total;

  @HiveField(5)
  double buyingPrice;

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.buyingPrice,
  });
}
