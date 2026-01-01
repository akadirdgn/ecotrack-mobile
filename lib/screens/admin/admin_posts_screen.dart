import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/activity_service.dart';
import '../../models/activity_model.dart';
import 'package:intl/intl.dart';

class AdminPostsScreen extends StatefulWidget {
  const AdminPostsScreen({super.key});

  @override
  State<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends State<AdminPostsScreen> {
  final AdminService _adminService = AdminService();
  final ActivityService _activityService = ActivityService();
  List<Activity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    final activities = await _adminService.getAllActivitiesForAdmin();
    if (mounted) {
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePost(Activity activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Gönderiyi Sil', style: TextStyle(color: Colors.white)),
        content: const Text('Bu gönderiyi kalıcı olarak silmek istediğinize emin misiniz? Kullanıcı puanları geri alınacaktır.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _activityService.deleteActivity(activity.id);
        setState(() {
          _activities.removeWhere((a) => a.id == activity.id);
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gönderi silindi.")));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gönderi Yönetimi"),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.black,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _activities.length,
              separatorBuilder: (c, i) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: activity.photoId.isNotEmpty 
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            activity.photoId, 
                            width: 60, 
                            height: 60, 
                            fit: BoxFit.cover,
                            errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        )
                      : Container(
                          width: 60, 
                          height: 60, 
                          color: Colors.white12, 
                          child: const Icon(Icons.image_not_supported, color: Colors.white54)
                        ),
                  title: Text(activity.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text("${DateFormat('dd/MM/yyyy').format(activity.timestamp)} • ${activity.pointsEarned} P", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deletePost(activity),
                  ),
                );
              },
            ),
    );
  }
}
