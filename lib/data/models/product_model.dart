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
  num buyingPrice;

  @HiveField(7)
  num sellingPrice;

  @HiveField(8)
  num wholesalePrice;

  @HiveField(9)
  num quantity;

  @HiveField(10)
  String? unitType;

  @HiveField(11)
  num? discount;

  @HiveField(12)
  num? vat;

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

  @HiveField(18)
  Map<String, List<String>>? attributes;

  @HiveField(19)
  bool? isMeasurable;

  @HiveField(20)
  String? unit;

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
    this.attributes,
    this.isMeasurable = false,
    this.unit,
  });
}
