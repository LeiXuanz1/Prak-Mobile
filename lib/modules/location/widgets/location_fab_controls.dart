import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';

class LocationFabControls extends StatelessWidget {
  final LocationController c = Get.find();
  final RxBool expanded = false.obs;

  LocationFabControls({super.key});

  static const double _radius = 90;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          _radialFab(
            context: context,
            angle: 0,
            icon: Icons.satellite_alt,
            label: 'GPS',
            onTap: c.getGPSLocation,
          ),
          _radialFab(
            context: context,
            angle: 45,
            icon: Icons.network_wifi,
            label: 'Network',
            onTap: c.getNetworkLocation,
          ),
          _radialFab(
            context: context,
            angle: 90,
            icon: c.isStreaming.value
                ? Icons.stop_circle_outlined
                : Icons.play_circle_fill,
            label: c.isStreaming.value ? 'Stop Live' : 'Live',
            onTap: () {
              c.isStreaming.value
                  ? c.stopLiveLocation()
                  : c.startLiveLocation();
            },
          ),

          // MAIN FAB
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'location-main-fab',
              backgroundColor: expanded.value
                  ? colorScheme.error
                  : colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 6,
              onPressed: () => expanded.toggle(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  expanded.value ? Icons.close : Icons.menu,
                  key: ValueKey(expanded.value),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _radialFab({
    required BuildContext context,
    required double angle,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final rad = angle * pi / 180;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      right: expanded.value ? (_radius * cos(rad)) + 20 : 20,
      bottom: expanded.value ? (_radius * sin(rad)) + 20 : 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: expanded.value ? 1 : 0,
        child: FloatingActionButton.small(
          heroTag: 'fab-$label',
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          elevation: 4,
          tooltip: label,
          onPressed: onTap,
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
