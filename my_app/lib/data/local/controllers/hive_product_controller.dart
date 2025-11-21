import 'package:get/get.dart';
import '../hive_boxes.dart';
import '../hive_models/product_hive_model.dart';

class HiveProductController extends GetxController {
  // LIST UTAMA (Model Asli)
  var products = <ProductHiveModel>[].obs;

  // LIST VERSI MAP (Biasanya dipakai untuk UI API-style)
  RxList<Map<String, dynamic>> apiProducts = <Map<String, dynamic>>[].obs;

  // STATE
  RxString searchQuery = ''.obs;
  RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // ================================================================
  // LOAD PRODUK DARI HIVE
  // ================================================================
  void loadProducts() {
    loading.value = true;

    final box = HiveBoxes.products;
    final productList = box.values.toList();

    // Simpan versi model
    products.assignAll(productList);

    // Simpan versi Map (misalkan UI butuh JSON-like)
    apiProducts.value = productList.map((p) => p.toMap()).toList();

    loading.value = false;
  }

  // TAMBAH PRODUK
  Future<void> addProduct(ProductHiveModel product) async {
    final box = HiveBoxes.products;
    await box.put(product.id, product);

    loadProducts();
  }

  // HAPUS PRODUK
  Future<void> deleteProduct(String id) async {
    final box = HiveBoxes.products;
    await box.delete(id);

    loadProducts();
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
        .where((p) =>
            p['name']
                .toString()
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            p['category']
                .toString()
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()))
        .toList();
  }
}