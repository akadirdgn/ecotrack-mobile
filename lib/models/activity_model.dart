import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String userId;
  final String typeId;
  final String description;
  final String photoId;
  final String locationId;
  final DateTime timestamp;
  final int pointsEarned;
  final double amount;
  final String status;
  final double? latitude;
  final double? longitude;

  Activity({
    required this.id, 
    required this.userId, 
    required this.typeId, 
    required this.description, 
    required this.photoId, 
    required this.locationId, 
    required this.timestamp,
    this.pointsEarned = 0,
    this.amount = 0.0,
    this.status = 'pending',
    this.latitude,
    this.longitude,
  });
  
  factory Activity.fromMap(Map<String, dynamic> data) {
    return Activity(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      typeId: data['typeId'] ?? '',
      description: data['description'] ?? '',
      photoId: data['photoId'] ?? '',
      locationId: data['locationId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pointsEarned: (data['pointsEarned'] as num?)?.toInt() ?? 0,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pending',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }
}


class ActivityLocation {
  final String id;
  final double latitude;
  final double longitude;
  final String address;

  ActivityLocation({required this.id, required this.latitude, required this.longitude, required this.address});
}

class Photo {
  final String id;
  final String storageUrl;
  final DateTime takenAt;
  final Map<String, dynamic> metadata;

  Photo({required this.id, required this.storageUrl, required this.takenAt, required this.metadata});
}
