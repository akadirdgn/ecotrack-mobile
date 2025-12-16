import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../map/map_screen.dart';
import '../camera/camera_screen.dart';
import '../profile/profile_screen.dart';
import '../feed/feed_screen.dart';
// import '../camera/camera_screen.dart';

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

    return Scaffold(
      extendBody: true, // For transparency behind nav bar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: _openProfile,
        ),
        title: const Text("EcoTrack"),
        actions: [
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
