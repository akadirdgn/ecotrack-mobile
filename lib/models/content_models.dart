import 'package:cloud_firestore/cloud_firestore.dart';

class Tip {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime publishDate;

  Tip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.publishDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'publishDate': Timestamp.fromDate(publishDate),
    };
  }

  factory Tip.fromMap(Map<String, dynamic> map) {
    return Tip(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      publishDate: (map['publishDate'] as Timestamp).toDate(),
    );
  }
}
