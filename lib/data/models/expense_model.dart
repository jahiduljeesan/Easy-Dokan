import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 5)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String? note;

  @HiveField(4)
  DateTime date;

  ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    this.note,
    required this.date,
  });
}
