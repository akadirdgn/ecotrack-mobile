import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gamification_service.dart';
import '../services/notification_service.dart';

/// Manuel rozet kontrolü ve bildirim gönderme scripti
/// Kullanım: Bir kez çalıştır, mevcut tüm kullanıcılar için rozet kontrolü yapar
class BadgeRetroactiveTrigger {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> checkAllUsersForBadges() async {
    try {
      print('🔄 Starting retroactive badge check...');
      
      // Tüm kullanıcıları al
      final usersSnapshot = await _firestore.collection('users').get();
      
      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final userId = userDoc.id;
        final totalPoints = userData['totalPoints'] ?? 0;
        final displayName = userData['displayName'] ?? 'User';
        
        print('Checking user: $displayName ($totalPoints points)');
        
        // Rozet kontrolü ve otomatik award
        await GamificationService().checkAndAwardBadges(userId, totalPoints);
      }
      
      print('✅ Retroactive badge check completed!');
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}
