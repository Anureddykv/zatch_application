class GoLiveStepOneResponse {
  final bool success;
  final String message;
  final String sessionId;

  GoLiveStepOneResponse({
    required this.success,
    required this.message,
    required this.sessionId,
  });

  factory GoLiveStepOneResponse.fromJson(Map<String, dynamic> json) {
    return GoLiveStepOneResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      sessionId: json['sessionId'] ?? '',
    );
  }
}
