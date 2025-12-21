import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Badges ---
  
  Future<List<Badge>> getBadges() async {
    try {
      final snapshot = await _firestore.collection('badges').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Badge.fromMap(doc.data())).toList();
      }
    } catch (e) {
      print("Error fetching badges: $e");
    }

    // Fallback Mock Badges
    return [
      Badge(
        id: 'badge1',
        name: 'Doğa Dostu',
        description: 'İlk aktiviteni tamamla',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/3209/3209265.png',
        requiredPoints: 10,
        category: 'beginner',
      ),
      Badge(
        id: 'badge2',
        name: 'Plastik Avcısı',
        description: '5 Plastik atığı geri dönüştür',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/3209/3209236.png',
        requiredPoints: 50,
        category: 'expert',
      ),
       Badge(
        id: 'badge3',
        name: 'Ağaç Dostu',
        description: '1 Ağaç dikimine katıl',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/3209/3209204.png',
        requiredPoints: 100,
        category: 'expert',
      ),
    ];
  }



  // --- Challenges ---

  Future<List<Challenge>> getActiveChallenges() async {
    try {
      final now = Timestamp.now();
      final snapshot = await _firestore
          .collection('challenges')
          .where('endDate', isGreaterThan: now)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Challenge.fromMap(doc.data())).toList();
      }
    } catch (e) {
      print("Error fetching challenges: $e");
    }

    // Fallback Mock Challenges
    return [
      Challenge(
        id: 'c1',
        title: 'Haftalık Plastiksiz Yaşam',
        description: 'Bu hafta hiç plastik kullanma!',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 6)),
        targetAmount: 0,
        typeId: 'plastic',
        participants: ['mock_user_1', 'mock_user_2'],
      ),
      Challenge(
        id: 'c2',
        title: '1000 Ağaç Kampanyası',
        description: 'Hep birlikte 1000 ağaç dikelim.',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        targetAmount: 1000,
        typeId: 'tree',
        participants: [],
      ),
    ];
  }

  Future<void> joinChallenge(String challengeId, String userId) async {
    final docRef = _firestore.collection('challenges').doc(challengeId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // If it doesn't exist, it might be a mock challenge we need to "seed"
      if (challengeId == 'c1') {
        await docRef.set({
           'id': 'c1',
           'title': 'Haftalık Plastiksiz Yaşam',
           'description': 'Bu hafta hiç plastik kullanma!',
           'startDate': DateTime.now().subtract(const Duration(days: 1)),
           'endDate': DateTime.now().add(const Duration(days: 6)),
           'targetAmount': 0,
           'typeId': 'plastic',
           'participants': [userId], // Add user immediately
        });
        return;
      }
       if (challengeId == 'c2') {
        await docRef.set({
          'id': 'c2',
          'title': '1000 Ağaç Kampanyası',
          'description': 'Hep birlikte 1000 ağaç dikelim.',
          'startDate': DateTime.now().subtract(const Duration(days: 5)),
          'endDate': DateTime.now().add(const Duration(days: 25)),
          'targetAmount': 1000,
          'typeId': 'tree',
          'participants': [userId], // Add user immediately
        });
        return;
      }
    }

    await docRef.update({
      'participants': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> checkAndAssignBadges(String userId, int totalPoints) async {
    // 1. Get all definitions (simplified for this demo)
    final badges = await getBadges();
    
    // 2. Get user's current badges
    final userBadgesSnap = await _firestore.collection('users').doc(userId).collection('user_badges').get();
    final ownedBadgeIds = userBadgesSnap.docs.map((d) => d.id).toSet();

    // 3. Check each badge
    for (var badge in badges) {
      if (!ownedBadgeIds.contains(badge.id) && totalPoints >= badge.requiredPoints) {
        // Earned!
        await assignBadgeToUser(userId, badge);
      }
    }
  }

  Future<void> assignBadgeToUser(String userId, Badge badge) async {
    // Add badge
    await _firestore.collection('users').doc(userId).collection('user_badges').doc(badge.id).set({
      'badgeId': badge.id,
      'earnedAt': FieldValue.serverTimestamp(),
    });

    // Create Notification
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': 'Yeni Rozet Kazandın! 🏆',
      'body': '"${badge.name}" rozeti profiline eklendi.',
      'type': 'badge',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
