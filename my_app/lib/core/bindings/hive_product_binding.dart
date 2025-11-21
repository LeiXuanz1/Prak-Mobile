import 'package:get/get.dart';
import '../../data/local/controllers/hive_product_controller.dart';

class HiveProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HiveProductController());
  }
}