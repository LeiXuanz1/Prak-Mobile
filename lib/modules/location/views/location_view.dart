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

  LocationView({this.isPickerMode = false, this.onLocationSelected});

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
            MapWidget(mapController: controller.mapController),

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
                        onLocationSelected!(
                          controller.currentLocation.value!.latitude,
                          controller.currentLocation.value!.longitude,
                        );
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
