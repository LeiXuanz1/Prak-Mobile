import 'package:hive/hive.dart';

part 'contact_hive_model.g.dart';

@HiveType(typeId: 4)
class ContactHiveModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name; // Nama toko/pembeli

  @HiveField(2)
  final String? phone;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final String address;

  @HiveField(5)
  final double? latitude; // Untuk location marker

  @HiveField(6)
  final double? longitude; // Untuk location marker

  @HiveField(7)
  final String? locationLabel; // Label lokasi (contoh: "Toko Utama", "Supplier ABC")

  @HiveField(8)
  final DateTime createdAt;

  ContactHiveModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.address,
    this.latitude,
    this.longitude,
    this.locationLabel,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'locationLabel': locationLabel,
      'createdAt': createdAt,
    };
  }

  ContactHiveModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
    String? locationLabel,
    DateTime? createdAt,
  }) {
    return ContactHiveModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationLabel: locationLabel ?? this.locationLabel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
