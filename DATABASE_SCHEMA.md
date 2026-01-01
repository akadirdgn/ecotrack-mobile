# EcoTrack Database - ER Diagram (Mermaid)

```mermaid
erDiagram
    USERS ||--o{ ACTIVITIES : creates
    USERS ||--o{ USER_BADGES : earns
    USERS ||--o{ LIKES : gives
    USERS ||--o{ COMMENTS : writes
    USERS }o--o{ GROUPS : "joins"
    USERS }o--o{ CHALLENGES : participates
    USERS ||--o| ADMINS : "can_be"
    
    ACTIVITIES ||--o{ LIKES : receives
    ACTIVITIES ||--o{ COMMENTS : has
    ACTIVITIES }o--|| ACTIVITY_TYPES : "of_type"
    
    BADGES ||--o{ USER_BADGES : "awarded_as"
    
    USERS {
        string uid PK
        string email
        string displayName
        int totalPoints
        int activityCount
        timestamp createdAt
        int currentStreak
        int longestStreak
        timestamp lastActivityDate
        string[] groupIds
    }
    
    ADMINS {
        string uid PK
        string role
        timestamp createdAt
    }
    
    ACTIVITIES {
        string id PK
        string userId FK
        string typeId FK
        double amount
        int pointsEarned
        string description
        string photoId
        double latitude
        double longitude
        timestamp timestamp
    }
    
    ACTIVITY_TYPES {
        string id PK
        string name
        string iconName
        int pointsPerUnit
    }
    
    BADGES {
        string id PK
        string name
        string description
        string iconName
        int requiredPoints
        timestamp createdAt
    }
    
    USER_BADGES {
        string id PK
        string userId FK
        string badgeId FK
        timestamp earnedAt
    }
    
    GROUPS {
        string id PK
        string name
        string description
        string[] memberIds
        int totalPoints
        timestamp createdAt
    }
    
    LIKES {
        string id PK
        string activityId FK
        string userId FK
        timestamp createdAt
    }
    
    COMMENTS {
        string id PK
        string activityId FK
        string userId FK
        string userName
        string text
        timestamp createdAt
    }
    
    CHALLENGES {
        string id PK
        string title
        string description
        timestamp startDate
        timestamp endDate
        string[] participants
        int targetAmount
    }
    
    TIPS {
        string id PK
        string title
        string content
        string iconEmoji
        boolean isActive
        timestamp createdAt
    }
    
    NOTIFICATIONS {
        string id PK
        string userId FK
        string type
        string message
        boolean isRead
        timestamp createdAt
    }
```

## Tablo Açıklamaları

### 1. USERS (Kullanıcılar)
- **Amaç:** Tüm kullanıcı bilgilerini tutar
- **Önemli:** Streak (ardışık gün) bilgileri de burada
- **İlişkiler:** Tüm aktivitelerin, yorumların, beğenilerin sahibi

### 2. ADMINS (Yöneticiler)
- **Amaç:** Admin yetkilerine sahip kullanıcıları tanımlar
- **Özellik:** Rol bazlı yetkilendirme (role: "admin", "super_admin")
- **İlişki:** Bir kullanıcı admin olabilir (opsiyonel)
- **Kullanım:** Admin panelinde kullanıcı ve gönderi yönetimi

### 3. ACTIVITIES (Aktiviteler)
- **Amaç:** Kullanıcıların gerçekleştirdiği eko aktiviteleri
- **Native Özellik:** GPS konumu (latitude/longitude) ve kamera (photoId)
- **İlişkiler:** Bir kullanıcıya ve bir aktivite tipine ait

### 4. ACTIVITY_TYPES (Aktivite Tipleri)
- **Amaç:** Plastik toplama, ağaç dikimi, cam geri dönüşüm gibi tipler
- **Özellik:** Her tip için puan hesaplama (pointsPerUnit)

### 5. BADGES (Rozetler)
- **Amaç:** Başarı rozetleri tanımı
- **Gamification:** Kullanıcı motivasyonu için

### 6. USER_BADGES (Kullanıcı Rozetleri)
- **Amaç:** Hangi kullanıcının hangi rozeti kazandığını takip
- **İlişki Tablosu:** USERS ↔ BADGES many-to-many ilişkisi

### 7. GROUPS (Topluluklar)
- **Amaç:** Kullanıcı grupları/topluluklar
- **Özellik:** Grup toplam puanı ve üye listesi

### 8. LIKES (Beğeniler)
- **Amaç:** Aktivitelere yapılan beğeniler
- **İlişki:** Bir kullanıcı bir aktiviteyi beğenir

### 9. COMMENTS (Yorumlar)
- **Amaç:** Aktivitelere yapılan yorumlar
- **Özellik:** Kullanıcılar kendi yorumlarını silebilir

### 10. CHALLENGES (Meydan Okumalar)
- **Amaç:** Zaman sınırlı toplu görevler
- **Özellik:** Başlangıç/bitiş tarihi ve katılımcılar

### 11. TIPS (İpuçları)
- **Amaç:** Günlük çevre ipuçları
- **Özellik:** Aktif/pasif durumu (isActive)

### 12. NOTIFICATIONS (Bildirimler)
- **Amaç:** Kullanıcı bildirimleri
- **Özellik:** Okundu/okunmadı durumu

## Normalizasyon
- ✅ 1NF: Tüm alanlar atomic değerler içerir
- ✅ 2NF: Primary key'e bağımlılık sağlanmış
- ✅ 3NF: Transitif bağımlılık yok
- ✅ İlişki tabloları kullanılmış (USER_BADGES)
- ✅ Foreign Key referansları tanımlı

## Native Modüller
- 📷 **Kamera:** ACTIVITIES tablosunda `photoId` alanı
- 📍 **GPS/Harita:** ACTIVITIES tablosunda `latitude` ve `longitude` alanları
