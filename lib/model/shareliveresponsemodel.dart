class ShareResponseModel {
  final bool success;
  final String message;
  final ShareText shareText;

  ShareResponseModel({
    required this.success,
    required this.message,
    required this.shareText,
  });

  factory ShareResponseModel.fromJson(Map<String, dynamic> json) {
    return ShareResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      shareText: ShareText.fromJson(json['shareText']),
    );
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
}
