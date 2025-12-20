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
  final String? description;

  @HiveField(7)
  final dynamic thumbnail;

  @HiveField(8)
  final String source;

  @HiveField(9)
  final String status;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final bool isSynced;

  @HiveField(12)
  final bool isDeleted;

  @HiveField(13)
  final String packaging;

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
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
    required this.packaging,
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
      "packaging": packaging,
      "thumbnail": thumbnail,
      "source": source,
      "status": status,
    };
  }

  Map<String, dynamic> toSupabase() {
    final raw = thumbnail?.toString().trim();

    final safeThumbnail = (raw != null && raw.startsWith('/')) ? null : raw;

    return {
      'id': id,
      'display_name': title,
      'category': category,
      'stock': stock,
      'price': price,
      'unit_size': unit.trim().toLowerCase(),
      'thumbnail': safeThumbnail,
      'description': description,
      'packaging': packaging,
    };
  }
}

extension ProductHiveModelCopy on ProductHiveModel {
  ProductHiveModel copyWith({
    String? id,
    String? title,
    String? category,
    int? stock,
    String? unit,
    double? price,
    String? description,
    String? packaging,
    dynamic thumbnail,
    String? source,
    String? status,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return ProductHiveModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      description: description ?? this.description,
      packaging: packaging ?? this.packaging,
      thumbnail: thumbnail ?? this.thumbnail,
      source: source ?? this.source,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
