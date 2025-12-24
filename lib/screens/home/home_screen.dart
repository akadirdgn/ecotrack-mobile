import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../map/map_screen.dart';
import '../camera/camera_screen.dart';
import '../profile/profile_screen.dart';
import '../feed/feed_screen.dart';
import '../../services/social_service.dart'; // New Import
import '../../services/map_state.dart'; // New Import
import '../../models/user_model.dart';
import '../../models/activity_model.dart';
import '../../models/notification_model.dart';
import '../../models/challenge_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(), // Feed
    const MapScreen(), // Map
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openCamera() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen()));
  }
  
  void _openProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Listen to MapState for navigation requests
    final mapState = Provider.of<MapState>(context);
    if (mapState.targetLocation != null && _currentIndex != 1) {
       // Defer state update to avoid build conflicts
       Future.microtask(() => setState(() => _currentIndex = 1));
    }

    return Scaffold(
      extendBody: true, // For transparency behind nav bar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: _openProfile,
        ),
        title: const Text("EcoTrack"),
        actions: [
          // Notifications Icon
          Consumer<AuthService>(
            builder: (context, authService, _) {
              final userId = authService.user?.uid ?? '';
              if (userId.isEmpty) return const SizedBox();

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('userId', isEqualTo: userId)
                    .orderBy('createdAt', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    );
                  }

                  final notifications = snapshot.data!.docs
                      .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
                      .toList();
                  final hasUnread = notifications.any((n) => !n.isRead);

                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text("Bildirimler"),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: 400,
                                child: notifications.isEmpty
                                    ? const Center(child: Text("Henüz bildirim yok"))
                                    : ListView.separated(
                                        itemCount: notifications.length,
                                        separatorBuilder: (_, __) => const Divider(),
                                        itemBuilder: (context, index) {
                                          final notif = notifications[index];
                                          IconData icon;
                                          Color color;

                                          switch (notif.type) {
                                            case 'welcome':
                                              icon = Icons.celebration;
                                              color = Colors.green;
                                              break;
                                            case 'badge_earned':
                                              icon = Icons.workspace_premium;
                                              color = Colors.amber;
                                              break;
                                            case 'milestone':
                                              icon = Icons.star;
                                              color = Colors.yellow;
                                              break;
                                            case 'challenge_completed':
                                              icon = Icons.local_fire_department;
                                              color = Colors.orange;
                                              break;
                                            default:
                                              icon = Icons.notifications;
                                              color = Colors.blue;
                                          }

                                          return ListTile(
                                            leading: Icon(icon, color: color),
                                            title: Text(
                                              notif.title,
                                              style: TextStyle(
                                                fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(notif.body),
                                            trailing: notif.isRead
                                                ? null
                                                : const Icon(Icons.circle, color: Colors.red, size: 8),
                                          );
                                        },
                                      ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c),
                                  child: const Text("Kapat"),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      if (hasUnread)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => authService.signOut(),
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Theme.of(context).cardColor.withOpacity(0.95),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: _currentIndex == 0 ? Theme.of(context).primaryColor : Colors.grey),
                onPressed: () => _onTabTapped(0),
              ),
              const SizedBox(width: 32), // Spacer for FAB
              IconButton(
                icon: Icon(Icons.map, color: _currentIndex == 1 ? Theme.of(context).primaryColor : Colors.grey),
                onPressed: () => _onTabTapped(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
