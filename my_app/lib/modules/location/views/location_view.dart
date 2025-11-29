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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OpenStreet")),
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
            ),

            Positioned(
              bottom: 140,
              left: 20,
              right: 20,
              child: LocationInfoCard(),
            ),
          ],
        );
      }),
      floatingActionButton: LocationFabControls(),
    );
  }
}