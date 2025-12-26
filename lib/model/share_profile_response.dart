class ShareProfileResponse {
  final bool success;
  final String message;
  final ProfileData profileData;

  ShareProfileResponse({
    required this.success,
    required this.message,
    required this.profileData,
  });

  factory ShareProfileResponse.fromJson(Map<String, dynamic> json) {
    return ShareProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      profileData: ProfileData.fromJson(json['profileData']),
    );
  }
}

class ProfileData {
  final String id;
  final String profilePic;
  final int rating;
  final String name;
  final String email;
  final List<dynamic> reviews;

  ProfileData({
    required this.id,
    required this.profilePic,
    required this.rating,
    required this.name,
    required this.email,
    required this.reviews,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? '',
      profilePic: json['profilePic'] ?? '',
      rating: json['rating'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      reviews: json['reviews'] ?? [],
    );
  }
}
