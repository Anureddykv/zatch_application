class ExploreSeller {
  final String id;
  final String username;
  final String countryCode;
  final String phone;
  final String gender;
  final String categoryType;
  final int followerCount;
  final int reviewsCount;
  final int productsSoldCount;
  final double customerRating;
  final String createdAt;
  final ProfilePic profilePic;

  ExploreSeller({
    required this.id,
    required this.username,
    required this.countryCode,
    required this.phone,
    required this.gender,
    required this.categoryType,
    required this.followerCount,
    required this.reviewsCount,
    required this.productsSoldCount,
    required this.customerRating,
    required this.createdAt,
    required this.profilePic,
  });

  factory ExploreSeller.fromJson(Map<String, dynamic> json) => ExploreSeller(
    id: json["_id"],
    username: json["username"],
    countryCode: json["countryCode"],
    phone: json["phone"],
    gender: json["gender"],
    categoryType: json["categoryType"],
    followerCount: json["followerCount"] ?? 0,
    reviewsCount: json["reviewsCount"] ?? 0,
    productsSoldCount: json["productsSoldCount"] ?? 0,
    customerRating: (json["customerRating"] ?? 0).toDouble(),
    createdAt: json["createdAt"],
    profilePic: ProfilePic.fromJson(json["profilePic"]),
  );
}

class ProfilePic {
  final String publicId;
  final String url;

  ProfilePic({required this.publicId, required this.url});

  factory ProfilePic.fromJson(Map<String, dynamic> json) => ProfilePic(
    publicId: json["public_id"] ?? "",
    url: json["url"] ?? "",
  );
}
