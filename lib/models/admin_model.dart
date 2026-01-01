import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String uid;
  final String email;
  final String role; // 'super_admin', 'moderator'
  final List<String> permissions;
  final DateTime createdAt;

  AdminModel({
    required this.uid,
    required this.email,
    this.role = 'moderator',
    this.permissions = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'permissions': permissions,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'moderator',
      permissions: List<String>.from(map['permissions'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
