// lib/model/api_response.dart
import 'user_model.dart';

class ApiResponse {
  final bool success;
  final String? message;
  final int totalUsers;
  final List<UserModel> users;

  ApiResponse({
    required this.success,
    this.message,
    required this.totalUsers,
    required this.users,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    // Handle both 'users' and 'sellers' keys from different endpoints
    var list = (json['users'] ?? json['sellers']) as List? ?? [];
    
    List<UserModel> parsedUsers = list
        .map((i) => UserModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      // Handle both 'totalUsers' and 'totalSellers'
      totalUsers: (json['totalUsers'] ?? json['totalSellers']) as int? ?? 0,
      users: parsedUsers,
    );
  }
}
