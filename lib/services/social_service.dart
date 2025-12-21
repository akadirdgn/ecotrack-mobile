import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class SocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // --- Groups ---

  Future<void> createGroup(String name, String description, String createdBy) async {
    final String id = _uuid.v4();
    final group = Group(
      id: id,
      name: name,
      description: description,
      memberIds: [createdBy],
      totalPoints: 0,
      createdBy: createdBy,
    );
    await _firestore.collection('groups').doc(id).set(group.toMap());
  }

  Future<List<Group>> getGroups() async {
    try {
      final snapshot = await _firestore.collection('groups').get();
       if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList();
      }
    } catch (e) {
       print("Error fetching groups: $e");
    }
    
    // Fallback Mock Groups
    return [
       Group(id: 'g1', name: 'Ofis Çalışanları', description: 'Ofiste sürdürülebilirlik takımı', memberIds: [], totalPoints: 1250, createdBy: 'admin'),
       Group(id: 'g2', name: 'Mahalle Gönüllüleri', description: 'Mahallemizi temiz tutalım', memberIds: [], totalPoints: 850, createdBy: 'admin'),
    ];
  }

  Future<void> joinGroup(String groupId, String userId) async {
    final docRef = _firestore.collection('groups').doc(groupId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Lazy seed for dummy groups
       if (groupId == 'g1') {
         await docRef.set({
           'id': 'g1', 'name': 'Ofis Çalışanları', 'description': 'Ofiste sürdürülebilirlik takımı', 
           'memberIds': [userId], 'totalPoints': 1250, 'createdBy': 'admin'
         });
         return;
       }
       if (groupId == 'g2') {
         await docRef.set({
           'id': 'g2', 'name': 'Mahalle Gönüllüleri', 'description': 'Mahallemizi temiz tutalım', 
           'memberIds': [userId], 'totalPoints': 850, 'createdBy': 'admin'
         });
         return;
       }
    }

    await docRef.update({
      'memberIds': FieldValue.arrayUnion([userId])
    });
  }

  // --- Notifications ---

  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }

    // Fallback Mock Notifications
    return [
      NotificationModel(id: 'n1', userId: userId, title: 'Rozet Kazandın!', body: 'Doğa Dostu rozeti profilinize eklendi.', type: 'badge', isRead: false, createdAt: DateTime.now()),
      NotificationModel(id: 'n2', userId: userId, title: 'Yeni Meydan Okuma', body: 'Haftalık plastik diyetine katıl.', type: 'challenge', isRead: true, createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    ];
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  // --- Reporting ---

  Future<void> reportContent({
    required String targetId,
    required String targetType, // 'activity', 'comment'
    required String reporterId,
    required String reason,
  }) async {
    final String id = _uuid.v4();
    final report = Report(
      id: id,
      targetId: targetId,
      targetType: targetType,
      reporterId: reporterId,
      reason: reason,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    // Note: We use toMap() but handle DateTime inside it
    await _firestore.collection('reports').doc(id).set({
      ...report.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
