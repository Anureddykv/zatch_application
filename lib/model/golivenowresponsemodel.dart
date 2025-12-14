class GoLiveNowResponseModel {
  final bool success;
  final String token;
  final String channelName;
  final String sessionId;
  final int uid;
  final String appId;
  final int expiresAt;
  final int expiresIn;

  GoLiveNowResponseModel({
    required this.success,
    required this.token,
    required this.channelName,
    required this.sessionId,
    required this.uid,
    required this.appId,
    required this.expiresAt,
    required this.expiresIn,
  });

  factory GoLiveNowResponseModel.fromJson(Map<String, dynamic> json) {
    return GoLiveNowResponseModel(
      success: json['success'] ?? false,
      token: json['token'] ?? '',
      channelName: json['channelName'] ?? '',
      sessionId: json['sessionId'] ?? '',
      uid: json['uid'] ?? 0,
      appId: json['appId'] ?? '',
      expiresAt: json['expiresAt'] ?? 0,
      expiresIn: json['expiresIn'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'token': token,
      'channelName': channelName,
      'sessionId': sessionId,
      'uid': uid,
      'appId': appId,
      'expiresAt': expiresAt,
      'expiresIn': expiresIn,
    };
  }
}
