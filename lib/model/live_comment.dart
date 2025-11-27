// lib/model/live_comment.dart

class LiveComment {
  final String id;
  final String text;
  final DateTime createdAt;
  // The 'user' object is nested in the response
  final LiveCommentUser user;

  LiveComment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.user,
  });

  factory LiveComment.fromJson(Map<String, dynamic> json) {
    return LiveComment(
      id: json['_id'] as String? ?? '',
      text: json['text'] as String? ?? '...',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      // Safely parse the nested 'user' object
      user: LiveCommentUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class LiveCommentUser {
  final String id;
  final String username;
  final String? profilePicUrl;

  LiveCommentUser({
    required this.id,
    required this.username,
    this.profilePicUrl,
  });

  factory LiveCommentUser.fromJson(Map<String, dynamic> json) {
    return LiveCommentUser(
      id: json['_id'] as String? ?? '',
      username: json['username'] as String? ?? 'User',
      profilePicUrl: json['profilePicUrl'] as String?,
    );
  }
}
