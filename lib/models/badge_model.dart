import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeModel {
  final String id;
  final String name;
  final String iconUrl;
  final int requiredPoints;
  final String category; // 'milestone', 'activity', 'special'
  final String description;

  BadgeModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.requiredPoints,
    required this.category,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'requiredPoints': requiredPoints,
      'category': category,
      'description': description,
    };
  }

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      requiredPoints: map['requiredPoints'] ?? 0,
      category: map['category'] ?? 'milestone',
      description: map['description'] ?? '',
    );
  }
}
