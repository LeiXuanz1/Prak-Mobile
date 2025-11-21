import '/data/local/hive_models/product_hive_model.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProductLocalController extends GetxController {
  final RxList<ProductHiveModel> products = <ProductHiveModel>[].obs;

  @override
  void onInit() {
    loadHiveProducts();
    super.onInit();
  }

  void loadHiveProducts() {
    final box = Hive.box<ProductHiveModel>('products');
    products.assignAll(box.values.toList());
  }

  Future<void> addProduct(ProductHiveModel p) async {
    final box = Hive.box<ProductHiveModel>('products');
    await box.put(p.id, p);

    products.insert(0, p);
  }

  Future<void> deleteProduct(String id) async {
    final box = Hive.box<ProductHiveModel>('products');
    await box.delete(id);

    products.removeWhere((p) => p.id == id);
  }
}
