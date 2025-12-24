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
}

class ImpactStat {
  final String userId;
  final String category; // e.g. "plastic_bottles", "co2_saved"
  final double value;

  ImpactStat({required this.userId, required this.category, required this.value});
}
