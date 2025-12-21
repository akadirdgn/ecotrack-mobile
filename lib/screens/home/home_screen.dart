import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../map/map_screen.dart';
import '../camera/camera_screen.dart';
import '../profile/profile_screen.dart';
import '../feed/feed_screen.dart';
import '../../services/social_service.dart'; // New Import
import '../../services/map_state.dart'; // New Import
import '../../models/models.dart'; // New Import

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
          StreamBuilder<List<NotificationModel>>(
            stream: Stream.fromFuture(SocialService().getUserNotifications('mock_user_id')), // Mock ID or Provider User ID
            builder: (context, snapshot) {
              final hasUnread = snapshot.data?.any((n) => !n.isRead) ?? false;
              return Stack(
                children: [
                   IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      // Show specific notification dialog or screen
                      showDialog(
                        context: context, 
                        builder: (c) => AlertDialog(
                          title: const Text("Bildirimler"),
                          content: SizedBox(
                            width: double.maxFinite,
                            height: 300,
                            child: ListView(
                              children: snapshot.data?.map((n) => ListTile(
                                leading: Icon(n.type == 'badge' ? Icons.military_tech : Icons.info, color: Colors.blue),
                                title: Text(n.title), 
                                subtitle: Text(n.body),
                                trailing: n.isRead ? null : const Icon(Icons.circle, color: Colors.red, size: 8),
                              )).toList() ?? const [Text("Bildirim yok")],
                            ),
                          ),
                          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Kapat"))],
                        )
                      );
                    },
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      ),
                    )
                ],
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
