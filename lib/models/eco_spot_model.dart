import 'package:cloud_firestore/cloud_firestore.dart';

class EcoSpot {
  final String id;
  final String name;
  final String type; // 'recycle', 'water', 'charging', 'tree'
  final double latitude;
  final double longitude;
  final String description;
  final String address;

  EcoSpot({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'address': address,
    };
  }

  factory EcoSpot.fromMap(Map<String, dynamic> map) {
    return EcoSpot(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'recycle',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      address: map['address'] ?? '',
    );
  }
}
