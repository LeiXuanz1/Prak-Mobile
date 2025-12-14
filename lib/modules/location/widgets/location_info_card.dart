import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/location_controller.dart';

class LocationInfoCard extends StatelessWidget {
  final LocationController c = Get.find();

  LocationInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loc = c.currentLocation.value;

      if (loc == null) {
        return const SizedBox.shrink();
      }

      return Card(
        margin: const EdgeInsets.all(12),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Latitude:  ${loc.latitude}"),
              Text("Longitude: ${loc.longitude}"),
              Text("Accuracy:  ${loc.accuracy} meter"),
              const SizedBox(height: 8),
              Text(
                "Updated: ${loc.timestamp}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    });
  }
}
