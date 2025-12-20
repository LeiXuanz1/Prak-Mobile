import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../controllers/location_permission_controller.dart';
import '../widgets/map_widget.dart';
import '../widgets/location_fab_controls.dart';
import '../widgets/location_info_card.dart';

class LocationView extends GetView<LocationController> {
  final LocationPermissionController permissionController =
      Get.find<LocationPermissionController>();

  final bool isPickerMode;
  final Function(double, double)? onLocationSelected;

  LocationView({
    super.key,
    this.isPickerMode = false,
    this.onLocationSelected,
  }) {
    // Reset selectedLocation saat picker mode dibuka
    if (isPickerMode) {
      controller.selectedLocation.value = null;
      controller.selectedMarker.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isPickerMode ? "Pilih Lokasi" : "OpenStreet")),
      body: Obx(() {
        if (!permissionController.permissionGranted.value) {
          return const Center(
            child: Text(
              "Location permission required.\nPlease enable GPS or grant permission.",
              textAlign: TextAlign.center,
            ),
          );
        }

        final loc = controller.currentLocation.value;

        if (loc == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            MapWidget(
              mapController: controller.mapController,
              onMapTap: isPickerMode
                  ? (lat, lng) => controller.setMarkerFromTap(lat, lng)
                  : null,
            ),

            if (!isPickerMode)
              Positioned(
                bottom: 140,
                left: 20,
                right: 20,
                child: LocationInfoCard(),
              ),

            // Picker mode: Show confirm button
            if (isPickerMode)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (onLocationSelected != null) {
                        // Gunakan selectedLocation jika ada, jika tidak gunakan currentLocation
                        final loc =
                            controller.selectedLocation.value ??
                            controller.currentLocation.value;
                        if (loc != null) {
                          onLocationSelected!(loc.latitude, loc.longitude);
                        }
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Pilih Lokasi Ini'),
                  ),
                ),
              ),
          ],
        );
      }),
      floatingActionButton: !isPickerMode ? LocationFabControls() : null,
    );
  }
}
