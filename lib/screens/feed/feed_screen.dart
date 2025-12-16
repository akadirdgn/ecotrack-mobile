import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // For Base64
import 'package:provider/provider.dart'; // Added missing Provider import
import '../../services/activity_service.dart';
import '../../services/auth_service.dart';
import '../../models/models.dart';

 class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Hata: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Henüz hiç aktivite yok. \nİlk paylaşımı sen yap!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final activities = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Ensure ID is passed if not in data
          data['id'] = doc.id; 
          return Activity.fromMap(data);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // Space for FAB
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ActivityCard(activity: activity);
          },
        );
      },
    );
  }
}

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(activity.timestamp);
    
    // Type Helper
    String typeName = "Aktivite";
    IconData typeIcon = Icons.eco;
    if (activity.typeId == 'plastic') { typeName = "Plastik Toplama"; typeIcon = Icons.delete_outline; }
    if (activity.typeId == 'tree') { typeName = "Ağaç Dikimi"; typeIcon = Icons.park; }
    if (activity.typeId == 'glass') { typeName = "Cam Geri Dönüşüm"; typeIcon = Icons.wine_bar; }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(typeIcon, color: Theme.of(context).primaryColor),
            ),
            title: Text(typeName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(dateStr),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "+${activity.pointsEarned} P",
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // Image
          if (activity.photoId.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black12,
              child: _buildActivityImage(activity.photoId),
            ),
            
          // Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activity.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(activity.description, style: const TextStyle(color: Colors.white70)),
                ],
            
                // Location Info (New)
                if (activity.latitude != null && activity.longitude != null) ...[
                   const SizedBox(height: 8),
                   Row(
                     children: [
                       const Icon(Icons.location_on, color: Colors.blueAccent, size: 16),
                       const SizedBox(width: 4),
                       Text(
                         "Konum: ${activity.latitude!.toStringAsFixed(4)}, ${activity.longitude!.toStringAsFixed(4)}",
                         style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
                       ),
                     ],
                   )
                ],

                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.scale, size: 16, color: Colors.white60),
                    const SizedBox(width: 4),
                    Text(
                      "${activity.amount} ${activity.typeId == 'tree' ? 'Adet' : 'kg'}",
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          // Interaction Bar (Likes & Comments)
          const Divider(height: 1, color: Colors.white12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Like Button
                _LikeButton(activityId: activity.id),
                
                // Comment Button
                TextButton.icon(
                  onPressed: () => _showCommentsDialog(context, activity.id),
                  icon: const Icon(Icons.comment_outlined, color: Colors.white70),
                  label: const Text("Yorum Yap", style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(BuildContext context, String activityId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      builder: (context) => _CommentsSheet(activityId: activityId),
    );
  }


  Widget _buildActivityImage(String photoData) {
    // Check if it's a URL
    if (photoData.startsWith('http')) {
      return Image.network(
        photoData,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) {
           return _buildErrorPlaceholder();
        },
        loadingBuilder: (c, child, progress) {
          if (progress == null) return child;
          return Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null));
        },
      );
    } 
    // Assume Base64
    try {
      return Image.memory(
        base64Decode(photoData),
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => _buildErrorPlaceholder(),
      );
    } catch (e) {
      return _buildErrorPlaceholder(); 
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 40),
            SizedBox(height: 8),
            Text("Görsel Yüklenemedi", style: TextStyle(color: Colors.white54, fontSize: 12))
          ],
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  final String activityId;
  const _LikeButton({required this.activityId});

  @override
  Widget build(BuildContext context) {
    final activityService = ActivityService();
    // Assuming we have access to current user ID provider or auth service
    // For simplicity obtaining from Provider here if possible, or just checking generic signin
    // NOTE: In a cleaner arch, ID should be passed down. 
    // We'll use a specific implementation for now
    
    // Hacky way to get user ID inside a stateless widget without rebuilding everything
    // Ideally AuthService should be provided at top of FeedScreen
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.user?.uid;

    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<bool>(
      stream: activityService.isLiked(activityId, userId),
      builder: (context, snapshot) {
        final isLiked = snapshot.data ?? false;
        return StreamBuilder<int>(
          stream: activityService.getLikeCount(activityId),
          builder: (context, countSnapshot) {
            final likeCount = countSnapshot.data ?? 0;
            return TextButton.icon(
              onPressed: () => activityService.toggleLike(activityId, userId),
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.white70,
              ),
              label: Text("$likeCount Beğeni", style: TextStyle(color: isLiked ? Colors.red : Colors.white70)),
            );
          }
        );
      },
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final String activityId;
  const _CommentsSheet({required this.activityId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentController = TextEditingController();
  final _activityService = ActivityService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text("Yorumlar", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
             ),
             Expanded(
               child: StreamBuilder<List<Comment>>(
                 stream: _activityService.getComments(widget.activityId),
                 builder: (context, snapshot) {
                   if (snapshot.hasError) {
                     return Center(child: Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Text("Hata: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                     ));
                   }
                   if (snapshot.connectionState == ConnectionState.waiting) {
                     return const Center(child: CircularProgressIndicator());
                   }
                   
                   // Handle empty case properly
                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Henüz yorum yok. İlk yorumu sen yap!", style: TextStyle(color: Colors.white54)));
                   }
                   
                   final comments = snapshot.data!;
                   return ListView.builder(
                     itemCount: comments.length,
                     itemBuilder: (context, index) {
                       final comment = comments[index];
                       return ListTile(
                         leading: CircleAvatar(
                           backgroundColor: Colors.teal,
                           child: Text(comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                         ),
                         title: Text(comment.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                         subtitle: Text(comment.text, style: const TextStyle(color: Colors.white70)),
                       );
                     },
                   );
                 },
               ),
             ),
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Row(
                 children: [
                   Expanded(
                     child: TextField(
                       controller: _commentController,
                       decoration: const InputDecoration(
                         hintText: "Yorum yap...",
                         filled: true,
                         fillColor: Colors.white12,
                         border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                       ),
                       style: const TextStyle(color: Colors.white),
                     ),
                   ),
                   IconButton(
                     icon: const Icon(Icons.send, color: Colors.greenAccent),
                     onPressed: () {
                       if (_commentController.text.isNotEmpty && user != null) {
                         _activityService.addComment(
                           widget.activityId, 
                           user.uid, 
                           user.displayName.isNotEmpty ? user.displayName : 'Adsız',
                           _commentController.text
                         );
                         _commentController.clear();
                       }
                     },
                   )
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }
}
