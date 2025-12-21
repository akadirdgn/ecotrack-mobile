import 'package:cloud_firestore/cloud_firestore.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int requiredPoints;
  final String category;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.requiredPoints,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'requiredPoints': requiredPoints,
      'category': category,
    };
  }

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      requiredPoints: map['requiredPoints']?.toInt() ?? 0,
      category: map['category'] ?? '',
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double targetAmount;
  final String typeId;
  final List<String> participants;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.targetAmount,
    required this.typeId,
    required this.participants,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'targetAmount': targetAmount,
      'typeId': typeId,
      'participants': participants,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      typeId: map['typeId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
    );
  }
}
