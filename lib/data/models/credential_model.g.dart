// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CredentialModelAdapter extends TypeAdapter<CredentialModel> {
  @override
  final int typeId = 9;

  @override
  CredentialModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CredentialModel(
      id: fields[0] as String,
      name: fields[1] as String,
      username: fields[2] as String?,
      secret: fields[3] as String?,
      description: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CredentialModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.secret)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
