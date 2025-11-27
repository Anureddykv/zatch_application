class LoginResponse {
  final bool success;
  final String message;
  final String token;
  final User user;

  LoginResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final ProfilePic profilePic;
  final String id;
  final String username;
  final String password;
  final String countryCode;
  final String phone;
  final List<dynamic> followers;
  final List<dynamic> following;
  final int followerCount;
  final int reviewsCount;
  final int productsSoldCount;
  final double customerRating;
  final List<dynamic> savedBits;
  final List<dynamic> savedProducts;
  final DateTime createdAt;
  final int v;

  User({
    required this.profilePic,
    required this.id,
    required this.username,
    required this.password,
    required this.countryCode,
    required this.phone,
    required this.followers,
    required this.following,
    required this.followerCount,
    required this.reviewsCount,
    required this.productsSoldCount,
    required this.customerRating,
    required this.savedBits,
    required this.savedProducts,
    required this.createdAt,
    required this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      profilePic: ProfilePic.fromJson(json['profilePic']),
      id: json['_id'],
      username: json['username'],
      password: json['password'],
      countryCode: json['countryCode'],
      phone: json['phone'],
      followers: json['followers'],
      following: json['following'],
      followerCount: json['followerCount'],
      reviewsCount: json['reviewsCount'],
      productsSoldCount: json['productsSoldCount'],
      customerRating: (json['customerRating'] as num).toDouble(),
      savedBits: json['savedBits'],
      savedProducts: json['savedProducts'],
      createdAt: DateTime.parse(json['createdAt']),
      v: json['__v'],
    );
  }
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
      publicId: json['public_id'],
      url: json['url'],
    );
  }
}