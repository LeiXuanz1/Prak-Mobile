import 'package:uuid/uuid.dart';
import '../../../data/local/hive_models/product_hive_model.dart';
import '../models/product_form_data.dart';

ProductHiveModel mapFormToHive(
  ProductFormData f,
  ProductHiveModel? old,
) {
  return ProductHiveModel(
    id: old?.id ?? const Uuid().v4(),
    title: f.title,
    category: f.category,
    stock: f.stock,
    unit: f.unit,
    price: f.price,
    description: f.description,
    thumbnail: f.imagePath,
    source: 'local',
    status: f.stock > 20 ? 'Available' : 'Low Stock',
    updatedAt: DateTime.now(),
    isSynced: false,
    isDeleted: false,
    packaging: f.packaging,
  );
}