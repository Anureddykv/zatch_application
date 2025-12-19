import 'package:flutter/material.dart';
import 'package:zatch_app/view/home_page.dart';
import 'package:zatch_app/view/profile/profile_screen.dart';
import '../controller/follower_controller.dart';
import '../view/sellers/see_all_followers_screen.dart';
import 'package:zatch_app/model/categories_response.dart';
import 'package:zatch_app/model/user_model.dart';

class FollowersWidget extends StatefulWidget {
  final Category? category;
  const FollowersWidget({super.key, this.category});

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

  // Removed didUpdateWidget since we no longer filter by category

  Future<void> _fetchData() async {
    // Only show full loading spinner if list is empty to prevent UI flickering on refresh
    if (mounted && _controller.followers.isEmpty) {
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
        setState(() {
          _controller.isLoading = false; // Ensure loading stops
        });
      }
    }
  }

  Future<void> _handleToggleFollow(String userId, String username) async {
    setState(() {}); // Optimistically update UI

    try {
      await _controller.toggleFollow(userId);
    } catch (e) {
      debugPrint("Error toggling follow: $e");
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MODIFIED: No longer filtering by category. Always show all followers.
    List<UserModel> displayedFollowers = _controller.followers;

    // Hide widget if no sellers found at all
    if (!_controller.isLoading && displayedFollowers.isEmpty && _controller.followers.isNotEmpty) {
      return const SizedBox.shrink();
    }

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
              if (displayedFollowers.length > 4)
                InkWell(
                  onTap: () async {
                    // Wait for the user to return from See All screen
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeeAllFollowersScreen(
                          followers: displayedFollowers,
                        ),
                      ),
                    );
                    // REFRESH DATA when coming back to sync changes
                    if (mounted) _fetchData();
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
          _buildSellerList(displayedFollowers),
        ],
      ),
    );
  }

  Widget _buildSellerList(List<UserModel> followers) {
    // Loading State
    if (_controller.isLoading && _controller.followers.isEmpty) {
      return const SizedBox(
          height: 130, child: Center(child: CircularProgressIndicator()));
    }

    // Error State
    if (_controller.errorMessage != null && _controller.followers.isEmpty) {
      return SizedBox(
        height: 130,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${_controller.errorMessage}',
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _fetchData, child: const Text('Retry'))
            ],
          ),
        ),
      );
    }

    // Empty State
    if (!_controller.isLoading && followers.isEmpty) {
      return const SizedBox(
          height: 130,
          child: Center(child: Text('No sellers found to explore.')));
    }

    // Data State
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: followers.length > 5 ? 5 : followers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final user = followers[index];

          final String? imageUrl = (user.profilePic.url?.isNotEmpty ?? false)
              ? user.profilePic.url
              : (user.profileImageUrl?.isNotEmpty ?? false)
              ? user.profileImageUrl
              : null;

          return GestureDetector(
            onTap: () async {
              final profileScreen = ProfileScreen(userId: user.id);
              if (homePageKey.currentState != null) {
                homePageKey.currentState!.navigateToSubScreen(profileScreen);
              } else {
                // Fallback to push if homePageKey is not available
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => profileScreen,
                  ),
                );
              }
              // REFRESH DATA when coming back to sync changes (if needed, though sub-screen is within the same page state)
              if (mounted) _fetchData();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 86,
                  height: 96,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: 85.44,
                          height: 83,
                          decoration: ShapeDecoration(
                            color: Colors.grey[300],
                            image: imageUrl != null
                                ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: imageUrl == null
                              ? Center(
                            child: Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : "S",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: InkWell(
                            onTap: _controller.isButtonLoading(user.id)
                                ? null
                                : () => _handleToggleFollow(
                                user.id, user.displayName),
                            borderRadius: BorderRadius.circular(48),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: ShapeDecoration(
                                color: user.isFollowing
                                    ? Colors.white
                                    : const Color(0xFFA2DC00),
                                shape: RoundedRectangleBorder(
                                  side: user.isFollowing
                                      ? const BorderSide(
                                      width: 1, color: Color(0xFFA2DC00))
                                      : BorderSide.none,
                                  borderRadius: BorderRadius.circular(48),
                                ),
                              ),
                              child: _controller.isButtonLoading(user.id)
                                  ? const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5))
                                  : Text(
                                user.isFollowing ? 'Following' : 'Follow',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontFamily: 'Encode Sans',
                                  fontWeight: FontWeight.w500,
                                  height: 1.50,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 85,
                  child: Text(
                    user.displayName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                    ),
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
