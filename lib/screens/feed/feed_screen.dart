import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io'; // Added for File
import 'package:provider/provider.dart';
import '../../services/activity_service.dart';
import '../../services/auth_service.dart';
import '../../services/gamification_service.dart';
import '../../services/social_service.dart';
import '../../services/map_state.dart';
import 'package:latlong2/latlong.dart';
import '../../models/activity_model.dart';
import '../../models/comment_model.dart';
import '../../models/challenge_model.dart';
import '../../models/user_model.dart';
import '../../models/tip_model.dart';

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

        final docs = snapshot.data?.docs ?? [];
        final activities = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; 
          return Activity.fromMap(data);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), 
          itemCount: activities.length + 2, // Added +1 for Tip
          itemBuilder: (context, index) {
            // Index 0: Daily Tip (Static)
            if (index == 0) {
              return const _DailyTipSection();
            }

            // Index 1: Challenges
            if (index == 1) {
              return const _ChallengesSection();
            }
            
            final activity = activities[index - 2];
            return ActivityCard(activity: activity);
          },
        );
      },
    );
  }
}


class _DailyTipSection extends StatelessWidget {
  const _DailyTipSection();

  Future<TipModel?> _getTodaysTip() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tips')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return TipModel.fromMap(snapshot.docs.first.data());
    } catch (e) {
      print('Error fetching tip: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TipModel?>(
      future: _getTodaysTip(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox(); // Tip yoksa gösterme
        }

        final tip = snapshot.data!;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(tip.iconEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text("Günün İpucu", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(tip.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(tip.content, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        );
      },
    );
  }
}



class _ChallengesSection extends StatefulWidget {
  const _ChallengesSection();

  @override
  State<_ChallengesSection> createState() => _ChallengesSectionState();
}

class _ChallengesSectionState extends State<_ChallengesSection> {
  // Simple hack to refresh state after join, better with Provider/Bloc
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false); // Need userId
    final userId = authService.user?.uid;

    return FutureBuilder<List<Challenge>>(
      future: GamificationService().getActiveChallenges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

        final challenges = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Meydan Okumalar 🔥", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  final challenge = challenges[index];
                  final daysLeft = challenge.endDate.difference(DateTime.now()).inDays;
                  final isJoined = userId != null && challenge.participants.contains(userId);

                  return Container(
                    width: 240,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isJoined ? Colors.amber.withOpacity(0.5) : Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flash_on, color: isJoined ? Colors.amber : Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(challenge.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(challenge.description, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("$daysLeft gün kaldı", style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                            isJoined 
                            ? Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                               child: const Text("Katıldın", style: TextStyle(color: Colors.amber, fontSize: 12)),
                            )
                            : InkWell(
                                onTap: () async {
                                  if (userId == null) return;
                                  await GamificationService().joinChallenge(challenge.id, userId);
                                  _refresh(); // Rebuild to show "Katıldın"
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Meydan okumaya katıldın!")));
                                },
                                child: Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                   decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                   child: const Text("Katıl", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
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
                   InkWell(
                     onTap: () {
                        // Navigate to Map
                        Provider.of<MapState>(context, listen: false).navigateToLocation(
                          LatLng(activity.latitude!, activity.longitude!)
                        );
                     },
                     child: Row(
                       children: [
                         const Icon(Icons.location_on, color: Colors.blueAccent, size: 16),
                         const SizedBox(width: 4),
                         Flexible(
                           child: Text(
                             "Konum: ${activity.latitude!.toStringAsFixed(4)}, ${activity.longitude!.toStringAsFixed(4)}",
                             style: const TextStyle(color: Colors.blueAccent, fontSize: 12, decoration: TextDecoration.underline),
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                       ],
                     ),
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
    if (photoData.isEmpty) return const SizedBox.shrink();

    // Check if it's a URL
    if (photoData.startsWith('http') || photoData.startsWith('https')) {
      return Image.network(
        photoData,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) {
           print("Error loading image from URL: $e");
           return _buildErrorPlaceholder();
        },
        loadingBuilder: (c, child, progress) {
          if (progress == null) return child;
          return Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null));
        },
      );
    } else if (File(photoData).existsSync()) {
      // Local File support (Demo Mode)
      return Image.file(
        File(photoData),
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => _buildErrorPlaceholder(),
      );
    } 
    // Assume Base64 or local path (if we supported it, but mainly URL now)
    try {
      // If it's a very long string, it might be base64.
      if (photoData.length > 200) {
         return Image.memory(
          base64Decode(photoData),
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _buildErrorPlaceholder(),
        );
      }
      return _buildErrorPlaceholder();
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
