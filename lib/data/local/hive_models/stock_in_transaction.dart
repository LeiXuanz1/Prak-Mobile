import 'package:hive/hive.dart';

part 'stock_in_transaction.g.dart';

@HiveType(typeId: 2)
class StockInTransaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final int stockBefore;

  @HiveField(6)
  final int stockAfter;

  @HiveField(7)
  final String category;

  StockInTransaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.date,
    required this.stockBefore,
    required this.stockAfter,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'date': date,
      'stockBefore': stockBefore,
      'stockAfter': stockAfter,
      'category': category,
    };
  }
}
