import 'package:get/get.dart';
import '../../modules/location/controllers/location_controller.dart';
import '../../modules/location/controllers/location_permission_controller.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LocationPermissionController());
    Get.put(LocationController());
  }
}
