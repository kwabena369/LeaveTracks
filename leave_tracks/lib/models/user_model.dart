class UserModel {
  final String uid;
  final String? username;
  final String? email;
  final String? googleId;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    this.username,
    this.email,
    this.googleId,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      username: json['username'],
      email: json['email'],
      googleId: json['googleid'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['createAt']),
      updatedAt: DateTime.parse(json['updateAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'googleid': googleId,
      'avatar_url': avatarUrl,
      'createAt': createdAt.toIso8601String(),
      'updateAt': updatedAt.toIso8601String(),
    };
  }
}