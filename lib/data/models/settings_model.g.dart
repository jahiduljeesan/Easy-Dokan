// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 7;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      shopName: fields[0] as String,
      currency: fields[1] as String,
      language: fields[2] as String,
      isDarkTheme: fields[3] as bool,
      pinCode: fields[4] as String?,
      address: fields[5] as String?,
      phone: fields[6] as String?,
      isSetupComplete: fields[7] as bool,
      ownerName: fields[8] as String?,
      businessEmail: fields[9] as String?,
      tradeLicense: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.shopName)
      ..writeByte(1)
      ..write(obj.currency)
      ..writeByte(2)
      ..write(obj.language)
      ..writeByte(3)
      ..write(obj.isDarkTheme)
      ..writeByte(4)
      ..write(obj.pinCode)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.isSetupComplete)
      ..writeByte(8)
      ..write(obj.ownerName)
      ..writeByte(9)
      ..write(obj.businessEmail)
      ..writeByte(10)
      ..write(obj.tradeLicense);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
