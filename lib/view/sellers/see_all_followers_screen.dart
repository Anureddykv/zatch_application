import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:zatch_app/controller/follower_controller.dart';
import 'package:zatch_app/model/user_model.dart';
import 'package:zatch_app/view/profile/profile_screen.dart';

class SeeAllFollowersScreen extends StatefulWidget {
  final List<UserModel> followers;

  const SeeAllFollowersScreen({
    super.key,
    required this.followers,
  });

  @override
  State<SeeAllFollowersScreen> createState() => _SeeAllFollowersScreenState();
}

class _SeeAllFollowersScreenState extends State<SeeAllFollowersScreen> {
  // Use a local controller to manage state changes for follow/unfollow actions.
  late final FollowerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller and set its followers list from the widget's properties.
    _controller = FollowerController();
    _controller.followers = List<UserModel>.from(widget.followers);
  }

  // --- CORRECTED METHOD ---
  // This method now correctly handles the state updates without errors.
  Future<void> _handleToggleFollow(String userId, String username) async {
    // Call setState once to trigger a rebuild, which will show the loading indicator
    // based on the controller's internal state, which is updated inside toggleFollow.
    setState(() {});

    try {
      await _controller.toggleFollow(userId);

      // The controller's list is updated optimistically, so we can find the user
      // and show the correct status in the feedback message.
      final user = _controller.followers.firstWhere((u) => u.id == userId);

      if (mounted) {
        Flushbar(
          title: user.isFollowing ? "Followed" : "Unfollowed",
          message:
          "${user.isFollowing ? "You are now following" : "You have unfollowed"} $username",
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.check_circle_outline, size: 28.0, color: Colors.white),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    } catch (e) {
      debugPrint("Error toggling follow on SeeAllFollowersScreen: $e");
      // If an error occurs, show feedback to the user.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update follow status for $username.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Rebuild the UI to reflect the final state (removes loading spinner
      // or reverts the follow state if there was an error).
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Sellers'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.75, // Adjust this value to fit your card design
        ),
        itemCount: _controller.followers.length,
        itemBuilder: (context, index) {
          final user = _controller.followers[index];
          // Pass the user data to the card builder method.
          return _buildSellerCard(user);
        },
      ),
    );
  }

  // A card widget built directly inside this screen for easy state management.
  Widget _buildSellerCard(UserModel user) {
    final String imageUrl = (user.profilePic.url?.isNotEmpty ?? false)
        ? user.profilePic.url!
        : (user.profileImageUrl?.isNotEmpty ?? false)
        ? user.profileImageUrl!
        : 'https://placehold.co/150x150/E0E0E0/B0B0B0?text=${user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : "S"}';

    // This check is correct and uses the public method from your controller.
    final bool isLoading = _controller.isButtonLoading(user.id);

    return GestureDetector(
      onTap: () {
        // Navigate to the user's profile screen when the card is tapped.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: user.id),
          ),
        );
      },
      child: Container(
        key: ValueKey(user.id),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Image
            ClipRRect(
              borderRadius: BorderRadius.circular(50), // Circular image
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(Icons.person_outline, color: Colors.grey[600], size: 50),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Display Name
            SizedBox(
              width: double.infinity,
              child: Text(
                user.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Follow/Following Button
            ElevatedButton(
              onPressed: isLoading
                  ? null // Disable button while loading
                  : () => _handleToggleFollow(user.id, user.displayName),
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isFollowing ? Colors.white : const Color(0xFFB7DF4B),
                foregroundColor: Colors.black,
                shape: const StadiumBorder(),
                side: const BorderSide(color: Color(0xFFB7DF4B), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                elevation: 0,
                minimumSize: const Size(120, 36),
              ),
              child: isLoading
                  ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                user.isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
