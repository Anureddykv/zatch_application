// lib/model/user_profile_response.dart

class UserProfileResponse {
  final bool success;
  final String message;
  final User user;
  UserProfileResponse({
    required this.success,
    required this.message,
    required this.user,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user.toJson(),
    };
  }

  @override
  String toString() => 'UserProfileResponse(success: $success, message: $message, user: $user)';
}

class User {
  final String id;
  final bool isFollowing;
  final String username;
  final String countryCode;
  final String phone;
  final String email;
  final String? dob;
  final String gender;
  final String categoryType;
  final ProfilePic profilePic;
  final List<dynamic> followers;
  final List<FollowedUser> following;
  final int followerCount;
  final int reviewsCount;
  final int productsSoldCount;
  final int customerRating;
  final List<SavedBit> savedBits;
  final List<SavedProduct> savedProducts;
  final bool isAdmin;
  final DateTime createdAt;
  final String sellerStatus;
  final List<dynamic> sellingProducts;
  final List<UpcomingLive> upcomingLives;

  User({
    required this.id,
    this.isFollowing = false,
    required this.username,
    required this.countryCode,
    required this.phone,
    required this.dob,
    required this.email,
    required this.gender,
    required this.categoryType,
    required this.profilePic,
    required this.followers,
    required this.following,
    required this.followerCount,
    required this.reviewsCount,
    required this.productsSoldCount,
    required this.customerRating,
    required this.savedBits,
    required this.savedProducts,
    required this.isAdmin,
    required this.createdAt,
    required this.sellerStatus,
    required this.sellingProducts,
    required this.upcomingLives,

  });

  factory User.fromJson(Map<String, dynamic> json) {
    // ✅ FIX: Robustly parse the 'following' list.
    // It can be a list of Objects (Map) or a list of IDs (String).
    final List<FollowedUser> followingList;
    final dynamic followingData = json['following'];

    if (followingData is List && followingData.isNotEmpty) {
      // Check the type of the first element to decide how to parse.
      if (followingData.first is Map<String, dynamic>) {
        // Case 1: List contains full user objects.
        followingList = followingData
            .map((item) => FollowedUser.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (followingData.first is String) {
        // Case 2: List contains only user IDs (Strings).
        // Create partial FollowedUser objects.
        followingList = followingData
            .map((id) => FollowedUser(id: id as String, username: '...'))
            .toList();
      } else {
        // Case 3: List contains unexpected data types.
        followingList = [];
      }
    } else {
      // Case 4: List is null, empty, or not a list.
      followingList = [];
    }


    return User(
      id: json['_id'] ?? json['id'] ?? '',
      isFollowing: json['isFollowing'] ?? false,
      username: json['username'] ?? '',
      countryCode: json['countryCode'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'],
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      categoryType: json['categoryType'] ?? '',
      profilePic: ProfilePic.fromJson(json['profilePic'] ?? {}),
      followers: List<dynamic>.from(json['followers'] ?? []),
      following: followingList, // Use the safely parsed list
      followerCount: json['followerCount'] ?? 0,
      reviewsCount: json['reviewsCount'] ?? 0,
      productsSoldCount: json['productsSoldCount'] ?? 0,
      customerRating: json['customerRating'] ?? 0,
      savedBits: List<SavedBit>.from((json["savedBits"] ?? []).map((x) => SavedBit.fromJson(x))),
      savedProducts: List<SavedProduct>.from((json["savedProducts"] ?? []).map((x) => SavedProduct.fromJson(x))),
      isAdmin: json['isAdmin'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      sellerStatus: json['sellerStatus'] ?? '',
      sellingProducts: List<dynamic>.from(json['sellingProducts'] ?? []),
      upcomingLives: List<UpcomingLive>.from((json['upcomingLives'] ?? []).map((x) => UpcomingLive.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'isFollowing': isFollowing,
      'username': username,
      'countryCode': countryCode,
      'phone': phone,
      'email': email,
      'dob': dob,
      'gender': gender,
      'categoryType': categoryType,
      'profilePic': profilePic.toJson(),
      'followers': followers,
      'following': List<dynamic>.from(following.map((x) => x.toJson())),
      'followerCount': followerCount,
      'reviewsCount': reviewsCount,
      'productsSoldCount': productsSoldCount,
      'customerRating': customerRating,
      'savedBits': List<dynamic>.from(savedBits.map((x) => x.toJson())),
      'savedProducts': List<dynamic>.from(savedProducts.map((x) => x.toJson())),
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'sellerStatus': sellerStatus,
      'sellingProducts': sellingProducts,
      'upcomingLives': List<dynamic>.from(upcomingLives.map((x) => x.toJson())),
    };
  }

  @override
  String toString() =>
      'User(username: $username, email: $email, followerCount: $followerCount)';
}

class ProfilePic {
  final String publicId;
  final String url;

  ProfilePic({
    required this.publicId,
    required this.url,
  });

  factory ProfilePic.fromJson(Map<String, dynamic> json) {
    return ProfilePic(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'public_id': publicId,
    'url': url,
  };
}

class FollowedUser {
  final String id;
  final String username;
  final String? profilePicUrl;
  final int productsCount;

  FollowedUser({
    required this.id,
    required this.username,
    this.profilePicUrl,
    this.productsCount = 0,
  });

  factory FollowedUser.fromJson(Map<String, dynamic> json) {
    final profilePic = json['profilePic'] as Map<String, dynamic>? ?? {};
    final products = json['sellingProducts'] as List? ?? [];

    return FollowedUser(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? 'No Name',
      profilePicUrl: profilePic['url'],
      productsCount: products.length,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'profilePic': {'url': profilePicUrl},
      'sellingProducts': List.generate(productsCount, (_) => {}),
    };
  }
}

class SavedBit {
  final String id;
  final BitMedia video;
  final BitMedia? thumbnail;
  final String title;
  final String description;
  final List<String> hashtags;
  final int likeCount;
  final int viewCount;
  final String? thumbnailUrl; // Helper for UI
  final List<BitComment> comments;

  SavedBit({
    required this.id,
    required this.video,
    this.thumbnail,
    required this.title,
    required this.description,
    required this.hashtags,
    required this.likeCount,
    required this.viewCount,
    required this.comments,
  }) : thumbnailUrl = thumbnail?.url;

  factory SavedBit.fromJson(Map<String, dynamic> json) {
    return SavedBit(
      id: json["_id"] ?? json['id'] ?? '',
      video: BitMedia.fromJson(json["video"] ?? {}),
      thumbnail: json["thumbnail"] != null ? BitMedia.fromJson(json["thumbnail"]) : null,
      title: json["title"] ?? '',
      description: json["description"] ?? '',
      hashtags: List<String>.from(json["hashtags"] ?? []),
      likeCount: json["likeCount"] ?? 0,
      viewCount: json["viewCount"] ?? 0,
      comments: List<BitComment>.from((json["comments"] ?? []).map((x) => BitComment.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "video": video.toJson(),
    "thumbnail": thumbnail?.toJson(),
    "title": title,
    "description": description,
    "hashtags": hashtags,
    "likeCount": likeCount,
    "viewCount": viewCount,
    "comments": comments.map((x) => x?.toJson()).toList(),
  };
}

class BitMedia {
  final String publicId;
  final String url;

  BitMedia({required this.publicId, required this.url});

  factory BitMedia.fromJson(Map<String, dynamic> json) => BitMedia(
    publicId: json["public_id"] ?? '',
    url: json["url"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "public_id": publicId,
    "url": url,
  };
}

class BitComment {
  final String id;
  final String userId;
  final String text;
  final DateTime createdAt;

  BitComment({required this.id, required this.userId, required this.text, required this.createdAt});

  factory BitComment.fromJson(Map<String, dynamic> json) => BitComment(
    id: json["_id"] ?? json['id'] ?? '',
    userId: json["userId"] ?? '',
    text: json["text"] ?? '',
    createdAt: DateTime.tryParse(json["createdAt"] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "text": text,
    "createdAt": createdAt.toIso8601String(),
  };
}

class SavedProduct {
  final String id;
  final String name;
  final double price;
  final bool? isLiked;
  final List<ProductImage> images;

  SavedProduct({
    required this.id,
    required this.name,
    required this.price,
     this.isLiked,
    required this.images,
  });

  factory SavedProduct.fromJson(Map<String, dynamic> json) => SavedProduct(
    id: json["_id"] ?? json['id'] ?? '',
    name: json["name"] ?? 'Unnamed Product',
    price: (json["price"] as num?)?.toDouble() ?? 0.0,
    isLiked: (json["isLiked"] as bool?) ?? false,
    images: List<ProductImage>.from((json["images"] ?? []).map((x) => ProductImage.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "price": price,
    "isLiked": isLiked,
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
  };
}

class ProductImage {
  final String url;

  ProductImage({required this.url});

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
    url: json["url"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "url": url,
  };
}
class UpcomingLive {
  final String id;
  final String title;
  final DateTime scheduledStartTime;

  UpcomingLive({
    required this.id,
    required this.title,
    required this.scheduledStartTime,
  });

  factory UpcomingLive.fromJson(Map<String, dynamic> json) {
    return UpcomingLive(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? 'Untitled Live',
      scheduledStartTime:
      DateTime.tryParse(json['scheduledStartTime'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'scheduledStartTime': scheduledStartTime.toIso8601String(),
    };
  }
}
