class UpdateProfileResponse {
  final bool success;
  final String message;
  final User user;

  UpdateProfileResponse({
    required this.success,
    required this.message,
    required this.user,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
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
}

class User {
  final ProfilePic profilePic;
  final String id;
  final String username;
  final String countryCode;
  final String phone;
  final String email;
  final String dob;
  final String gender;
  final String categoryType;
  final List<dynamic> followers;
  final List<dynamic> following;
  final int followerCount;
  final int reviewsCount;
  final int productsSoldCount;
  final double customerRating;
  final List<dynamic> savedBits;
  final List<dynamic> savedProducts;
  final bool isAdmin;
  final String createdAt;
  final int v;

  User({
    required this.profilePic,
    required this.id,
    required this.username,
    required this.countryCode,
    required this.phone,
    required this.email,
    required this.gender,
    required this.dob,
    required this.categoryType,
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
    required this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      profilePic: ProfilePic.fromJson(json['profilePic'] ?? {}),
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      countryCode: json['countryCode'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      categoryType: json['categoryType'] ?? '',
      followers: json['followers'] ?? [],
      following: json['following'] ?? [],
      followerCount: json['followerCount'] ?? 0,
      reviewsCount: json['reviewsCount'] ?? 0,
      productsSoldCount: json['productsSoldCount'] ?? 0,
      customerRating: (json['customerRating'] ?? 0).toDouble(),
      savedBits: json['savedBits'] ?? [],
      savedProducts: json['savedProducts'] ?? [],
      isAdmin: json['isAdmin'] ?? false,
      createdAt: json['createdAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profilePic': profilePic.toJson(),
      '_id': id,
      'username': username,
      'countryCode': countryCode,
      'phone': phone,
      'email': email,
      'gender': gender,
      'dob': dob,
      'categoryType': categoryType,
      'followers': followers,
      'following': following,
      'followerCount': followerCount,
      'reviewsCount': reviewsCount,
      'productsSoldCount': productsSoldCount,
      'customerRating': customerRating,
      'savedBits': savedBits,
      'savedProducts': savedProducts,
      'isAdmin': isAdmin,
      'createdAt': createdAt,
      '__v': v,
    };
  }
}

class ProfilePic {
  final String publicId;
  final String url;

  ProfilePic({required this.publicId, required this.url});

  factory ProfilePic.fromJson(Map<String, dynamic> json) {
    return ProfilePic(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'url': url,
    };
  }
}
