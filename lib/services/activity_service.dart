import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

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
    
    final activityData = {
      'id': activityId,
      'userId': userId,
      'typeId': typeId,
      'description': description,
      'photoId': photoUrl,
      'locationId': 'mock_location_id',
      'timestamp': FieldValue.serverTimestamp(),
      'pointsEarned': pointsEarned,
      'amount': amount,
      'status': 'verified', 
      'latitude': latitude,
      'longitude': longitude,
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
        else if (typeId == 'glass') {
           updateData['co2Saved'] = FieldValue.increment(amount * 0.5);
        }

        transaction.update(userDoc, updateData);
      });
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
}
