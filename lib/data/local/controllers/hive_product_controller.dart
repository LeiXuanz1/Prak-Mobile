import 'package:get/get.dart';
import '../hive_boxes.dart';
import '../hive_models/product_hive_model.dart';
import '../../../modules/apify/controllers/apify_controller.dart';
import '../../../core/services/notification_service.dart';

class HiveProductController extends GetxController {
  var products = <ProductHiveModel>[].obs;
  RxList<Map<String, dynamic>> apiProducts = <Map<String, dynamic>>[].obs;
  static const int lowStockThreshold = 5;

  // STATE
  RxString searchQuery = ''.obs;
  RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // LOAD PRODUK DARI HIVE
  void loadProducts() {
    loading.value = true;

    final box = HiveBoxes.products;
    final productList = box.values.toList();

    // Simpan versi model
    products.assignAll(productList);

    // Simpan versi Map (misalkan UI butuh JSON-like)
    apiProducts.value = productList.map((p) => p.toMap()).toList();

    for (final p in productList) {
      if (p.stock <= lowStockThreshold) {
        NotificationService.showLowStock(
          productId: p.id,
          title: p.title,
          stock: p.stock,
        );
      }
    }

    loading.value = false;
  }

  // TAMBAH PRODUK
  Future<void> addProduct(ProductHiveModel product) async {
    final box = HiveBoxes.products;
    await box.put(product.id, product);

    // reload list
    loadProducts();

    // Add a recent activity
    try {
      final apify = Get.find<ApifyController>();
      apify.addRecentActivity({
        'type': 'added',
        'title': product.title,
        'description': 'Added to local storage',
        'timeAgo': 'just now',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
    }
  }

  // HAPUS PRODUK
  Future<void> deleteProduct(String id) async {
    final box = HiveBoxes.products;
    await box.delete(id);

    loadProducts();
  }

  // UPDATE PRODUK
  Future<void> updateProduct(String id, ProductHiveModel product) async {
    final box = HiveBoxes.products;
    await box.put(id, product);

    loadProducts();

    // Log recent activity for update
    try {
      final apify = Get.find<ApifyController>();
      apify.addRecentActivity({
        'type': 'updated',
        'title': product.title,
        'description': 'Updated product',
        'timeAgo': 'just now',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  // CLEAR SEMUA DATA
  Future<void> clearAll() async {
    final box = HiveBoxes.products;
    await box.clear();

    loadProducts();
  }

  // FILTER / SEARCH
  List<Map<String, dynamic>> get filteredProducts {
    if (searchQuery.value.isEmpty) return apiProducts;

    return apiProducts
        .where(
          (p) =>
              p['name'].toString().toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              p['category'].toString().toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }
}
