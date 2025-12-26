class ShareProductResponse {
  final bool success;
  final String message;
  final String shareLink;
  final String image;
  final String primaryText;
  final int shareCount;

  ShareProductResponse({
    required this.success,
    required this.message,
    required this.shareLink,
    required this.image,
    required this.primaryText,
    required this.shareCount,
  });

  factory ShareProductResponse.fromJson(Map<String, dynamic> json) {
    return ShareProductResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      shareLink: json['shareLink'] ?? '',
      image: json['image'] ?? '',
      primaryText: json['primaryText'] ?? '',
      shareCount: json['shareCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'shareLink': shareLink,
      'image': image,
      'primaryText': primaryText,
      'shareCount': shareCount,
    };
  }
}
