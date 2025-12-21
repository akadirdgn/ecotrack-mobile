# 🌿 EcoTrack Mobile App

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Google Maps](https://img.shields.io/badge/Google_Maps-4285F4?style=for-the-badge&logo=google-maps&logoColor=white)

> **Track your eco-impact, compete with friends, and save the planet—one activity at a time.** 🌍

**EcoTrack** is a cross-platform mobile application developed with **Flutter** that empowers users to log their environmentally friendly activities. Whether it's planting trees 🌳, collecting plastic ♻️, or recycling glass 🍾, EcoTrack gamifies the experience with points, badges, and a social feed.

---

## 🚀 Key Features

### 📸 **Snap & Share**
- Capture your eco-activities using the **integrated Camera module**.
- Automatically captures **Geolocation (GPS)** data for verified impact.

### 🗺️ **Interactive Map**
- View verified activities on a **Google Map**.
- See where others are making a difference around you.

### 🤝 **Social Community**
- **Social Feed:** Scroll through a real-time timeline of user activities.
- **Likes & Comments:** Interact with the community! Like posts ❤️ and leave comments 💬 using our robust backend system.
- **Profiles:** Check out other users' stats and badges.

### 🏆 **Gamification & Stats**
- **Earn Points:** Get rewarded for every verified activity.
- **Badges:** Unlock levels like *Bronze*, *Silver*, and *Gold*.
- **Impact Stats:** Track exactly how much **CO2 you've saved**, **Plastic you've collected**, and **Trees you've planted**.

---

## 🛠️ Technology Stack

*   **Frontend:** Flutter (Dart)
*   **Backend:** Firebase (Firestore, Auth, Storage)
*   **Maps:** Google Maps Flutter SDK
*   **Hardware Access:** Camera, Geolocator, Permissions Handler
*   **State Management:** Provider

---

## 💾 Data Model

The application is built on a robust **NoSQL** architecture with **10 Data Models**, fully integrated:

1.  **Users:** Stores profiles, compiled stats (points, CO2 saved), and badging info.
2.  **Activities:** Main entity linking users, types, locations, and photos.
3.  **ActivityTypes:** Categorization (Plastic, Tree, Glass, etc.).
4.  **ActivityLocation:** Geospatial data.
5.  **Photos:** Metadata for evidence images.
6.  **Badges:** Achievement definitions.
7.  **UserBadges:** Many-to-many relation for earned achievements.
8.  **Comments:** Social interaction data (with username denormalization).
9.  **Likes:** Social interaction tracking.
10. **ImpactStats:** Detailed breakdown of user contributions.

---

## 📸 Screenshots

| Home & Feed | Add Activity | Profile & Stats |
|:---:|:---:|:---:|
| <img src="https://via.placeholder.com/300x600?text=Feed" width="200"> | <img src="https://via.placeholder.com/300x600?text=Camera" width="200"> | <img src="https://via.placeholder.com/300x600?text=Profile" width="200"> |

---

## 🏁 Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/akadirdgn/ecotrack-mobile.git
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Firebase Setup:**
    - Place your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the respective folders.
4.  **Run the app:**
    ```bash
    flutter run
    ```

---

