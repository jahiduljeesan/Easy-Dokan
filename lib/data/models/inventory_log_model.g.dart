// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryLogModelAdapter extends TypeAdapter<InventoryLogModel> {
  @override
  final int typeId = 6;

  @override
  InventoryLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryLogModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      type: fields[2] as String,
      quantity: fields[3] as int,
      date: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryLogModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
