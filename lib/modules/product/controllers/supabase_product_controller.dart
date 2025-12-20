import 'dart:developer';
import 'package:get/get.dart';
import '../../../data/cloud/supabase_service.dart';

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
    } catch (e, stack) {
      log("Error loadProducts", error: e, stackTrace: stack);
    } finally {
      isLoading.value = false;
    }
  }
}
