import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/modules/location/services/location_service.dart';
import '../models/location_model.dart';
import '../providers/location_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationController extends GetxController {
  final LocationProvider provider = LocationProvider();
  final mapController = MapController();
  late final LocationService service;

  Rxn<Marker> userMarker = Rxn<Marker>();
  Rxn<Marker> selectedMarker =
      Rxn<Marker>(); // Marker untuk lokasi yang dipilih
  Rx<LocationModel?> currentLocation = Rx<LocationModel?>(null);
  Rx<LocationModel?> selectedLocation = Rx<LocationModel?>(
    null,
  ); // Lokasi yang dipilih

  RxBool isStreaming = false.obs;

  StreamSubscription<LocationModel>? _subscription;

  DateTime? _lastMoveTime;

  var mapReady = false.obs;

  @override
  void onInit() {
    service = provider.service;
    super.onInit();

    debounce<LocationModel?>(currentLocation, (loc) {
      if (loc != null) updateUserMarker(loc);
    }, time: Duration(milliseconds: 300));

    detectBestLocationSource();
  }

  void moveTo(double lat, double lng) {
    if (!mapReady.value) return;

    final now = DateTime.now();
    if (_lastMoveTime != null &&
        now.difference(_lastMoveTime!) < const Duration(seconds: 1)) {
      return;
    }

    _lastMoveTime = now;

    mapController.move(LatLng(lat, lng), 16);
  }

  void startLiveLocation() {
    if (isStreaming.value) return;

    isStreaming.value = true;

    _subscription?.cancel();

    _subscription = provider.liveLocation().listen((location) {
      currentLocation.value = location;

      if (isStreaming.value) {
        moveTo(location.latitude, location.longitude);
      }
    });
  }

  void stopLiveLocation() {
    isStreaming.value = false;
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> getGPSLocation() async {
    if (!await provider.service.checkPermissionGPS()) {
      Get.snackbar("Permission Denied", "Please allow location access");
      return;
    }

    currentLocation.value = await provider.getGPS();

    final loc = currentLocation.value!;

    debugPrint(
      "GPS result: ${loc.latitude}, ${loc.longitude}, acc=${loc.accuracy}",
    );

    moveTo(loc.latitude, loc.longitude);
  }

  Future<void> getNetworkLocation() async {
    if (!await provider.service.checkPermissionNetwork()) {
      Get.snackbar("Permission Denied", "Please enable permission in settings");
      return;
    }

    currentLocation.value = await provider.getNetwork();
    final loc = currentLocation.value!;
    moveTo(loc.latitude, loc.longitude);
  }

  void updateUserMarker(LocationModel loc) {
    userMarker.value = Marker(
      point: LatLng(loc.latitude, loc.longitude),
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on, color: Colors.red),
    );
  }

  void setMarkerFromTap(double lat, double lng) {
    // Simpan lokasi yang dipilih (tidak mengubah currentLocation)
    selectedLocation.value = LocationModel(
      latitude: lat,
      longitude: lng,
      accuracy: 0,
      timestamp: DateTime.now(),
    );

    // Buat marker biru untuk lokasi yang dipilih
    selectedMarker.value = Marker(
      point: LatLng(lat, lng),
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on, color: Colors.blue),
    );

    moveTo(lat, lng);
  }

  Future<void> detectBestLocationSource() async {
    final systemLocationOn = await service.isSystemLocationEnabled();
    debugPrint("System location enabled? $systemLocationOn");

    if (!systemLocationOn) {
      Get.snackbar(
        "Location Disabled",
        "Please Turn ON Location on your device",
      );
      return;
    }

    final gpsPerm = await service.checkPermissionGPS();
    debugPrint("GPS Permission: $gpsPerm");

    if (gpsPerm) {
      try {
        debugPrint("Trying GPS...");
        await getGPSLocation();
        debugPrint("GPS OK");
        return;
      } catch (e) {
        debugPrint("GPS FAILED: $e");
      }
    }

    // FALLBACK ke network
    final netPerm = await service.checkPermissionNetwork();
    debugPrint("Network Permission: $netPerm");

    if (netPerm) {
      try {
        debugPrint("Trying NETWORK...");
        await getNetworkLocation();
        debugPrint("NETWORK OK");
        return;
      } catch (e) {
        debugPrint("NETWORK FAILED: $e");
      }
    }

    debugPrint("NO LOCATION AVAILABLE");
    Get.snackbar(
      "Location Disabled",
      "Both GPS and Network unavailable. Please enable location",
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    mapController.dispose();

    super.onClose();
  }
}
