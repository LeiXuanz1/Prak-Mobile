// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_out_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockOutTransactionAdapter extends TypeAdapter<StockOutTransaction> {
  @override
  final int typeId = 3;

  @override
  StockOutTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockOutTransaction(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      quantity: fields[3] as int,
      sellPrice: fields[4] as double,
      buyPrice: fields[5] as double,
      omset: fields[6] as double,
      profit: fields[7] as double,
      date: fields[8] as DateTime,
      stockBefore: fields[9] as int,
      stockAfter: fields[10] as int,
      category: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StockOutTransaction obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.sellPrice)
      ..writeByte(5)
      ..write(obj.buyPrice)
      ..writeByte(6)
      ..write(obj.omset)
      ..writeByte(7)
      ..write(obj.profit)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.stockBefore)
      ..writeByte(10)
      ..write(obj.stockAfter)
      ..writeByte(11)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockOutTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
