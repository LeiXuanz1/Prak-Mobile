class LocationModel {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  // Convert dari Geolocator Position
  factory LocationModel.fromPosition({
    required double latitude,
    required double longitude,
    required double accuracy,
    DateTime? timestamp,
  }) {
    return LocationModel(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  // Untuk debugging
  @override
  String toString() {
    return "Location(lat: $latitude, lon: $longitude, acc: $accuracy, time: $timestamp)";
  }
}
