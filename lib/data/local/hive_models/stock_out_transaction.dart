import 'package:hive/hive.dart';

part 'stock_out_transaction.g.dart';

@HiveType(typeId: 3)
class StockOutTransaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final double sellPrice;

  @HiveField(5)
  final double buyPrice;

  @HiveField(6)
  final double omset;

  @HiveField(7)
  final double profit;

  @HiveField(8)
  final DateTime date;

  @HiveField(9)
  final int stockBefore;

  @HiveField(10)
  final int stockAfter;

  @HiveField(11)
  final String category;

  @HiveField(12)
  final String? contactName;

  StockOutTransaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.sellPrice,
    required this.buyPrice,
    required this.omset,
    required this.profit,
    required this.date,
    required this.stockBefore,
    required this.stockAfter,
    required this.category,
    this.contactName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'sellPrice': sellPrice,
      'buyPrice': buyPrice,
      'omset': omset,
      'profit': profit,
      'date': date,
      'stockBefore': stockBefore,
      'stockAfter': stockAfter,
      'category': category,
      'contactName': contactName,
    };
  }
}
