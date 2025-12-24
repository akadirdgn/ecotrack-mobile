import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_model.dart';
import '../models/badge_model.dart';
import '../models/user_badge_model.dart';
import 'notification_service.dart';

class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Badge Methods
  Future<List<BadgeModel>> getAllBadges() async {
    try {
      final snapshot = await _firestore.collection('badges').get();
      return snapshot.docs
          .map((doc) => BadgeModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching badges: $e");
      return [];
    }
  }

  Future<BadgeModel?> getBadgeById(String badgeId) async {
    try {
      final doc = await _firestore.collection('badges').doc(badgeId).get();
      if (doc.exists) {
        return BadgeModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching badge: $e");
      return null;
    }
  }

  Future<List<String>> getUserBadgeIds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_badges')
          .where('userId', isEqualTo: userId)
          .get();
      
      return snapshot.docs
          .map((doc) => doc.data()['badgeId'] as String)
          .toList();
    } catch (e) {
      print("Error fetching user badges: $e");
      return [];
    }
  }

  Future<void> awardBadge(String userId, String badgeId) async {
    try {
      // Check if already earned
      final earnedIds = await getUserBadgeIds(userId);
      if (earnedIds.contains(badgeId)) {
        print("Badge already awarded: $badgeId");
        return;
      }

      final userBadge = UserBadge(
        userId: userId,
        badgeId: badgeId,
        earnedAt: DateTime.now(),
      );
      
      await _firestore.collection('user_badges').add(userBadge.toMap());

      // Send notification 🏆
      final badge = await getBadgeById(badgeId);
      if (badge != null) {
        await NotificationService().sendBadgeEarnedNotification(userId, badge);
      }
    } catch (e) {
      print("Error awarding badge: $e");
    }
  }

  // Auto-check and award badges based on points
  Future<void> checkAndAwardBadges(String userId, int currentPoints) async {
    try {
      final allBadges = await getAllBadges();
      final earnedIds = await getUserBadgeIds(userId);

      for (var badge in allBadges) {
        if (!earnedIds.contains(badge.id) && currentPoints >= badge.requiredPoints) {
          await awardBadge(userId, badge.id);
        }
      }
    } catch (e) {
      print("Error checking badges: $e");
    }
  }

  // Challenge Methods

  Future<List<Challenge>> getActiveChallenges() async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .where('endDate', isGreaterThan: DateTime.now())
          .get();
      
      return snapshot.docs.map((doc) => Challenge.fromMap(doc.data())).toList();
    } catch (e) {
      print("Error fetching challenges: $e");
      return [];
    }
  }

  Future<void> joinChallenge(String challengeId, String userId) async {
    try {
      await _firestore.collection('challenges').doc(challengeId).update({
        'participants': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
       print("Error joining challenge: $e");
    }
  }
}
