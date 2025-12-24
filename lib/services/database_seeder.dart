import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class DatabaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seed() async {
    print("🌱 Starting database seeding...");

    await _seedActivityTypes();
    await _seedBadges();
    await _seedEcoSpots();
    await _seedChallenges();
    await _seedTips();

    print("✅ Database seeding completed!");
  }

  Future<void> _seedActivityTypes() async {
    final types = [
      ActivityType(
        id: 'plastic',
        name: 'Plastik Toplama',
        iconName: 'delete_outline',
        pointsPerUnit: 10,
        unit: 'kg',
      ),
      ActivityType(
        id: 'tree',
        name: 'Ağaç Dikimi',
        iconName: 'park',
        pointsPerUnit: 50,
        unit: 'adet',
      ),
      ActivityType(
        id: 'glass',
        name: 'Cam Geri Dönüşüm',
        iconName: 'wine_bar',
        pointsPerUnit: 8,
        unit: 'kg',
      ),
      ActivityType(
        id: 'paper',
        name: 'Kağıt Geri Dönüşüm',
        iconName: 'description',
        pointsPerUnit: 5,
        unit: 'kg',
      ),
    ];

    for (var type in types) {
      await _firestore.collection('activity_types').doc(type.id).set(type.toMap());
    }
    print("✓ Activity types seeded");
  }

  Future<void> _seedBadges() async {
    final badges = [
      BadgeModel(
        id: 'badge_1',
        name: 'Doğa Dostu',
        iconUrl: 'https://img.icons8.com/color/96/leaf.png',
        requiredPoints: 100,
        category: 'milestone',
        description: 'İlk 100 puanını topla',
      ),
      BadgeModel(
        id: 'badge_2',
        name: 'Geri Dönüşümcü',
        iconUrl: 'https://img.icons8.com/color/96/recycle-sign.png',
        requiredPoints: 500,
        category: 'milestone',
        description: '500 puana ulaş',
      ),
      BadgeModel(
        id: 'badge_3',
        name: 'Ağaç Koruyucu',
        iconUrl: 'https://img.icons8.com/color/96/tree.png',
        requiredPoints: 1000,
        category: 'activity',
        description: '10 ağaç dik',
      ),
      BadgeModel(
        id: 'badge_4',
        name: 'Eko Lider',
        iconUrl: 'https://img.icons8.com/color/96/trophy.png',
        requiredPoints: 5000,
        category: 'milestone',
        description: '5000 puana ulaş',
      ),
      BadgeModel(
        id: 'badge_5',
        name: 'Plastik Avcısı',
        iconUrl: 'https://img.icons8.com/color/96/waste.png',
        requiredPoints: 300,
        category: 'activity',
        description: '50kg plastik topla',
      ),
    ];

    for (var badge in badges) {
      await _firestore.collection('badges').doc(badge.id).set(badge.toMap());
    }
    print("✓ Badges seeded");
  }

  Future<void> _seedEcoSpots() async {
    final spots = [
      // Parks (existing orange markers)
      EcoSpot(
        id: 'spot_1',
        name: 'Hürriyet Parkı',
        type: 'tree',
        latitude: 38.3552,
        longitude: 38.3095,
        description: 'Yeşil alan ve dinlenme alanı',
        address: 'Merkez, Malatya',
      ),
      EcoSpot(
        id: 'spot_2',
        name: 'Sümer Park',
        type: 'tree',
        latitude: 38.3430,
        longitude: 38.3140,
        description: 'Aile piknik alanı ve yürüyüş parkuru',
        address: 'Merkez, Malatya',
      ),
      EcoSpot(
        id: 'spot_3',
        name: 'Orduzu Pınarbaşı',
        type: 'water',
        latitude: 38.3300,
        longitude: 38.3500,
        description: 'Doğal kaynak suyu - Ücretsiz temiz içme suyu',
        address: 'Orduzu, Malatya',
      ),
      EcoSpot(
        id: 'spot_4',
        name: 'Beydağı Ormanı',
        type: 'tree',
        latitude: 38.4000,
        longitude: 38.2500,
        description: 'Doğa yürüyüşü ve kamp alanı',
        address: 'Beydağı, Malatya',
      ),
      
      // Recycle Centers
      EcoSpot(
        id: 'spot_5',
        name: 'Battalgazi Geri Dönüşüm Merkezi',
        type: 'recycle',
        latitude: 38.3552,
        longitude: 38.2249,
        description: 'Plastik, cam ve kağıt geri dönüşümü',
        address: 'Battalgazi, Malatya',
      ),
      EcoSpot(
        id: 'spot_6',
        name: 'Yeşilyurt Geri Dönüşüm İstasyonu',
        type: 'recycle',
        latitude: 38.3282,
        longitude: 38.2795,
        description: 'Elektronik atık ve pil toplama noktası',
        address: 'Yeşilyurt, Malatya',
      ),
      
      // Water Points
      EcoSpot(
        id: 'spot_7',
        name: 'İnönü Üniversitesi Temiz Su',
        type: 'water',
        latitude: 38.3187,
        longitude: 38.3348,
        description: 'Kampüs içi içme suyu noktası - Matara doldurun',
        address: 'İnönü Üniversitesi, Malatya',
      ),
      EcoSpot(
        id: 'spot_8',
        name: 'Kernek Barajı Piknik',
        type: 'tree',
        latitude: 38.4000,
        longitude: 38.2500,
        description: 'Doğa manzaralı piknik ve dinlenme alanı',
        address: 'Kernek, Malatya',
      ),
    ];

    for (var spot in spots) {
      await _firestore.collection('eco_spots').doc(spot.id).set(spot.toMap());
    }
    print("✓ Eco spots seeded");
  }

  Future<void> _seedChallenges() async {
    final challenges = [
      Challenge(
        id: 'ch_1',
        title: '30 Günde 10 Aktivite',
        description: 'Bir ay içinde 10 farklı eko aktivite yap ve 500 puan kazan!',
        targetAmount: 10,
        typeId: 'general',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        participants: [],
      ),
      Challenge(
        id: 'ch_2',
        title: 'Plastik Savaşçısı',
        description: 'Bu hafta 20kg plastik topla',
        targetAmount: 20,
        typeId: 'plastic',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        participants: [],
      ),
    ];

    for (var challenge in challenges) {
      await _firestore.collection('challenges').doc(challenge.id).set(challenge.toMap());
    }

    print("✅ Challenges seeded");
  }

  Future<void> _seedTips() async {
    final tips = [
      TipModel(
        id: 'tip_1',
        title: 'Matara Kullanın',
        content: 'Plastik şişelerin doğada yok olması 450 yıl sürer. Matara kullanarak bu atığı önleyebilirsiniz!',
        iconEmoji: '💡',
        date: DateTime.now(),
        isActive: true,
      ),
      TipModel(
        id: 'tip_2',
        title: 'Bez Çanta Tercih Edin',
        content: 'Tek kullanımlık poşetler yerine bez çanta kullanarak yılda 150+ poşet tasarrufu yapabilirsiniz.',
        iconEmoji: '🛍️',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isActive: false,
      ),
      TipModel(
        id: 'tip_3',
        title: 'LED Ampul',
        content: 'LED ampuller %75 daha az enerji tüketir ve 25 kat daha uzun ömürlüdür. Hem para hem enerji tasarrufu!',
        iconEmoji: '💡',
        date: DateTime.now().subtract(const Duration(days: 2)),
        isActive: false,
      ),
      TipModel(
        id: 'tip_4',
        title: 'Geri Dönüşüm',
        content: '1 ton kağıt geri dönüştürmek 17 ağacı kurtarır. Atıklarınızı ayrıştırın!',
        iconEmoji: '♻️',
        date: DateTime.now().subtract(const Duration(days: 3)),
        isActive: false,
      ),
      TipModel(
        id: 'tip_5',
        title: 'Toplu Taşıma',
        content: 'Araba yerine toplu taşıma kullanarak kişi başı CO2 emisyonunu %45 azaltabilirsiniz.',
        iconEmoji: '🚌',
        date: DateTime.now().subtract(const Duration(days: 4)),
        isActive: false,
      ),
    ];

    for (var tip in tips) {
      await _firestore.collection('tips').doc(tip.id).set(tip.toMap());
    }

    print("✅ Tips seeded");
  }
}
