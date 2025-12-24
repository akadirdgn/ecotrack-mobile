class Comment {
  final String id;
  final String activityId;
  final String userId;
  final String userName; // Added for display
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id, 
    required this.activityId, 
    required this.userId, 
    required this.userName, 
    required this.text, 
    required this.createdAt
  });
}
