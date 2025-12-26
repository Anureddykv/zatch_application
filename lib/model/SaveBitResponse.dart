class SaveBitResponse {
  final bool success;
  final String message;
  final bool isSaved;
  final int savedBitsCount;

  SaveBitResponse({
    required this.success,
    required this.message,
    required this.isSaved,
    required this.savedBitsCount,
  });

  factory SaveBitResponse.fromJson(Map<String, dynamic> json) {
    return SaveBitResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      isSaved: json['isSaved'] ?? false,
      savedBitsCount: json['savedBitsCount'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'isSaved': isSaved,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'SaveBitResponse(success: $success, isSaved: $isSaved, message: "$message")';
  }
}
