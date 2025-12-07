import 'dart:convert';

import 'package:zatch_app/model/ExploreApiRes.dart';
import 'package:zatch_app/model/product_response.dart';

// Helper function to decode the JSON response
BitDetailsResponse bitDetailsResponseFromJson(String str) =>
    BitDetailsResponse.fromJson(json.decode(str));

class BitDetailsResponse {
  final bool success;
  final String message;
  final BitDetails bit;

  BitDetailsResponse({
    required this.success,
    required this.message,
    required this.bit,
  });

  factory BitDetailsResponse.fromJson(Map<String, dynamic> json) =>
      BitDetailsResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        // The 'bits' key contains a single object, so we pass it to BitDetails.fromJson
        bit: BitDetails.fromJson(json["bitsDetails"] ?? {}),
      );
}

// --- Main "BitDetails" Model ---
class BitDetails {
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
  final int saveCount;
  final bool isSaved;
  final UploadedBy uploadedBy;
  final String shareLink;
  final DateTime createdAt;
  final List<Comment> comments;

  BitDetails({
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
    required this.saveCount,
    required this.shareLink,
    required this.createdAt,
    required this.comments,
    required this.uploadedBy,
    required this.isSaved,
  });

  factory BitDetails.fromJson(Map<String, dynamic> json) {
    // Safely parse nested lists from the JSON
    var productsList = json['products'] as List<dynamic>? ?? [];
    var commentsList = json['comments'] as List<dynamic>? ?? [];
    var hashtagsList = json['hashtags'] as List<dynamic>? ?? [];
    var likesList = json['likes'] as List<dynamic>? ?? [];

    return BitDetails(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? '',
      // Parse nested objects
      video: Video.fromJson(json['video'] ?? {}),
      thumbnail: Thumbnail.fromJson(json['thumbnail'] ?? {}),
      hashtags: List<String>.from(hashtagsList),
      products: productsList
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList(),
      userId: json['userId'] as String? ?? '',
      likes: List<String>.from(likesList),
      likeCount: json['likeCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      // ✅ 3. Parse the new field from JSON with a safe default
      saveCount: json['saveCount'] as int? ?? 0,
      shareLink: json['shareLink'] as String? ?? '',
      isSaved: json['isSaved'] ?? false,
      uploadedBy: UploadedBy.fromJson(json['uploadedBy'] ?? {}),
      createdAt:
      DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      comments: commentsList
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
class UploadedBy {
  final String id;
  final String username;
  final ProfilePic profilePic;
  final String followerCount;

  UploadedBy({
    required this.id,
    required this.username,
    required this.profilePic,
    this.followerCount = "0",
  });
  factory UploadedBy.fromJson(Map<String, dynamic> json) {
    return UploadedBy(
      id: json['_id'] ?? '',
      username: json['username'] ?? 'Unknown',
      profilePic: ProfilePic.fromJson(json['profilePic'] ?? {}),
      followerCount: (json['followerCount'] ?? 0).toString(),
    );
  }
}


class Video {
  final String publicId;
  final String url;

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
