import 'package:get/get.dart';
import '../services/supabase_service.dart';

class SupabaseProductController extends GetxController {
  var products = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final data = await SupabaseService.getSoySauces();
      products.assignAll(data);
    } catch (e) {
      print("Error loadProducts: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
