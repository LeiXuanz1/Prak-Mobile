// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_in_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockInTransactionAdapter extends TypeAdapter<StockInTransaction> {
  @override
  final int typeId = 2;

  @override
  StockInTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockInTransaction(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      quantity: fields[3] as int,
      date: fields[4] as DateTime,
      stockBefore: fields[5] as int,
      stockAfter: fields[6] as int,
      category: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StockInTransaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.stockBefore)
      ..writeByte(6)
      ..write(obj.stockAfter)
      ..writeByte(7)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockInTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
