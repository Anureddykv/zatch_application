class ShareLiveResponse {
  final bool success;
  final String message;
  final ShareText shareText;

  ShareLiveResponse({
    required this.success,
    required this.message,
    required this.shareText,
  });

  factory ShareLiveResponse.fromJson(Map<String, dynamic> json) {
    return ShareLiveResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      shareText: ShareText.fromJson(json['shareText'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'shareText': shareText.toJson(),
    };
  }
}

class ShareText {
  final String primary;
  final String secondary;
  final String link;
  final String title;
  final String? thumbnail;
  final String? thumbnailPublicId;
  final bool isLive;
  final String scheduledTime;
  final String hostName;
  final String channelName;

  ShareText({
    required this.primary,
    required this.secondary,
    required this.link,
    required this.title,
    this.thumbnail,
    this.thumbnailPublicId,
    required this.isLive,
    required this.scheduledTime,
    required this.hostName,
    required this.channelName,
  });

  factory ShareText.fromJson(Map<String, dynamic> json) {
    return ShareText(
      primary: json['primary'] ?? '',
      secondary: json['secondary'] ?? '',
      link: json['link'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'],
      thumbnailPublicId: json['thumbnailPublicId'],
      isLive: json['isLive'] ?? false,
      scheduledTime: json['scheduledTime'] ?? '',
      hostName: json['hostName'] ?? '',
      channelName: json['channelName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'link': link,
      'title': title,
      'thumbnail': thumbnail,
      'thumbnailPublicId': thumbnailPublicId,
      'isLive': isLive,
      'scheduledTime': scheduledTime,
      'hostName': hostName,
      'channelName': channelName,
    };
  }
}