class FollowResponse {
  final bool success;
  final String message;
  final bool isFollowing; // New field
  final int followerCount;

  FollowResponse({
    required this.success,
    required this.message,
    required this.isFollowing, // Added to constructor
    required this.followerCount,
  });

  factory FollowResponse.fromJson(Map<String, dynamic> json) {
    return FollowResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      isFollowing: json["isFollowing"] ?? false, // Parse new field from JSON
      followerCount: json["followerCount"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "isFollowing": isFollowing, // Add to JSON serialization
      "followerCount": followerCount,
    };
  }
}
