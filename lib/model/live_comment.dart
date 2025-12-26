// lib/model/live_comment.dart

class LiveCommentResponse {
  final bool success;
  final List<LiveComment> comments;
  final int total;

  LiveCommentResponse({
    required this.success,
    required this.comments,
    required this.total,
  });

  factory LiveCommentResponse.fromJson(Map<String, dynamic> json) {
    return LiveCommentResponse(
      success: json['success'] as bool? ?? false,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => LiveComment.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      total: json['total'] as int? ?? 0,
    );
  }
}

class LiveComment {
  final String id;
  final String text;
  final DateTime createdAt;
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
      text: json['text'] as String? ?? '',
      // MAP 'timestamp' from API to 'createdAt'
      createdAt: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),

      // CONSTRUCT the user object manually from the flat fields 'userId' and 'username'
      user: LiveCommentUser(
        id: json['userId'] as String? ?? '',
        username: json['username'] as String? ?? 'User',
        // API response doesn't seem to have profilePic currently, handling null safely
        profilePicUrl: json['profilePic'] is Map ? json['profilePic']['url'] : null,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'timestamp': createdAt.toIso8601String(), // Keeping consistency
      'userId': user.id,
      'username': user.username,
      'user': user.toJson(), // Optional: keep for internal UI consistency if needed
    };
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
      profilePicUrl: json['profilePicUrl'] as String? ??
          (json['profilePic'] is Map ? json['profilePic']['url'] : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'profilePic': {'url': profilePicUrl},
      'profilePicUrl': profilePicUrl,
    };
  }
}
