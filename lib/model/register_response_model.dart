class RegisterResponse {
  final bool success;
  final String message;
  final String token;
  final User user;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      token: json["token"] ?? "",
      user: User.fromJson(json["user"]),
    );
  }
}

class User {
  final String username;
  final String password;
  final String countryCode;
  final String phone;
  final ProfilePic profilePic;
  final List<dynamic> followers;
  final List<dynamic> following;
  final int followerCount;
  final int reviewsCount;
  final int productsSoldCount;
  final int customerRating;
  final List<dynamic> savedBits;
  final List<dynamic> savedProducts;
  final String id;
  final DateTime createdAt;
  final int v;

  User({
    required this.username,
    required this.password,
    required this.countryCode,
    required this.phone,
    required this.profilePic,
    required this.followers,
    required this.following,
    required this.followerCount,
    required this.reviewsCount,
    required this.productsSoldCount,
    required this.customerRating,
    required this.savedBits,
    required this.savedProducts,
    required this.id,
    required this.createdAt,
    required this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json["username"] ?? "",
      password: json["password"] ?? "",
      countryCode: json["countryCode"] ?? "+91",
      phone: json["phone"] ?? "",
      profilePic: ProfilePic.fromJson(json["profilePic"]),
      followers: json["followers"] ?? [],
      following: json["following"] ?? [],
      followerCount: json["followerCount"] ?? 0,
      reviewsCount: json["reviewsCount"] ?? 0,
      productsSoldCount: json["productsSoldCount"] ?? 0,
      customerRating: json["customerRating"] ?? 0,
      savedBits: json["savedBits"] ?? [],
      savedProducts: json["savedProducts"] ?? [],
      id: json["_id"] ?? "",
      createdAt: DateTime.parse(json["createdAt"] ?? DateTime.now().toIso8601String()),
      v: json["__v"] ?? 0,
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
      publicId: json["public_id"] ?? "",
      url: json["url"] ?? "",
    );
  }
}
