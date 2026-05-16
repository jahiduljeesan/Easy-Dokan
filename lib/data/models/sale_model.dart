import 'package:hive/hive.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 3)
class SaleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  List<SaleItemModel> items;

  @HiveField(2)
  num subtotal;

  @HiveField(3)
  num discount;

  @HiveField(4)
  num vat;

  @HiveField(5)
  num total;

  @HiveField(6)
  num paidAmount;

  @HiveField(7)
  num dueAmount;

  @HiveField(8)
  num profit;

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
  num quantity;

  @HiveField(3)
  num unitPrice;

  @HiveField(4)
  num total;

  @HiveField(5)
  num buyingPrice;

  @HiveField(6)
  Map<String, String>? selectedAttributes;

  @HiveField(7)
  String? category;

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.buyingPrice,
    this.selectedAttributes,
    this.category,
  });
}
