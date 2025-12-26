import 'dart:convert';

/// A model to represent the API response when toggling a bit's saved status.
///
/// To use this class, you can decode a JSON string like this:
/// final toggleSaveResponse = toggleSaveResponseFromJson(jsonString);

ToggleSaveResponse toggleSaveResponseFromJson(String str) =>
    ToggleSaveResponse.fromJson(json.decode(str));

String toggleSaveResponseToJson(ToggleSaveResponse data) =>
    json.encode(data.toJson());

class ToggleSaveResponse {
  final bool success;
  final String message;
  final int savedBitsCount;

  ToggleSaveResponse({
    required this.success,
    required this.message,
    required this.savedBitsCount,
  });

  /// Factory constructor to create an instance from a JSON map.
  factory ToggleSaveResponse.fromJson(Map<String, dynamic> json) =>
      ToggleSaveResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        savedBitsCount: json["savedBitsCount"] ?? 0,
      );

  /// Converts the instance to a JSON map.
  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "savedBitsCount": savedBitsCount,
  };
}
