import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../models/badge_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  /// Generic notification sender
  Future<void> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        body: message,
        type: type,
        isRead: false,
        createdAt: DateTime.now(),
        data: data,
      );

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      print('✅ Notification sent: $type to user $userId');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Welcome notification for new users
  Future<void> sendWelcomeNotification(String userId, String userName) async {
    await sendNotification(
      userId: userId,
      type: 'welcome',
      title: 'Hoş Geldin!',
      message: 'Hoş geldin $userName! EcoTrack\'e katıldığın için teşekkürler 🌱',
    );
  }

  /// Badge earned notification
  Future<void> sendBadgeEarnedNotification(String userId, BadgeModel badge) async {
    await sendNotification(
      userId: userId,
      type: 'badge_earned',
      title: 'Rozet Kazandın!',
      message: 'Tebrikler! \'${badge.name}\' rozetini kazandın 🏆',
      data: {'badgeId': badge.id, 'badgeName': badge.name},
    );
  }

  /// Challenge completed notification
  Future<void> sendChallengeCompletedNotification(
    String userId,
    String challengeId,
    String challengeName,
  ) async {
    await sendNotification(
      userId: userId,
      type: 'challenge_completed',
      title: 'Meydan Okuma Tamamlandı!',
      message: 'Harika! \'$challengeName\' meydan okumasını tamamladın 🔥',
      data: {'challengeId': challengeId},
    );
  }

  /// Milestone notification (100, 500, 1000, 5000 points)
  Future<void> sendMilestoneNotification(String userId, int points) async {
    String emoji;
    switch (points) {
      case 100:
        emoji = '🎉';
        break;
      case 500:
        emoji = '🌟';
        break;
      case 1000:
        emoji = '💪';
        break;
      case 5000:
        emoji = '👑';
        break;
      default:
        emoji = '⭐';
    }

    await sendNotification(
      userId: userId,
      type: 'milestone',
      title: 'Yeni Hedef!',
      message: '$points puana ulaştın! Devam et $emoji',
      data: {'points': points},
    );
  }

  /// Weekly summary notification
  Future<void> sendWeeklySummaryNotification(
    String userId,
    int activityCount,
    int totalPoints,
  ) async {
    await sendNotification(
      userId: userId,
      type: 'weekly_summary',
      title: 'Haftalık Özet',
      message: 'Bu hafta $activityCount aktivite yaptın ve $totalPoints puan kazandın! 📊',
      data: {
        'activityCount': activityCount,
        'totalPoints': totalPoints,
      },
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Get unread count for a user
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
