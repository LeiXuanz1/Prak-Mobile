import 'package:get/get.dart';
import '../../modules/apify/controllers/apify_controller.dart';

class ApifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApifyController());
  }
}
