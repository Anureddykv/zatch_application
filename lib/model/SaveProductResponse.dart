
class SaveProductResponse {
  final bool success;
  final String message;
  final bool isSaved;
  final int savedProductsCount;
  final int saveCount; // 0 for unsaved, 1 for saved

  SaveProductResponse({
    required this.success,
    required this.message,
    required this.isSaved,
    required this.savedProductsCount,
    required this.saveCount,
  });

  factory SaveProductResponse.fromJson(Map<String, dynamic> json) {
    return SaveProductResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      isSaved: json['isSaved'] ?? false,
      savedProductsCount: json['savedProductsCount'] ?? 0,
      saveCount: json['saveCount'] ?? 0,
    );
  }
}
