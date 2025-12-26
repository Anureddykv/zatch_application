import 'package:flutter/material.dart';
import 'package:zatch/view/home_page.dart';
import 'package:zatch/view/profile/profile_screen.dart';
import '../controller/follower_controller.dart';
import '../view/sellers/see_all_followers_screen.dart';
import 'package:zatch/model/categories_response.dart';
import 'package:zatch/model/user_model.dart';

class FollowersWidget extends StatefulWidget {
  final Category? category;
  final Function(bool)? onLoaded; // Callback added

  const FollowersWidget({super.key, this.category, this.onLoaded});

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

  @override
  void didUpdateWidget(FollowersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category?.id != widget.category?.id || 
        oldWidget.category?.easyname != widget.category?.easyname ||
        oldWidget.category?.slug != widget.category?.slug) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (mounted && _controller.followers.isEmpty) {
      setState(() {
        _controller.isLoading = true;
      });
    }

    try {
      await _controller.fetchFollowers();
      if (mounted) {
        _notifyParent();
      }
    } catch (e) {
      debugPrint("Error fetching followers: $e");
      if (mounted) widget.onLoaded?.call(false);
    } finally {
      if (mounted) {
        setState(() {
          _controller.isLoading = false;
        });
      }
    }
  }

  void _notifyParent() {
    final List<UserModel> allFollowers = _controller.followers;
    final bool isExploreAll = widget.category == null || 
                             widget.category!.easyname?.toLowerCase() == 'explore_all' ||
                             widget.category!.name.toLowerCase() == 'explore all';

    bool hasData = false;
    if (isExploreAll) {
      hasData = allFollowers.isNotEmpty;
    } else {
      final targetFilter = (widget.category!.slug ?? widget.category!.easyname ?? widget.category!.name).toLowerCase();
      hasData = allFollowers.any((user) => user.categoryBreakdown?.containsKey(targetFilter) ?? false);
    }
    widget.onLoaded?.call(hasData);
  }

  Future<void> _handleToggleFollow(String userId, String username) async {
    setState(() {}); 

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
  Widget build(BuildContext context) {
    final List<UserModel> allFollowers = _controller.followers;
    List<UserModel> displayedFollowers;

    final bool isExploreAll = widget.category == null || 
                             widget.category!.easyname?.toLowerCase() == 'explore_all' ||
                             widget.category!.name.toLowerCase() == 'explore all';

    if (isExploreAll) {
      displayedFollowers = allFollowers;
    } else {
      final targetFilter = (widget.category!.slug ?? widget.category!.easyname ?? widget.category!.name).toLowerCase();
      displayedFollowers = allFollowers.where((user) {
        return user.categoryBreakdown?.containsKey(targetFilter) ?? false;
      }).toList();
    }

    if (!_controller.isLoading && displayedFollowers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeeAllFollowersScreen(
                          followers: displayedFollowers,
                        ),
                      ),
                    );
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
    if (_controller.isLoading && _controller.followers.isEmpty) {
      return const SizedBox(
          height: 130, child: Center(child: CircularProgressIndicator()));
    }

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

    if (!_controller.isLoading && followers.isEmpty) {
      return const SizedBox.shrink();
    }

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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => profileScreen,
                  ),
                );
              }
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
