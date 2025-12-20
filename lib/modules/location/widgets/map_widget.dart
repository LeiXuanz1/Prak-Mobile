import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/modules/location/controllers/location_controller.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final Function(double, double)? onMapTap;

  MapWidget({super.key, required this.mapController, this.onMapTap});

  final LocationController c = Get.find();

  @override
  Widget build(BuildContext context) {
    final loc = c.currentLocation.value;

    if (loc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            onMapReady: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              c.mapReady.value = true;
            },
            onTap: (tapPosition, point) {
              if (onMapTap != null) {
                onMapTap!(point.latitude, point.longitude);
              }
            },
            initialCenter: LatLng(loc.latitude, loc.longitude),
            initialZoom: 16,
            keepAlive: true,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.example.locationapp',
            ),

            Obx(() {
              final markers = <Marker>[];

              // Marker merah = lokasi real-time
              if (c.userMarker.value != null) {
                markers.add(c.userMarker.value!);
              }

              // Marker biru = lokasi yang dipilih
              if (c.selectedMarker.value != null) {
                markers.add(c.selectedMarker.value!);
              }

              return MarkerLayer(markers: markers);
            }),
          ],
        ),

        Obx(() {
          if (c.currentLocation.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
