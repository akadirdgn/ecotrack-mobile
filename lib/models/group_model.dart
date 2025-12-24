import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final List<String> memberIds;
  final int totalPoints;
  final String createdBy;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.memberIds,
    required this.totalPoints,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'totalPoints': totalPoints,
      'createdBy': createdBy,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      totalPoints: map['totalPoints']?.toInt() ?? 0,
      createdBy: map['createdBy'] ?? '',
    );
  }
}
