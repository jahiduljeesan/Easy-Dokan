// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleModelAdapter extends TypeAdapter<SaleModel> {
  @override
  final int typeId = 3;

  @override
  SaleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleModel(
      id: fields[0] as String,
      items: (fields[1] as List).cast<SaleItemModel>(),
      subtotal: fields[2] as num,
      discount: fields[3] as num,
      vat: fields[4] as num,
      total: fields[5] as num,
      paidAmount: fields[6] as num,
      dueAmount: fields[7] as num,
      profit: fields[8] as num,
      paymentMethod: fields[9] as String,
      date: fields[10] as DateTime,
      customerId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SaleModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.subtotal)
      ..writeByte(3)
      ..write(obj.discount)
      ..writeByte(4)
      ..write(obj.vat)
      ..writeByte(5)
      ..write(obj.total)
      ..writeByte(6)
      ..write(obj.paidAmount)
      ..writeByte(7)
      ..write(obj.dueAmount)
      ..writeByte(8)
      ..write(obj.profit)
      ..writeByte(9)
      ..write(obj.paymentMethod)
      ..writeByte(10)
      ..write(obj.date)
      ..writeByte(11)
      ..write(obj.customerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SaleItemModelAdapter extends TypeAdapter<SaleItemModel> {
  @override
  final int typeId = 4;

  @override
  SaleItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItemModel(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as num,
      unitPrice: fields[3] as num,
      total: fields[4] as num,
      buyingPrice: fields[5] as num,
      selectedAttributes: (fields[6] as Map?)?.cast<String, String>(),
      category: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SaleItemModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.total)
      ..writeByte(5)
      ..write(obj.buyingPrice)
      ..writeByte(6)
      ..write(obj.selectedAttributes)
      ..writeByte(7)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
