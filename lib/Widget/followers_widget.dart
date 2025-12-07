import 'package:flutter/material.dart';
import 'package:zatch_app/view/profile/profile_screen.dart';
import '../controller/follower_controller.dart';
import '../view/sellers/see_all_followers_screen.dart';

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
    setState(() {}); // Optimistically update UI

    try {
      await _controller.toggleFollow(userId);
      // Logic to show Flushbar if needed remains here
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
    return Container(
      // Matches the vertical padding implicitly from the height,
      // but kept flexible for the parent view.
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
                          followers: _controller.followers,
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
    if (!_controller.isLoading && _controller.followers.isEmpty) {
      return const SizedBox(
          height: 130,
          child: Center(child: Text('No sellers found to explore.')));
    }

    // Data State - Adjusted height to match Figma design (approx 114 - 130px safe area)
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Limit to 5 items for "Explore", show more in "See All"
        itemCount: _controller.followers.length > 5
            ? 5
            : _controller.followers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final user = _controller.followers[index];

          // Check if we have a valid image URL
          final String? imageUrl = (user.profilePic.url?.isNotEmpty ?? false)
              ? user.profilePic.url
              : (user.profileImageUrl?.isNotEmpty ?? false)
              ? user.profileImageUrl
              : null;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: user.id),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // This Stack replicates the Profile Image + Floating Button design
                SizedBox(
                  width: 86, // Slightly wider to accommodate button overflow if needed
                  height: 96, // Height to hold image (83) + button overhang
                  child: Stack(
                    children: [
                      // Profile Image
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: 85.44,
                          height: 83,
                          decoration: ShapeDecoration(
                            color: Colors.grey[300], // Fallback color if no image
                            image: imageUrl != null
                                ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                // Error handling is internal to image provider,
                                // but the container color acts as the visual fallback
                              },
                            )
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          // Only show initial if no image is available
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
                      // Follow/Following Button
                      Positioned(
                        bottom: 0, // Aligns bottom of button
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
                // Name Text
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
                      fontWeight: FontWeight.w400, // Adjust weight based on preference
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
