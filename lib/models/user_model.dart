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

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'User',
      avatarUrl: map['avatarUrl'],
      totalPoints: map['totalPoints'] ?? 0,
      activityCount: map['activityCount'] ?? 0,
      plasticCollected: (map['plasticCollected'] as num?)?.toDouble() ?? 0.0,
      treesPlanted: (map['treesPlanted'] as num?)?.toInt() ?? 0,
      co2Saved: (map['co2Saved'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ImpactStat {
  final String userId;
  final String category; // e.g. "plastic_bottles", "co2_saved"
  final double value;

  ImpactStat({required this.userId, required this.category, required this.value});
}
