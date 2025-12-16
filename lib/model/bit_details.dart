import 'dart:convert';
import 'package:zatch_app/model/ExploreApiRes.dart';
import 'package:zatch_app/model/product_response.dart';

// Helper function to decode the JSON response
BitDetailsResponse bitDetailsResponseFromJson(String str) =>
    BitDetailsResponse.fromJson(json.decode(str));

class BitDetailsResponse {
  final bool success;
  final BitDetails bit;

  BitDetailsResponse({
    required this.success,
    required this.bit,
  });

  factory BitDetailsResponse.fromJson(Map<String, dynamic> json) =>
      BitDetailsResponse(
        success: json["success"] ?? false,
        // Map 'bitsDetails' from JSON to our BitDetails model
        bit: BitDetails.fromJson(json["bitsDetails"] ?? {}),
      );
}

class BitDetails {
  final String id;
  final String title;
  final String description;
  final Video video;
  final Thumbnail thumbnail;
  final List<String> hashtags;
  final List<Product> products;
  final int likeCount;
  final int viewCount;
  final int shareCount;
  final int saveCount;
  final bool isSaved;
  final bool isLiked;
  final UploadedBy uploadedBy;
  final List<Comment> comments;

  // Stats Summary (Optional, based on JSON)
  final StatsSummary? statsSummary;

  BitDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.video,
    required this.thumbnail,
    required this.hashtags,
    required this.products,
    required this.likeCount,
    required this.viewCount,
    required this.shareCount,
    required this.saveCount,
    required this.isSaved,
    required this.isLiked,
    required this.uploadedBy,
    required this.comments,
    this.statsSummary,
  });

  factory BitDetails.fromJson(Map<String, dynamic> json) {
    var productsList = json['products'] as List<dynamic>? ?? [];
    var commentsList = json['comments'] as List<dynamic>? ?? [];
    var hashtagsList = json['hashtags'] as List<dynamic>? ?? [];

    return BitDetails(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      video: Video.fromJson(json['video'] ?? {}),
      thumbnail: Thumbnail.fromJson(json['thumbnail'] ?? {}),
      hashtags: List<String>.from(hashtagsList),
      products: productsList
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList(),
      likeCount: json['likeCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      saveCount: json['saveCount'] as int? ?? 0,
      isSaved: json['isSaved'] ?? false,
      isLiked: json['isLiked'] ?? false,
      uploadedBy: UploadedBy.fromJson(json['uploadedBy'] ?? {}),
      comments: commentsList
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList(),
      statsSummary: json['statsSummary'] != null
          ? StatsSummary.fromJson(json['statsSummary'])
          : null,
    );
  }

  // Helper for UI compatibility
  String get userId => uploadedBy.id;
}

class UploadedBy {
  final String id;
  final String username;
  final ProfilePic profilePic;
  final int followerCount;

  UploadedBy({
    required this.id,
    required this.username,
    required this.profilePic,
    required this.followerCount,
  });

  factory UploadedBy.fromJson(Map<String, dynamic> json) {
    return UploadedBy(
      id: json['_id'] ?? '',
      username: json['username'] ?? 'Unknown',
      profilePic: ProfilePic.fromJson(json['profilePic'] ?? {}),
      followerCount: json['followerCount'] ?? 0,
    );
  }
}


class User {
  final String id;
  final String username;
  final ProfilePic profilePic;

  User({
    required this.id,
    required this.username,
    required this.profilePic,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      username: json['username'] ?? 'Unknown',
      // JSON uses "profilePicture" inside comments, unlike "profilePic" elsewhere
      profilePic: ProfilePic.fromJson(json['profilePicture'] ?? {}),
    );
  }
}

class StatsSummary {
  final int views;
  final String viewsChange;
  final int zatches;

  StatsSummary({
    required this.views,
    required this.viewsChange,
    required this.zatches,
  });

  factory StatsSummary.fromJson(Map<String, dynamic> json) {
    return StatsSummary(
      views: json['views'] ?? 0,
      viewsChange: json['viewsChange'] ?? '',
      zatches: json['zatches'] ?? 0,
    );
  }
}

