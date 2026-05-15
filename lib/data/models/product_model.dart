import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String? barcodeId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String? banglaName;

  @HiveField(4)
  String? category;

  @HiveField(5)
  String? brand;

  @HiveField(6)
  double buyingPrice;

  @HiveField(7)
  double sellingPrice;

  @HiveField(8)
  double wholesalePrice;

  @HiveField(9)
  int quantity;

  @HiveField(10)
  String? unitType;

  @HiveField(11)
  double? discount;

  @HiveField(12)
  double? vat;

  @HiveField(13)
  String? supplierId;

  @HiveField(14)
  String? imagePath;

  @HiveField(15)
  DateTime? expiryDate;

  @HiveField(16)
  DateTime createdDate;

  @HiveField(17)
  DateTime updatedDate;

  ProductModel({
    required this.uid,
    this.barcodeId,
    required this.name,
    this.banglaName,
    this.category,
    this.brand,
    required this.buyingPrice,
    required this.sellingPrice,
    this.wholesalePrice = 0.0,
    required this.quantity,
    this.unitType,
    this.discount,
    this.vat,
    this.supplierId,
    this.imagePath,
    this.expiryDate,
    required this.createdDate,
    required this.updatedDate,
  });
}
