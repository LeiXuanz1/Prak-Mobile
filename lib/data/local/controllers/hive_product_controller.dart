import 'dart:async';
import 'package:get/get.dart';
import '../hive_boxes.dart';
import '../hive_models/product_hive_model.dart';
import '../../../modules/apify/controllers/apify_controller.dart';
import '../../../core/services/notification_service.dart';
import 'package:my_app/core/services/connectvity_service.dart';
import 'package:my_app/data/sync/product_sync_service.dart';

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

    final productList = box.values.where((p) => p.isDeleted == false).toList();

    // Simpan versi model
    products.assignAll(productList);

    // Simpan versi Map (misalkan UI butuh JSON-like)
    apiProducts.value = productList.map((p) => p.toMap()).toList();

    // Check low stock
    for (final p in productList) {
      _checkAndShowLowStockAlert(p.id, p.title, p.stock);
    }

    loading.value = false;
  }

  // Check if stock just dropped below threshold (first time).
  // Only show notification if: current stock < threshold AND last known stock >= threshold
  Future<void> _checkAndShowLowStockAlert(
    String productId,
    String title,
    int currentStock,
  ) async {
    final shouldShow = await NotificationService.shouldShowLowStockAlert(
      productId: productId,
      currentStock: currentStock,
      threshold: lowStockThreshold,
    );

    if (shouldShow) {
      await NotificationService.showLowStock(
        productId: productId,
        title: title,
        stock: currentStock,
      );
    }
  }

  // TAMBAH PRODUK
  Future<void> addProduct(
    ProductHiveModel product, {
    String source = 'lokal',
  }) async {
    final box = HiveBoxes.products;
    await box.put(product.id, product);

    // reload list
    loadProducts();

    _trySyncDebounce();

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
    } catch (_) {}

    if (source != 'supabase') {
      _trySyncDebounce();
    }
  }

  // HAPUS PRODUK
  Future<void> deleteProduct(String id) async {
    final box = HiveBoxes.products;
    final old = box.get(id);
    if (old == null) return;

    final deleted = ProductHiveModel(
      id: old.id,
      title: old.title,
      category: old.category,
      stock: old.stock,
      unit: old.unit,
      price: old.price,
      description: old.description,
      thumbnail: old.thumbnail,
      source: old.source,
      status: old.status,
      updatedAt: DateTime.now(),
      isSynced: false,
      isDeleted: true,
      packaging: old.packaging,
    );

    await box.put(id, deleted);

    loadProducts();
    _trySyncDebounce();
  }

  // UPDATE PRODUK
  Future<void> updateProduct(String id, ProductHiveModel product) async {
    final box = HiveBoxes.products;

    final updated = ProductHiveModel(
      id: product.id,
      title: product.title,
      category: product.category,
      stock: product.stock,
      unit: product.unit,
      price: product.price,
      description: product.description,
      thumbnail: product.thumbnail,
      source: 'local',
      status: product.status,
      updatedAt: DateTime.now(),
      isSynced: false,
      isDeleted: false,
      packaging: product.packaging,
    );

    await box.put(id, updated);

    loadProducts();
    _trySyncDebounce();

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
              p['title'].toString().toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              p['category'].toString().toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  Timer? _syncTimer;

  void _trySyncDebounce({String source = 'local'}) {
    if (source == 'supabase') return;

    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 2), () {
      _runSyncSafely();
    });
  }

  Future<void> _runSyncSafely() async {
    try {
      final online = await ConnectivityService.isOnline();
      if (!online) return;

      await ProductSyncService.sync();
    } catch (e, s) {
      print('SYNC ERROR');
      print(e);
      print(s);
    }
  }
}
