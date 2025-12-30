import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/social_service.dart';
import '../../services/gamification_service.dart';
import '../../models/user_model.dart';
import '../../models/badge_model.dart';
import '../../models/group_model.dart';
import '../../models/activity_model.dart';
import 'settings_screen.dart';
import 'group_detail_screen.dart';

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



                  // Dynamic Badges Section
                  Text("Rozetlerim", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: FutureBuilder<List<BadgeModel>>(
                      future: GamificationService().getAllBadges(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final allBadges = snapshot.data!;
                        
                        // Sort badges: Earned first, then by points
                        allBadges.sort((a, b) {
                          final isEarnedA = user.totalPoints >= a.requiredPoints;
                          final isEarnedB = user.totalPoints >= b.requiredPoints;
                          
                          if (isEarnedA && !isEarnedB) return -1;
                          if (!isEarnedA && isEarnedB) return 1;
                          return a.requiredPoints.compareTo(b.requiredPoints);
                        });

                        if (allBadges.isEmpty) {
                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Henüz rozet yok.",
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: allBadges.length,
                          itemBuilder: (context, index) {
                            final badge = allBadges[index];
                            // Check if earned based on points
                            final isEarned = user.totalPoints >= badge.requiredPoints;

                            return _buildDynamicBadgeItem(
                              badge.name,
                              badge.iconUrl,
                              badge.requiredPoints,
                              isEarned,
                              badge.category,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Groups Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Topluluklar", style: Theme.of(context).textTheme.titleLarge), 
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
                        onPressed: () => _showCreateGroupDialog(context, user.uid),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Group>>(
                    future: SocialService().getGroups(), 
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final groups = snapshot.data!;
                      
                      return Column(
                        children: groups.map((group) {
                          final isMember = group.memberIds.contains(user.uid);
                          return Card(
                            color: Colors.white.withOpacity(0.05),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => GroupDetailScreen(group: group)));
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: ListTile(
                                leading: CircleAvatar(backgroundColor: Colors.indigo, child: Text(group.name[0], style: const TextStyle(color: Colors.white))),
                                title: Text(group.name, style: const TextStyle(color: Colors.white)),
                                subtitle: Text("${group.totalPoints} Puan • ${group.memberIds.length} Üye", style: const TextStyle(color: Colors.white70)),
                                trailing: isMember 
                                  ? const Icon(Icons.chevron_right, color: Colors.white54)
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(60, 30),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      onPressed: () async {
                                        await SocialService().joinGroup(group.id, user.uid);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gruba katıldınız!")));
                                        (context as Element).markNeedsBuild(); // Force rebuild to update UI
                                      }, 
                                      child: const Text("Katıl", style: TextStyle(fontSize: 12)),
                                    ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
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

  Widget _buildDynamicBadgeItem(String name, String iconUrl, int points, bool earned, String category) {
    // Dynamic colors based on category
    Color badgeColor;
    switch (category) {
      case 'milestone':
        badgeColor = Colors.amber;
        break;
      case 'activity':
        badgeColor = Colors.lightGreenAccent;
        break;
      case 'special':
        badgeColor = Colors.purpleAccent;
        break;
      default:
        badgeColor = Colors.cyanAccent;
    }

    return Opacity(
      opacity: earned ? 1.0 : 0.35,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: earned
              ? LinearGradient(
                  colors: [
                    badgeColor.withOpacity(0.2),
                    badgeColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: earned ? null : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: earned ? Border.all(color: badgeColor, width: 2) : Border.all(color: Colors.white12, width: 1),
          boxShadow: earned
              ? [
                  BoxShadow(
                    color: badgeColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 48,
              width: 48,
              child: Image.network(
                iconUrl,
                errorBuilder: (c, e, s) => Icon(
                  Icons.workspace_premium,
                  size: 40,
                  color: earned ? badgeColor : Colors.grey,
                ),
                color: earned ? null : Colors.grey,
                colorBlendMode: earned ? null : BlendMode.saturation,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: earned ? badgeColor : Colors.white60,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!earned)
              Text(
                "${points}P",
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              )
            else
              Icon(Icons.check_circle, color: badgeColor, size: 14),
          ],
        ),
      ),
    );
  }



  // Deprecated: Keeping for reference if old code calls it, but mostly replaced
  Widget _buildBadgeItem(String name, int points, bool earned, IconData icon, Color badgeColor) {
    return Opacity(
      opacity: earned ? 1.0 : 0.5,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: earned ? badgeColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: earned ? Border.all(color: badgeColor, width: 1) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: earned ? badgeColor : Colors.grey),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
              maxLines: 2,
            ),
            if (!earned)
              Text(
                "${points}P",
                style: const TextStyle(fontSize: 10, color: Colors.white54),
              ),
          ],
        ),
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

  void _showCreateGroupDialog(BuildContext context, String userId) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Yeni Grup Oluştur", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Grup Adı",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24))
              ),
            ),
            const SizedBox(height: 8),
             TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Açıklama",
                labelStyle: TextStyle(color: Colors.white70),
                 enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24))
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await SocialService().createGroup(nameController.text, descController.text, userId);
                Navigator.pop(context);
                // In a stateless widget, we can't easily setState to refresh the FutureBuilder parent.
                // For this demo, we rely on the fact that next time profile opens it will be there, 
                // or user can pull to refresh if we had one.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Grup oluşturuldu!")));
              }
            },
            child: const Text("Oluştur", style: TextStyle(color: Colors.greenAccent))
          ),
        ],
      )
    );
  }
}
