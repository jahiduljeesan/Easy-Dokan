import 'package:hive/hive.dart';

part 'debt_model.g.dart';

@HiveType(typeId: 8)
class DebtModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String type; // 'GIVEN', 'RECEIVED'

  @HiveField(5)
  String? note;

  DebtModel({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.date,
    required this.type,
    this.note,
  });
}
