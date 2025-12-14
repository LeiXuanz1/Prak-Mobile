import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

class LocationService {
  final loc.Location _location = loc.Location();

  // Cek permission GPS
  Future<bool> checkPermissionGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // Cek permission NETWORK
  Future<bool> checkPermissionNetwork() async {
    // Check permission
    loc.PermissionStatus perm = await _location.hasPermission();
    
    if (perm == loc.PermissionStatus.denied) {
      perm = await _location.requestPermission();
    }

    return perm == loc.PermissionStatus.granted ||
        perm == loc.PermissionStatus.grantedLimited;
  }

  Future<bool> isSystemLocationEnabled() async {
    return await _location.serviceEnabled();
  }

  // GPS
  Future<Position> getGPS() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
  }

  // NETWORK ONLY
  Future<loc.LocationData> getNetwork() async {
    return await _location.getLocation();
  }

  // Live location
  Stream<Position> get liveLocationStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    );
  }
}
