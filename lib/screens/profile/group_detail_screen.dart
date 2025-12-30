import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/social_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(bottom: 50.0), // Move title further up to avoid TabBar overlap
                centerTitle: true,
                title: Text(widget.group.name),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.groups, size: 80, color: Colors.white24),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Detay"),
                  Tab(text: "Sıralama"),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailTab(widget.group),
            _buildLeaderboardTab(widget.group),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTab(Group group) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hakkında", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(group.description, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildInfoCard(Icons.star, "${group.totalPoints}", "Toplam Puan")),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard(Icons.people, "${group.memberIds.length}", "Üye")),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu özellik yakında eklenecek!")));
          },
          icon: const Icon(Icons.exit_to_app),
          label: const Text("Gruptan Ayrıl"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
        )
      ],
    );
  }

  Widget _buildLeaderboardTab(Group group) {
    return FutureBuilder<List<UserModel>>(
      future: SocialService().getGroupMembers(group.memberIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
           return const Center(child: Text("Üye bilgisi bulunamadı."));
        }

        final members = snapshot.data!;
        // Sort by points descending
        members.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final rank = index + 1;
            
            Color? rankColor;
            if (rank == 1) rankColor = Colors.amber;
            else if (rank == 2) rankColor = Colors.grey.shade400;
            else if (rank == 3) rankColor = Colors.brown.shade400;

            return ListTile(
              leading: CircleAvatar(
                 backgroundColor: rankColor ?? Colors.blueGrey,
                 child: Text("#$rank", style: const TextStyle(color: Colors.white)),
              ),
              title: Text(member.displayName),
              subtitle: Text("${member.activityCount} aktivite"),
              trailing: Text(
                "${member.totalPoints} P",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.greenAccent),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }
}
