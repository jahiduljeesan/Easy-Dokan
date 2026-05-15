import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 1)
class CustomerModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String? address;

  @HiveField(4)
  double dueAmount;

  @HiveField(5)
  DateTime createdDate;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.dueAmount = 0.0,
    required this.createdDate,
  });
}
