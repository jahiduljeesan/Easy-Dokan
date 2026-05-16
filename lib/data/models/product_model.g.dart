// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 0;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      uid: fields[0] as String,
      barcodeId: fields[1] as String?,
      name: fields[2] as String,
      banglaName: fields[3] as String?,
      category: fields[4] as String?,
      brand: fields[5] as String?,
      buyingPrice: fields[6] as num,
      sellingPrice: fields[7] as num,
      wholesalePrice: fields[8] as num,
      quantity: fields[9] as num,
      unitType: fields[10] as String?,
      discount: fields[11] as num?,
      vat: fields[12] as num?,
      supplierId: fields[13] as String?,
      imagePath: fields[14] as String?,
      expiryDate: fields[15] as DateTime?,
      createdDate: fields[16] as DateTime,
      updatedDate: fields[17] as DateTime,
      attributes: (fields[18] as Map?)?.map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<String>())),
      isMeasurable: fields[19] as bool?,
      unit: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.barcodeId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.banglaName)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.brand)
      ..writeByte(6)
      ..write(obj.buyingPrice)
      ..writeByte(7)
      ..write(obj.sellingPrice)
      ..writeByte(8)
      ..write(obj.wholesalePrice)
      ..writeByte(9)
      ..write(obj.quantity)
      ..writeByte(10)
      ..write(obj.unitType)
      ..writeByte(11)
      ..write(obj.discount)
      ..writeByte(12)
      ..write(obj.vat)
      ..writeByte(13)
      ..write(obj.supplierId)
      ..writeByte(14)
      ..write(obj.imagePath)
      ..writeByte(15)
      ..write(obj.expiryDate)
      ..writeByte(16)
      ..write(obj.createdDate)
      ..writeByte(17)
      ..write(obj.updatedDate)
      ..writeByte(18)
      ..write(obj.attributes)
      ..writeByte(19)
      ..write(obj.isMeasurable)
      ..writeByte(20)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
