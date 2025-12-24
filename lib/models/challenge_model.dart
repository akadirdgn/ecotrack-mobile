import 'package:cloud_firestore/cloud_firestore.dart';

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
