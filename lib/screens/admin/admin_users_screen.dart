import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _adminService.getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kullanıcı Yönetimi"),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.black,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _users.length,
              separatorBuilder: (c, i) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(user.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(user.email, style: const TextStyle(color: Colors.white70)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("${user.totalPoints} P", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      Text("${user.activityCount} Aktivite", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
