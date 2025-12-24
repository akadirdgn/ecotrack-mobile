import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/eco_spot_model.dart';

class MapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<EcoSpot>> getEcoSpots() async {
    try {
      final snapshot = await _firestore.collection('eco_spots').get();
      return snapshot.docs
          .map((doc) => EcoSpot.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching eco spots: $e");
      return [];
    }
  }

  Future<List<EcoSpot>> getEcoSpotsByType(String type) async {
    try {
      final snapshot = await _firestore
          .collection('eco_spots')
          .where('type', isEqualTo: type)
          .get();
      
      return snapshot.docs
          .map((doc) => EcoSpot.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching eco spots by type: $e");
      return [];
    }
  }
}
