import 'package:hive/hive.dart';

part 'product_hive_model.g.dart';

@HiveType(typeId: 1)
class ProductHiveModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final int stock;

  @HiveField(4)
  final String unit;

  @HiveField(5)
  final double price;

  @HiveField(6)
  final String description;

  @HiveField(7)
  final dynamic thumbnail;

  @HiveField(8)
  final String source;

  @HiveField(9)
  final String status;

  ProductHiveModel({
    required this.id,
    required this.title,
    required this.category,
    required this.stock,
    required this.unit,
    required this.price,
    required this.description,
    required this.thumbnail,
    required this.source,
    required this.status,
  });

  Map<String, dynamic> toMap() {
  return {
    "id": id,
    "title": title,
    "category": category,
    "stock": stock,
    "unit": unit,
    "price": price,
    "description": description,
    "thumbnail": thumbnail,
    "source": source,
    "status": status,
  };
}
}