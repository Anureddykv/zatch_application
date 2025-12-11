import 'package:flutter/foundation.dart';
import 'package:zatch_app/model/product_response.dart';

// --- Top-Level API Response ---
class ExploreApiResponse {
  final bool success;
  final String message;
  final List<Bits> bits;

  ExploreApiResponse({
    required this.success,
    required this.message,
    required this.bits,
  });

  factory ExploreApiResponse.fromJson(Map<String, dynamic> json) {
    var bitsListFromJson = json['bits'] as List<dynamic>?;
    List<Bits> parsedBits = [];
    if (bitsListFromJson != null) {
      parsedBits = bitsListFromJson
          .map((i) => Bits.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return ExploreApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      bits: parsedBits,
    );
  }
}

// --- Main "Bits" Model ---
class Bits {
  final String id;
  final String title;
  final String description;
  final Video video;
  final Thumbnail thumbnail;
  final List<String> hashtags;
  final List<Product> products;
  final String userId;
  final List<String> likes;
  final int likeCount;
  final int viewCount;
  final int shareCount;
  final String shareLink;
  final DateTime createdAt;
  final List<Comment> comments;
  final String? type;

  Bits({
    required this.id,
    required this.title,
    required this.description,
    required this.video,
    required this.thumbnail,
    required this.hashtags,
    required this.products,
    required this.userId,
    required this.likes,
    required this.likeCount,
    required this.viewCount,
    required this.shareCount,
    required this.shareLink,
    required this.createdAt,
    required this.comments,
    this.type,
  });

  factory Bits.fromJson(Map<String, dynamic> json) {
    // Safely parse nested lists
    var productsList = json['products'] as List<dynamic>? ?? [];
    var commentsList = json['comments'] as List<dynamic>? ?? [];
    var hashtagsList = json['hashtags'] as List<dynamic>? ?? [];

    return Bits(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? '',
      video: Video.fromJson(json['video'] ?? {}),
      thumbnail: Thumbnail.fromJson(json['thumbnail'] ?? {}),
      hashtags: List<String>.from(hashtagsList),
      products: productsList
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList(),
      userId: json['userId'] as String? ?? '',
      likes: List<String>.from(json['likes'] as List<dynamic>? ?? []),
      likeCount: json['likeCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      shareLink: json['shareLink'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      comments: commentsList
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList(),
      type: json['type'] as String?,
    );
  }
}

// --- Nested Models ---

class Video {
  final String? publicId;
  final String? url;

  Video({required this.publicId, required this.url});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      publicId: json['public_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class Thumbnail {
  final String publicId;
  final String url;

  Thumbnail({required this.publicId, required this.url});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      publicId: json['public_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class Comment {
  final String userId;
  final String text;
  final String id;
  final DateTime createdAt;
  final Reviewer? user;
  final int likes;
  final List<Comment> replies;

  Comment({
    required this.userId,
    required this.text,
    required this.id,
    required this.createdAt,
    this.user,
    this.likes = 0,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['userId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      id: json['_id'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      user: json['user'] != null ? Reviewer.fromJson(json['user']) : null,
      likes: json['likes'] ?? 0,
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),

    );
  }
}
class Review {
  final String id;
  final Reviewer reviewerId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reviewerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      reviewerId: Reviewer.fromJson(json['reviewerId'] ?? {}),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class Reviewer {
  final ProfilePic profilePic;
  final String id;
  final String username;

  Reviewer({
    required this.profilePic,
    required this.id,
    required this.username,
  });

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(
      profilePic: ProfilePic.fromJson(json['profilePic'] ?? {}),
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
    );
  }
}
