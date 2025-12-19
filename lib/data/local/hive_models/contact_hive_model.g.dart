// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactHiveModelAdapter extends TypeAdapter<ContactHiveModel> {
  @override
  final int typeId = 4;

  @override
  ContactHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String?,
      email: fields[3] as String?,
      address: fields[4] as String,
      latitude: fields[5] as double?,
      longitude: fields[6] as double?,
      locationLabel: fields[7] as String?,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ContactHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.locationLabel)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
