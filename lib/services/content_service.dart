import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Tips ---

  Future<List<Tip>> getDailyTips() async {
    // 1. Define backup tips first (Rich/static content for robustness)
    final List<Tip> staticTips = [
      Tip(id: 't1', title: 'Matara Kullanın', content: 'Plastik şişelerin doğada yok olması 450 yıl sürer. Matara kullanarak bu atığı önleyebilirsiniz!', category: 'plastic', publishDate: DateTime.now()),
      Tip(id: 't2', title: 'Kısa Duş Alın', content: 'Duş sürenizi 1 dakika kısaltmak yılda tonlarca su tasarrufu sağlar.', category: 'water', publishDate: DateTime.now()),
      Tip(id: 't3', title: 'Bez Çanta Taşıyın', content: 'Alışverişe giderken bez çanta kullanmak, plastik poşet kullanımını sıfıra indirir.', category: 'waste', publishDate: DateTime.now()),
      Tip(id: 't4', title: 'Mevsimsel Beslen', content: 'Mevsiminde gıda tüketmek, gıdanın karbon ayak izini düşürür.', category: 'food', publishDate: DateTime.now()),
      Tip(id: 't5', title: 'Elektronik Atıklar', content: 'Eski pillerinizi ve telefonlarınızı çöpe değil, e-atık kutularına atın.', category: 'waste', publishDate: DateTime.now()),
    ];

    List<Tip> allTips = [];

    // 2. Try fetching from Firestore
    try {
      final snapshot = await _firestore.collection('tips').get();
      if (snapshot.docs.isNotEmpty) {
        allTips = snapshot.docs.map((doc) => Tip.fromMap(doc.data())).toList();
      }
    } catch (e) {
      print("Error fetching tips: $e");
    }

    // 3. Merge or fallback
    if (allTips.isEmpty) {
      allTips = staticTips;
    } else {
      // Optional: Add static tips if DB has too few, or just use DB
      if (allTips.length < 5) allTips.addAll(staticTips);
    }

    // 4. Deterministic Selection
    final dayOfYear = int.parse("${DateTime.now().year}${DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1}"); 
    // Simplified: Just use day of year
    final index = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays % allTips.length;
    
    // Return list with the "Daily" tip at index 0
    final dailyTip = allTips[index];
    // We remove it and add to front to ensure it's the one displayed as "Daily" by the UI (if UI picks first)
    // Or just return list where 0 is the daily one.
    List<Tip> result = List.from(allTips);
    result.remove(dailyTip);
    result.insert(0, dailyTip);
    
    return result;
  }
}
