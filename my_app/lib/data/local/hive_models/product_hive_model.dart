import 'package:hive/hive.dart';

part 'product_hive_model.g.dart';

@HiveType(typeId: 1)
class ProductHiveModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String brand;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final dynamic price;

  ProductHiveModel({
    required this.id,
    required this.title,
    required this.brand,
    required this.imageUrl,
    required this.price,
  });

  factory ProductHiveModel.fromJson(Map<String, dynamic> json) {
    return ProductHiveModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      brand: json['brand'] ?? '',
      imageUrl: json['image'] ?? '',
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'brand': brand,
        'imageUrl': imageUrl,
        'price': price,
      };
}
