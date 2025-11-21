import 'package:get/get.dart';
import '../services/theme_controller.dart';
import '../../data/local/controllers/hive_product_controller.dart';
import '../../data/cloud/supabase_service.dart';
import '../../modules/product/controllers/supabase_product_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.put(SupabaseService(), permanent: true);
    Get.lazyPut(() => HiveProductController(), fenix: true);
    Get.lazyPut(() => SupabaseProductController(), fenix: true);
  }
}
