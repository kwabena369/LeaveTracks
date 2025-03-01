// lib/models/comment_model.dart
class CommentModel {
  final String id;
  final String routeId;
  final String userId;
  final String userName;
  final String userProfile;
  final String content;
  final DateTime createdAt;
  final int likes;

  CommentModel({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.userName,
    required this.userProfile,
    required this.content,
    required this.createdAt,
    this.likes = 0,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? '',
      routeId: json['routeId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userProfile: json['userProfile'] ?? '/cat.png',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      likes: json['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'routeId': routeId,
      'userId': userId,
      'userName': userName,
      'userProfile': userProfile,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
    };
  }
}