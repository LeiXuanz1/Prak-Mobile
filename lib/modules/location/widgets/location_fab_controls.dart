import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';

class LocationFabControls extends StatelessWidget {
  final LocationController c = Get.find();
  final RxBool expanded = false.obs;

  LocationFabControls({super.key});

  final double radius = 90; // jarak dari main button

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          // GPS
          _buildRadialButton(
            angleDegree: 0,
            icon: Icons.satellite_alt,
            label: "GPS",
            onTap: c.getGPSLocation,
          ),

          // NETWORK
          _buildRadialButton(
            angleDegree: 45,
            icon: Icons.network_wifi,
            label: "Network",
            onTap: c.getNetworkLocation,
          ),

          // LIVE
          _buildRadialButton(
            angleDegree: 90,
            icon: c.isStreaming.value
                ? Icons.stop_circle_outlined
                : Icons.play_circle_fill,
            label: c.isStreaming.value ? "Stop Live" : "Live",
            onTap: () {
              if (c.isStreaming.value) {
                c.stopLiveLocation();
              } else {
                c.startLiveLocation();
              }
            },
          ),

          // MAIN BUTTON
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: "main",
              backgroundColor: expanded.value ? Colors.red : Colors.blue,
              child: Icon(expanded.value ? Icons.close : Icons.menu, size: 28),
              onPressed: () => expanded.value = !expanded.value,
            ),
          ),
        ],
      );
    });
  }

  // Build radial animated FAB
  Widget _buildRadialButton({
    required double angleDegree,
    required IconData icon,
    required String label,
    required Function() onTap,
  }) {
    final double rad = angleDegree * pi / 180;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      right: expanded.value ? (radius * cos(rad)) + 20 : 20,
      bottom: expanded.value ? (radius * sin(rad)) + 20 : 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: expanded.value ? 1 : 0,
        child: FloatingActionButton(
          heroTag: label,
          mini: true,
          backgroundColor: Colors.blue,
          child: Icon(icon, size: 18),
          onPressed: onTap,
        ),
      ),
    );
  }
}