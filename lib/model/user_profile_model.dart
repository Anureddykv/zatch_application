import 'package:flutter/foundation.dart';

// --- Main UserProfile Class ---
class UserProfile {
  final String id;  final String? username;
  final String? phone;
  final String? email;
  final String? countryCode;
  final String? gender;
  final String? categoryType;
  final String? role;
  final String? profilePicUrl;
  final String? sellerStatus;
   int followerCount;
  final int reviewsCount;
  final int productsSoldCount;
  final int customerRating;
  final List<dynamic> followers;
  final List<dynamic> following;
  final List<dynamic> sellingProducts;
  final List<SavedBit> savedBits;
  final List<SavedProduct> savedProducts;
  final List<UpcomingLive> upcomingLives;

  UserProfile({
    required this.id,
    this.username,
    this.phone,
    this.email,
    this.countryCode,
    this.gender,
    this.categoryType,
    this.role,
    this.profilePicUrl,
    this.sellerStatus,
    this.followerCount = 0,
    this.reviewsCount = 0,
    this.productsSoldCount = 0,
    this.customerRating = 0,
    this.followers = const [],
    this.following = const [],
    this.sellingProducts = const [],
    this.savedBits = const [],
    this.savedProducts = const [],
    this.upcomingLives = const [],
  });

  UserProfile copyWith({
    String? id,
    String? username,
    String? phone,
    String? email,
    String? countryCode,
    String? gender,
    String? categoryType,
    String? role,
    String? profilePicUrl,
    String? sellerStatus,
    int? followerCount,
    int? reviewsCount,
    int? productsSoldCount,
    int? customerRating,
    List<dynamic>? followers,
    List<dynamic>? following,
    List<dynamic>? sellingProducts,
    List<SavedBit>? savedBits,
    List<SavedProduct>? savedProducts,
    List<UpcomingLive>? upcomingLives,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      gender: gender ?? this.gender,
      categoryType: categoryType ?? this.categoryType,
      role: role ?? this.role,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      sellerStatus: sellerStatus ?? this.sellerStatus,
      followerCount: followerCount ?? this.followerCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      productsSoldCount: productsSoldCount ?? this.productsSoldCount,
      customerRating: customerRating ?? this.customerRating,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      sellingProducts: sellingProducts ?? this.sellingProducts,
      savedBits: savedBits ?? this.savedBits,
      savedProducts: savedProducts ?? this.savedProducts,
      upcomingLives: upcomingLives ?? this.upcomingLives,
    );
  }

  // This factory now correctly handles the full API response structure.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // 1. Extract the nested 'user' object from the full response.
    final user = json['user'] ?? {};

    // 2. Use the 'user' object for all subsequent operations.
    final profilePic = user['profilePic'] ?? {};

    final sellingProductsList =
    (user['sellingProducts'] as List? ?? []).map((product) {
      final images = product['images'] as List? ?? [];
      return {
        ...product,
        'image': images.isNotEmpty ? images.first : null,
      };
    }).toList();

    final savedBitsList = (user['savedBits'] as List? ?? [])
        .map((bitJson) => SavedBit.fromJson(bitJson))
        .toList();
    final savedProductsList = (user['savedProducts'] as List? ?? [])
        .map((productJson) => SavedProduct.fromJson(productJson))
        .toList();
    final upcomingLivesList = (user['upcomingLives'] as List? ?? [])
        .map((liveJson) => UpcomingLive.fromJson(liveJson))
        .toList();

    // 3. Create the UserProfile using the 'user' object.
    return UserProfile(
      id: user['_id'] ?? '',
      username: user['username'],
      phone: user['phone'],
      email: user['email'],
      countryCode: user['countryCode'],
      gender: user['gender'],
      categoryType: user['categoryType'],
      role: user['role'],
      profilePicUrl: profilePic['url'],
      sellerStatus: user['sellerStatus'],
      followerCount: user['followerCount'] ?? 0,
      reviewsCount: user['reviewsCount'] ?? 0,
      productsSoldCount: user['productsSoldCount'] ?? 0,
      customerRating: user['customerRating'] ?? 0,
      followers: user['followers'] ?? [],
      following: user['following'] ?? [],
      sellingProducts: sellingProductsList,
      savedBits: savedBitsList,
      savedProducts: savedProductsList,
      upcomingLives: upcomingLivesList,
    );
  }
}

// --- Helper Classes for Nested Data ---
// (These are unchanged and correct)

class SavedBit {
  final String id;
  final String title;
  final String? description;
  final String? videoUrl;

  SavedBit({
    required this.id,
    required this.title,
    this.description,
    this.videoUrl,
  });

  factory SavedBit.fromJson(Map<String, dynamic> json) {
    final video = json['video'] ?? {};
    return SavedBit(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Untitled Bit',
      description: json['description'],
      videoUrl: video['url'],
    );
  }
}

class SavedProduct {
  final String id;
  final String name;
  final num price;
  final String? imageUrl;

  SavedProduct({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory SavedProduct.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List? ?? [];
    return SavedProduct(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Untitled Product',
      price: json['price'] ?? 0,
      imageUrl: images.isNotEmpty ? images.first['url'] : null,
    );
  }
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
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Untitled Live',
      scheduledStartTime:
      DateTime.tryParse(json['scheduledStartTime'] ?? '') ?? DateTime.now(),
    );
  }
}
