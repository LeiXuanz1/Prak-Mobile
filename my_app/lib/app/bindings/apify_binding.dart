import 'package:get/get.dart';
import '/modules/kecap/controllers/apify_controller.dart';

class ApifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApifyController>(() => ApifyController());
  }
}
