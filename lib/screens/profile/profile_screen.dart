import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(user.displayName),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF064E3B), Color(0xFF111827)],
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    child: Text(
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Stats Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(context, "Puan", "${user.totalPoints}"),
                          _buildStatItem(context, "Aktivite", "${user.activityCount}"),

                          _buildStatItem(context, "Seviye", _getBadgeName(user.activityCount)), 

                        ],
                      ),
                    ),
                  ),

                  // Badge Display (New Requirement)
                  // if (user.activityCount >= 10)
                     Container(
                       margin: const EdgeInsets.only(top: 16),
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(
                            color: _getBadgeColor(user.activityCount).withOpacity(0.5),
                            width: 2
                         )
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.military_tech, color: _getBadgeColor(user.activityCount), size: 32),
                           const SizedBox(width: 12),
                           Text(
                             "${_getBadgeName(user.activityCount)} Rozeti Sahibi",
                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                           )
                         ],
                       ),
                     ),
                  const SizedBox(height: 24),
                  
                  Text("Etki İstatistikleri", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  
                  // Mock Impact Stats from Data Model requirement
                  _buildImpactTile(context, Icons.delete_outline, "Toplanan Plastik", "${user.plasticCollected} kg"),
                  _buildImpactTile(context, Icons.park, "Dikilen Ağaç", "${user.treesPlanted}"),
                  _buildImpactTile(context, Icons.co2, "Karbon Tasarrufu", "${user.co2Saved} kg"),
                  
                  const SizedBox(height: 24),
                  
                  // Settings / Account Actions
                  Text("Hesap", style: Theme.of(context).textTheme.titleLarge),

                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white70),
                    title: const Text("Ayarlar"),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text("Çıkış Yap", style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      // Fix for infinite loading loop
                      // Pop the profile screen FIRST, then sign out
                      Navigator.pop(context); 
                      await authService.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildImpactTile(BuildContext context, IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white.withOpacity(0.05),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
      ),
    );
  }


  String _getBadgeName(int count) {
    if (count >= 100) return "Elmas";
    if (count >= 50) return "Altın";
    if (count >= 10) return "Gümüş";
    return "Bronz";
  }

  Color _getBadgeColor(int count) {
    if (count >= 100) return Colors.cyanAccent; // Diamond
    if (count >= 50) return Colors.amber; // Gold
    if (count >= 10) return Colors.grey.shade400; // Silver
    return Colors.brown.shade400; // Bronze
  }
}
