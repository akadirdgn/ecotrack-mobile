import 'package:cloud_firestore/cloud_firestore.dart';

class UserBadge {
  final String userId;
  final String badgeId;
  final DateTime earnedAt;

  UserBadge({
    required this.userId,
    required this.badgeId,
    required this.earnedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'badgeId': badgeId,
      'earnedAt': Timestamp.fromDate(earnedAt),
    };
  }

  factory UserBadge.fromMap(Map<String, dynamic> map) {
    return UserBadge(
      userId: map['userId'] ?? '',
      badgeId: map['badgeId'] ?? '',
      earnedAt: (map['earnedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
