import 'package:get/get.dart';
import 'package:my_app/modules/kecap/controllers/supabase_product_controller.dart';
import '/modules/kecap/controllers/apify_controller.dart';

class ApifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApifyController>(() => ApifyController());
    Get.lazyPut(() => SupabaseProductController());
  }
}
