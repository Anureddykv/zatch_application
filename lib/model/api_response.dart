// lib/model/api_response.dart (New file or add to existing model file)
import 'user_model.dart'; // Assuming UserModel is in user_model.dart

class ApiResponse {
  final bool success;
  final String message;
  final int totalUsers;
  final List<UserModel> users;

  ApiResponse({
    required this.success,
    required this.message,
    required this.totalUsers,
    required this.users,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var usersList = json['users'] as List;
    List<UserModel> parsedUsers = usersList.map((i) => UserModel.fromJson(i)).toList();

    return ApiResponse(
      success: json['success'],
      message: json['message'],
      totalUsers: json['totalUsers'],
      users: parsedUsers,
    );
  }
}

