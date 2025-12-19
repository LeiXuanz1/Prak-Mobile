import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionController extends GetxController {
  var permissionGranted = false.obs;
  var serviceEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    initPermission();
  }

  Future<void> initPermission() async {
    await checkPermission();
  }

  // Check if location service + permission aktif
  Future<void> checkPermission() async {
    final service = await Geolocator.isLocationServiceEnabled();
    serviceEnabled.value = service; 

    LocationPermission perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse) {
      permissionGranted.value = true;
    } else {
      permissionGranted.value = false;
    }
  }

  // Request permission jika belum diberikan
  Future<void> requestPermission() async {
    final perm = await Geolocator.requestPermission();
    
    permissionGranted.value =
        perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;

    serviceEnabled.value = await Geolocator.isLocationServiceEnabled();
  }

  bool get isReady => serviceEnabled.value && permissionGranted.value;
}
