import 'package:cloud_firestore/cloud_firestore.dart';

class TipModel {
  final String id;
  final String title;
  final String content;
  final String iconEmoji;
  final DateTime date;
  final bool isActive;

  TipModel({
    required this.id,
    required this.title,
    required this.content,
    required this.iconEmoji,
    required this.date,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'iconEmoji': iconEmoji,
      'date': Timestamp.fromDate(date),
      'isActive': isActive,
    };
  }

  factory TipModel.fromMap(Map<String, dynamic> map) {
    return TipModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      iconEmoji: map['iconEmoji'] ?? '💡',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? false,
    );
  }
}
