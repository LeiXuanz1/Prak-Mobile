import 'package:get/get.dart';
import 'package:my_app/core/controllers/notification_controller.dart';
import 'package:my_app/data/local/controllers/hive_product_controller.dart';
import 'package:my_app/data/cloud/supabase_service.dart';
import 'package:my_app/modules/apify/controllers/apify_controller.dart';
import 'package:my_app/modules/product/controllers/supabase_product_controller.dart';
import 'package:my_app/modules/auth/controllers/auth_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(NotificationController(), permanent: true);
    Get.put(SupabaseService(), permanent: true);
    Get.put(ApifyController(), permanent: true);
    Get.lazyPut(() => HiveProductController(), fenix: true);
    Get.lazyPut(() => SupabaseProductController(), fenix: true);
  }
}
