import 'package:cloud_firestore/cloud_firestore.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, int>> getStreakData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final data = userDoc.data();
      
      if (data == null) {
        return {'currentStreak': 0, 'longestStreak': 0};
      }

      return {
        'currentStreak': data['currentStreak'] ?? 0,
        'longestStreak': data['longestStreak'] ?? 0,
      };
    } catch (e) {
      print('Error getting streak data: $e');
      return {'currentStreak': 0, 'longestStreak': 0};
    }
  }

  Future<void> updateStreak(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();
      final data = userDoc.data();

      if (data == null) return;

      final now = DateTime.now();
      final lastActivityTimestamp = data['lastActivityDate'] as Timestamp?;
      final lastActivityDate = lastActivityTimestamp?.toDate();

      int currentStreak = data['currentStreak'] ?? 0;
      int longestStreak = data['longestStreak'] ?? 0;

      if (lastActivityDate == null) {
        // First activity ever
        currentStreak = 1;
      } else {
        final daysDifference = _daysBetween(lastActivityDate, now);

        if (daysDifference == 0) {
          // Same day, no change
          return;
        } else if (daysDifference == 1) {
          // Consecutive day
          currentStreak++;
        } else {
          // Streak broken
          currentStreak = 1;
        }
      }

      // Update longest streak if needed
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }

      // Update Firestore
      await userRef.update({
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActivityDate': FieldValue.serverTimestamp(),
      });

      print('Streak updated: current=$currentStreak, longest=$longestStreak');
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }
}
