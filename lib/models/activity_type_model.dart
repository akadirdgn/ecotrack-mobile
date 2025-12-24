import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityType {
  final String id;
  final String name;
  final String iconName; // MaterialIcons icon name as string
  final int pointsPerUnit;
  final String unit; // 'kg' or 'adet'

  ActivityType({
    required this.id,
    required this.name,
    required this.iconName,
    required this.pointsPerUnit,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'pointsPerUnit': pointsPerUnit,
      'unit': unit,
    };
  }

  factory ActivityType.fromMap(Map<String, dynamic> map) {
    return ActivityType(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconName: map['iconName'] ?? 'eco',
      pointsPerUnit: map['pointsPerUnit'] ?? 0,
      unit: map['unit'] ?? 'kg',
    );
  }
}
