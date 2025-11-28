// lib/model/api_response.dart
import 'user_model.dart';

class ApiResponse {
  final bool success;
  final String? message; // Make the message field nullable
  final int totalUsers;
  final List<UserModel> users;

  ApiResponse({
    required this.success,
    this.message, // No longer required in the constructor
    required this.totalUsers,
    required this.users,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var usersList = json['users'] as List? ?? [];
    List<UserModel> parsedUsers = usersList
        .map((i) => UserModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      totalUsers: json['totalUsers'] as int? ?? 0,
      users: parsedUsers,
    );
  }
}
