import '../models/location_model.dart';
import '../services/location_service.dart';
import 'dart:developer';

class LocationProvider {
  final LocationService service = LocationService();

  // Stream live lokasi
  Stream<LocationModel> liveLocation() async* {
    await service.checkPermissionGPS();

    yield* service.liveLocationStream.map(
      (pos) => LocationModel(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        timestamp: pos.timestamp,
      ),
    );
  }

  // Mendapatkan lokasi dari GPS provider
  Future<LocationModel> getGPS() async {
    final pos = await service.getGPS();

    return LocationModel(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      timestamp: pos.timestamp,
    );
  }

  // Mendapatkan lokasi dari Network provider
  Future<LocationModel> getNetwork() async {
    log("Calling getNetwork()");
    final locData = await service.getNetwork();
    log(
      "Network result: ${locData.latitude}, ${locData.longitude}, acc=${locData.accuracy}",
    );

    return LocationModel(
      latitude: locData.latitude!,
      longitude: locData.longitude!,
      accuracy: locData.accuracy ?? 40,
      timestamp: DateTime.now(),
    );
  }
}
