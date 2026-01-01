import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all users with pagination
  Future<List<UserModel>> getAllUsers({int limit = 20, DocumentSnapshot? startAfter}) async {
    try {
      Query query = _firestore.collection('users').orderBy('createdAt', descending: true).limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      
      // Note: createdAt might be missing in older docs, so we handle it casually
      // In a real app we might want to ensure createdAt exists.
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback query if createdAt is not available
      final snapshot = await _firestore.collection('users').limit(limit).get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    }
  }

  // Get Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final usersCount = await _firestore.collection('users').count().get();
      final activitiesCount = await _firestore.collection('activities').count().get();
      
      return {
        'totalUsers': usersCount.count,
        'totalActivities': activitiesCount.count,
        // Calculate total points could be expensive, so maybe estimation or aggregate
      };
    } catch (e) {
      print("Error getting stats: $e");
      return {'totalUsers': 0, 'totalActivities': 0};
    }
  }

  // Get All Activities for Admin (with user details ideally, but for now just activities)
  Future<List<Activity>> getAllActivitiesForAdmin({int limit = 20, DocumentSnapshot? startAfter}) async {
    try {
      Query query = _firestore.collection('activities').orderBy('timestamp', descending: true).limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Activity.fromMap(data);
      }).toList();
    } catch (e) {
      print("Error fetching admin activities: $e");
      return [];
    }
  }
}
