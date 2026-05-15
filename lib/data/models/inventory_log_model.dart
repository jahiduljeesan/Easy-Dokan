import 'package:hive/hive.dart';

part 'inventory_log_model.g.dart';

@HiveType(typeId: 6)
class InventoryLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String productId;

  @HiveField(2)
  String type; // 'ADD', 'REMOVE', 'DAMAGE'

  @HiveField(3)
  int quantity;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? note;

  InventoryLogModel({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.date,
    this.note,
  });
}
