import 'package:cloud_firestore/cloud_firestore.dart';

// 1. Users Table
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final int totalPoints;
  final int activityCount;
  final double plasticCollected;
  final int treesPlanted;
  final double co2Saved;

  UserModel({
    required this.uid, 
    required this.email, 
    required this.displayName, 
    this.avatarUrl, 
    this.totalPoints = 0,
    this.activityCount = 0,
    this.plasticCollected = 0.0,
    this.treesPlanted = 0,
    this.co2Saved = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'totalPoints': totalPoints,
    'activityCount': activityCount,
    'plasticCollected': plasticCollected,
    'treesPlanted': treesPlanted,
    'co2Saved': co2Saved,
  };
}

// 2. Activities Table
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

// 3. Activity Types Table
class ActivityType {
  final String id;
  final String name;
  final String icon;
  final int pointsValue;

  ActivityType({required this.id, required this.name, required this.icon, required this.pointsValue});
}

// 4. Locations Table
class ActivityLocation {
  final String id;
  final double latitude;
  final double longitude;
  final String address;

  ActivityLocation({required this.id, required this.latitude, required this.longitude, required this.address});
  
  // Helper for maps
  // LatLng get toLatLng => LatLng(latitude, longitude); 
}

// 5. Photos Table
class Photo {
  final String id;
  final String storageUrl;
  final DateTime takenAt;
  final Map<String, dynamic> metadata;

  Photo({required this.id, required this.storageUrl, required this.takenAt, required this.metadata});
}

// 6. Badges Table
class Badge {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String criteria;

  Badge({required this.id, required this.name, required this.description, required this.imageUrl, required this.criteria});
}

// 7. UserBadges Table (Join)
class UserBadge {
  final String userId;
  final String badgeId;
  final DateTime earnedAt;

  UserBadge({required this.userId, required this.badgeId, required this.earnedAt});
}

// 8. Comments Table
class Comment {
  final String id;
  final String activityId;
  final String userId;
  final String userName; // Added for display
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id, 
    required this.activityId, 
    required this.userId, 
    required this.userName, 
    required this.text, 
    required this.createdAt
  });
}

// 9. Likes Table
class Like {
  final String activityId;
  final String userId;
  final DateTime createdAt;

  Like({required this.activityId, required this.userId, required this.createdAt});
}

// 10. ImpactStats Table
class ImpactStat {
  final String userId;
  final String category; // e.g. "plastic_bottles", "co2_saved"
  final double value;

  ImpactStat({required this.userId, required this.category, required this.value});
}
