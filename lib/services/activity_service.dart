import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/activity_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';
import '../models/like_model.dart';
import '../models/activity_type_model.dart';
import 'notification_service.dart';
import 'gamification_service.dart';
import 'streak_service.dart';



class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Activities collection reference
  CollectionReference get _activitiesRef => _firestore.collection('activities');
  CollectionReference get _usersRef => _firestore.collection('users');

  Future<void> addActivity({
    required String userId,
    required String typeId,
    required String description,
    required String photoUrl, 
    required int pointsEarned,
    required double amount, // e.g. kg or count
    required double? latitude,
    required double? longitude,
  }) async {
    String activityId = _uuid.v4();
    
    // Create Activity Object
    // Note: In a real app we'd upload photo to storage here and get URL
    
    final activity = Activity(
      id: activityId,
      userId: userId,
      typeId: typeId,
      description: description,
      photoId: photoUrl,
      locationId: 'mock_location_id',
      timestamp: DateTime.now(),
      pointsEarned: pointsEarned,
      amount: amount,
      status: 'verified',
      latitude: latitude,
      longitude: longitude,
    );
    
    // Use toMap from the model (Manual map removed)
    final activityData = {
        'id': activity.id,
        'userId': activity.userId,
        'typeId': activity.typeId,
        'description': activity.description,
        'photoId': activity.photoId,
        'locationId': activity.locationId,
        'timestamp': FieldValue.serverTimestamp(), // Override for server time
        'pointsEarned': activity.pointsEarned,
        'amount': activity.amount,
        'status': activity.status,
        'latitude': activity.latitude,
        'longitude': activity.longitude,
    };

    try {
      // Run as a transaction to ensure points added only if activity saved
      await _firestore.runTransaction((transaction) async {
        // 1. Save Activity
         transaction.set(_activitiesRef.doc(activityId), activityData);
        
        // 2. Update User Points and Stats
        DocumentReference userDoc = _usersRef.doc(userId);
        
        Map<String, dynamic> updateData = {
          'totalPoints': FieldValue.increment(pointsEarned),
          'activityCount': FieldValue.increment(1),
        };

        // Logic for specific stats
        // Plastic: 1kg saves ~2kg CO2
        if (typeId == 'plastic') {
           updateData['plasticCollected'] = FieldValue.increment(amount); 
           updateData['co2Saved'] = FieldValue.increment(amount * 2.0);
        } 
        // Tree: 1 tree absorbs ~20kg CO2/year
        else if (typeId == 'tree') {
           updateData['treesPlanted'] = FieldValue.increment(amount.toInt());
           updateData['co2Saved'] = FieldValue.increment(amount * 10.0);
        }
        if (typeId == 'glass') {
           updateData['co2Saved'] = FieldValue.increment(amount * 0.5);
        }

        transaction.update(userDoc, updateData);
      });
      
      // After transaction: Update streak, send notifications, and check badges
      try {
        // Update daily streak
        await StreakService().updateStreak(userId);
        
        // Get updated user points
        final userSnapshot = await _usersRef.doc(userId).get();
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final totalPoints = userData['totalPoints'] ?? 0;

        // Milestone notifications (100, 500, 1000, 5000)
        final milestones = [100, 500, 1000, 5000];
        for (var milestone in milestones) {
          if (totalPoints >= milestone && (totalPoints - pointsEarned) < milestone) {
            await NotificationService().sendMilestoneNotification(userId, milestone);
          }
        }

        // Auto-check and award badges 🏆
        await GamificationService().checkAndAwardBadges(userId, totalPoints);
      } catch (e) {
        print("Error sending notifications: $e");
      }

      print("Activity Added and Points Updated");
    } catch (e) {
      print("Error adding activity: $e");
      rethrow;
    }
  }
  // Likes
  Future<void> toggleLike(String activityId, String userId) async {
    final likeRef = _firestore.collection('likes').doc('${activityId}_$userId');
    
    final doc = await likeRef.get();
    if (doc.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({
        'activityId': activityId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<bool> isLiked(String activityId, String userId) {
    return _firestore.collection('likes').doc('${activityId}_$userId').snapshots().map((doc) => doc.exists);
  }

  Stream<int> getLikeCount(String activityId) {
    return _firestore.collection('likes').where('activityId', isEqualTo: activityId).snapshots().map((snap) => snap.docs.length);
  }

  // Comments
  Future<void> addComment(String activityId, String userId, String userName, String text) async {
    String commentId = _uuid.v4();
    await _firestore.collection('comments').doc(commentId).set({
      'id': commentId,
      'activityId': activityId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore.collection('comments').doc(commentId).delete();
      print("Comment deleted: $commentId");
    } catch (e) {
      print("Error deleting comment: $e");
      rethrow;
    }
  }

  Stream<List<Comment>> getComments(String activityId) {
    return _firestore
        .collection('comments')
        .where('activityId', isEqualTo: activityId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Comment(
                id: data['id'],
                activityId: data['activityId'],
                userId: data['userId'],
                userName: data['userName'] ?? 'Kullanıcı', // Fallback
                text: data['text'],
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              );
            }).toList());
  }

  
  // Connect to Gamification Logic
  Future<void> _checkGamification(String userId, int newTotalPoints) async {
    // We import the service dynamically or pass it to avoid circular deps if needed, 
    // but here direct usage is fine as they are effectively separate modules for now.
    // However, to keep it clean, let's just use the GamificationService class.
    // Note: Verify imports in file header.
    // Simple fire and forget or await.
    // We need to import it.
  }

  // Activity Types - Dynamic Fetching
  static List<ActivityType>? _activityTypesCache;

  Future<List<ActivityType>> getActivityTypes() async {
    if (_activityTypesCache != null) return _activityTypesCache!;
    
    try {
      final snapshot = await _firestore.collection('activity_types').get();
      _activityTypesCache = snapshot.docs
          .map((doc) => ActivityType.fromMap(doc.data()))
          .toList();
      return _activityTypesCache!;
    } catch (e) {
      print("Error fetching activity types: $e");
      return [];
    }
  }

  Future<ActivityType?> getActivityTypeById(String id) async {
    try {
      final doc = await _firestore.collection('activity_types').doc(id).get();
      if (doc.exists) {
        return ActivityType.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching activity type: $e");
      return null;
    }
  }

  // Deletion Logic
  Future<void> deleteActivity(String activityId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final activityRef = _activitiesRef.doc(activityId);
        final activitySnapshot = await transaction.get(activityRef);

        if (!activitySnapshot.exists) {
          throw Exception("Activity does not exist!");
        }

        final activityData = activitySnapshot.data() as Map<String, dynamic>;
        final userId = activityData['userId'];
        final pointsEarned = activityData['pointsEarned'] ?? 0;
        final typeId = activityData['typeId'];
        final amount = activityData['amount'] ?? 0.0;

        // 1. Delete Activity
        transaction.delete(activityRef);

        // 2. Decrement User Stats
        final userRef = _usersRef.doc(userId);
        Map<String, dynamic> updateData = {
          'totalPoints': FieldValue.increment(-pointsEarned),
          'activityCount': FieldValue.increment(-1),
        };

        if (typeId == 'plastic') {
           updateData['plasticCollected'] = FieldValue.increment(-amount); 
           updateData['co2Saved'] = FieldValue.increment(-(amount * 2.0));
        } else if (typeId == 'tree') {
           updateData['treesPlanted'] = FieldValue.increment(-(amount.toInt()));
           updateData['co2Saved'] = FieldValue.increment(-(amount * 10.0));
        }
        if (typeId == 'glass') {
           updateData['co2Saved'] = FieldValue.increment(-(amount * 0.5));
        }

        transaction.update(userRef, updateData);
      });
      
      print("Activity Deleted: $activityId");
    } catch (e) {
      print("Error deleting activity: $e");
      rethrow;
    }
  }
}
