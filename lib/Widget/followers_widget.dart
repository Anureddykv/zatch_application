import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:zatch_app/view/profile/profile_screen.dart';
import '../controller/follower_controller.dart';
import '../view/sellers/see_all_followers_screen.dart'; // Import the model for type safety

class FollowersWidget extends StatefulWidget {
  const FollowersWidget({super.key});

  @override
  State<FollowersWidget> createState() => _FollowersWidgetState();
}

class _FollowersWidgetState extends State<FollowersWidget> {
  late final FollowerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FollowerController();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (mounted) {
      setState(() {
        _controller.isLoading = true;
      });
    }

    try {
      await _controller.fetchFollowers();
    } catch (e) {
      debugPrint("Error fetching followers: $e");
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _handleToggleFollow(String userId, String username) async {
    setState(() {}); // Optimistically update UI to show loading

    try {
      await _controller.toggleFollow(userId);
      final user = _controller.followers.firstWhere((u) => u.id == userId);
      if (mounted) {
       /* Flushbar(
          title: user.isFollowing ? "Followed" : "Unfollowed",
          message:
          "${user.isFollowing ? "You are now following" : "You have unfollowed"} $username",
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.check_circle_outline, size: 28.0, color: Colors.white),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);*/
      }
    } catch (e) {
      if (mounted) {
      }
    } finally {
      if (mounted) {
        setState(() {}); // Rebuild to remove loading spinner
      }
    }
  }

  @override
  void dispose() {
    // It's good practice to dispose of controllers if they have listeners.
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Explore Sellers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_controller.followers.length > 4)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeeAllFollowersScreen(
                          followers: _controller.followers, // Pass the full list
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSellerList(),
        ],
      ),
    );
  }

  Widget _buildSellerList() {
    // Loading State
    if (_controller.isLoading && _controller.followers.isEmpty) {
      return const SizedBox(height: 190, child: Center(child: CircularProgressIndicator()));
    }

    // Error State
    if (_controller.errorMessage != null && _controller.followers.isEmpty) {
      return SizedBox(
        height: 190,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${_controller.errorMessage}',
                  style: TextStyle(color: Colors.red[700]), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _fetchData, child: const Text('Retry'))
            ],
          ),
        ),
      );
    }

    // Empty State
    if (!_controller.isLoading && _controller.followers.isEmpty) {
      return const SizedBox(height: 190, child: Center(child: Text('No sellers found to explore.')));
    }

    // Data State
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _controller.followers.length > 5 ? 5 : _controller.followers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final user = _controller.followers[index];
          final String imageUrl = (user.profilePic.url?.isNotEmpty ?? false)
              ? user.profilePic.url!
              : (user.profileImageUrl?.isNotEmpty ?? false)
              ? user.profileImageUrl!
              : 'https://placehold.co/80x80/E0E0E0/B0B0B0?text=${user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : "S"}';

          return GestureDetector(onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(userId: user.id),
              ),
            );
          },
            child: Column(
              key: ValueKey(user.id),
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: Colors.grey[300], borderRadius: BorderRadius.circular(40)),
                      child: Icon(Icons.person_outline, color: Colors.grey[600], size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _controller.isButtonLoading(user.id)
                      ? null
                      : () => _handleToggleFollow(user.id, user.displayName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user.isFollowing ? Colors.white : const Color(0xFFB7DF4B),
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                    side: const BorderSide(color: Color(0xFFB7DF4B), width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    elevation: 0,
                    fixedSize: const Size(100, 32),
                  ),
                  child: _controller.isButtonLoading(user.id)
                      ? const SizedBox(
                      width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(user.isFollowing ? 'Following' : 'Follow',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 90,
                  child: Text(
                    user.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
