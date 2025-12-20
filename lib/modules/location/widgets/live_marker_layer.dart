import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import '../controllers/location_controller.dart';

class LiveMarkerLayer extends StatelessWidget {
  final LocationController controller = Get.find();

  LiveMarkerLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final marker = controller.userMarker.value;

      if (marker == null) {
        return const MarkerLayer(markers: []);
      }

      return MarkerLayer(markers: [marker]);
    });
  }
}
