// lib/controller/follower_controller.dart

import '../model/user_model.dart';
import '../services/api_service.dart';

// No longer extends ChangeNotifier
class FollowerController {
  final ApiService _api = ApiService();

  // State is now public, as the widget will manage it directly.
  bool isLoading = false;
  String? errorMessage;
  List<UserModel> followers = [];
  final Set<String> _loadingUserIds = {};

  // Public getter remains for the button's loading state.
  bool isButtonLoading(String userId) => _loadingUserIds.contains(userId);

  FollowerController() {
    // The widget will call fetchFollowers and handle the state change.
  }

  Future<void> fetchFollowers() async {
    isLoading = true;
    errorMessage = null;
    // `notifyListeners()` is removed.

    try {
      final response = await _api.getAllUsers();
      followers = response.users;
    } catch (e) {
      errorMessage = "Failed to load sellers: $e";
      // Re-throw the error so the widget knows the call failed.
      throw e;
    } finally {
      isLoading = false;
      // `notifyListeners()` is removed.
    }
  }

  // The method now directly returns the new follow state.
  Future<bool> toggleFollow(String userId) async {
    final userIndex = followers.indexWhere((user) => user.id == userId);
    if (userIndex == -1) throw Exception("User not found");

    final user = followers[userIndex];
    final originalIsFollowing = user.isFollowing;
    final newFollowState = !originalIsFollowing;

    _loadingUserIds.add(userId);
    followers[userIndex] = user.copyWith(isFollowing: newFollowState);

    try {
      await _api.toggleFollowUser(userId);
      return newFollowState;
    } catch (e) {
      followers[userIndex] = user.copyWith(isFollowing: originalIsFollowing);
      throw e;
    } finally {
      // Always remove from loading set
      _loadingUserIds.remove(userId);
      // `notifyListeners()` removed.
    }
  }
}
