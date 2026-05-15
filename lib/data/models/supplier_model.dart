import 'package:hive/hive.dart';

part 'supplier_model.g.dart';

@HiveType(typeId: 2)
class SupplierModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String company;

  @HiveField(3)
  String phone;

  @HiveField(4)
  double dueAmount;

  SupplierModel({
    required this.id,
    required this.name,
    required this.company,
    required this.phone,
    this.dueAmount = 0.0,
  });
}
