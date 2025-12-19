import 'package:get/get.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/local/models/product_hive_model.dart';

class BarangController extends GetxController {
  final productList = Rx<List<ProductHiveModel>>([]);
  final isLoading = Rx<bool>(false);

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
  }

  void _loadProducts() {
    try {
      final products = HiveBoxes.products.values.toList();
      productList.value = products;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat barang: $e');
    }
  }

  void deleteProduct(String productId) {
    try {
      final box = HiveBoxes.products;
      final index = box.values.toList().indexWhere((p) => p.id == productId);
      if (index != -1) {
        box.deleteAt(index);
        _loadProducts();
        Get.snackbar('Sukses', 'Barang berhasil dihapus');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus barang: $e');
    }
  }

  void refreshProducts() {
    _loadProducts();
  }
}
