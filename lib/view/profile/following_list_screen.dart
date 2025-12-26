import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:zatch/model/user_profile_response.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/home_page.dart';
import 'package:zatch/view/navigation_page.dart';
import 'package:zatch/view/profile/profile_screen.dart';
import 'package:zatch/view/zatch_ai_screen.dart';

class FollowingScreen extends StatefulWidget {
  final List<FollowedUser> followedUsers;
  final UserProfileResponse? userProfile;

  const FollowingScreen({
    super.key,
    required this.followedUsers,
    this.userProfile,
  });

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  bool _hasChanged = false;
  bool _isLoadingData = false;
  late List<FollowedUser> _allFollowedUsers;
  late List<FollowedUser> _filteredList;
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _loadingUsers = {};
  final Set<String> _unfollowedIds = {};

  @override
  void initState() {
    super.initState();
    // Initialize with passed data
    _allFollowedUsers = List.from(widget.followedUsers);
    _filteredList = List.from(_allFollowedUsers);
    _searchController.addListener(_filterList);
    
    // Call API to get latest data
    _refreshData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterList);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isLoadingData = true);
    try {
      final response = await ApiService().getUserProfile();
      if (mounted) {
        setState(() {
          _allFollowedUsers = response.user.following;
          _filterList(); // Re-apply current search filter if any
          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint("Error refreshing following list: $e");
      if (mounted) {
        setState(() => _isLoadingData = false);
        _showMessage("Error", "Failed to refresh list.", isError: true);
      }
    }
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _allFollowedUsers.where((user) {
        return user.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _toggleFollow(FollowedUser user) async {
    if (user.id.isEmpty) {
      _showMessage("Error", "Invalid User ID.", isError: true);
      return;
    }
    if (_loadingUsers.contains(user.id)) return;

    setState(() => _loadingUsers.add(user.id));

    try {
      final response = await ApiService().toggleFollowUser(user.id);

      if (mounted) {
        setState(() {
          _hasChanged = true;
          if (response.isFollowing) {
            _unfollowedIds.remove(user.id);
          } else {
            _unfollowedIds.add(user.id);
          }
        });
        _showMessage(response.isFollowing ? "Followed" : "Unfollowed", response.message);
      }
    } catch (e) {
      debugPrint("Error toggling follow: $e");
      _showMessage("Error", "Action failed. Please try again.", isError: true);
    } finally {
      if (mounted) {
        setState(() => _loadingUsers.remove(user.id));
      }
    }
  }

  void _viewProfile(FollowedUser user) {
    debugPrint("🔹 Navigating to profile for userId: ${user.id}");
    if (user.id.isEmpty) {
      debugPrint("❌ User ID is empty, cannot navigate");
      _showMessage("Error", "User details not found.", isError: true);
      return;
    }

    final screen = ProfileScreen(
      userId: user.id,
      onFollowToggle: (isFollowing) {
        if (mounted) {
          setState(() {
            _hasChanged = true;
            // Immediate UI update
            if (isFollowing) {
              _unfollowedIds.remove(user.id);
            } else {
              _unfollowedIds.add(user.id);
            }
          });
          // Refresh the whole list to keep it perfectly in sync with backend
          _refreshData();
        }
      },
    );

    if (homePageKey.currentState != null) {
      debugPrint("✅ Using homePageKey to navigate to sub-screen");
      homePageKey.currentState!.navigateToSubScreen(screen);
    } else {
      debugPrint("⚠️ homePageKey.currentState is null, using Navigator.push");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ).then((_) => _refreshData()); // Refresh when returning via Navigator.push
    }
  }

  void _showMessage(String title, String message, {bool isError = false}) {
    if (!mounted) return;
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 2),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        size: 28.0,
        color: Colors.white,
      ),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  void _onBack() {
    // Priority 1: Close sub-screen if we are in one managed by HomePage
    if (homePageKey.currentState != null && homePageKey.currentState!.hasSubScreen) {
      homePageKey.currentState!.closeSubScreen();
    } 
    // Priority 2: Pop standard Navigator route if this screen was 'pushed'
    else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(_hasChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF2F2F2),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: _onBack,
          ),
          title: const Text('Following',
              style: TextStyle(color: Color(0xFF121111), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _refreshData,
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Following...',
                  hintStyle: const TextStyle(color: Color(0xFF626262), fontSize: 14, fontFamily: 'Encode Sans'),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF626262)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: _isLoadingData && _allFollowedUsers.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Colors.black))
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        color: Colors.black,
                        child: _filteredList.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                                  Center(
                                    child: Text(
                                      _searchController.text.isNotEmpty ? "No users found" : "You are not following anyone yet.",
                                      style: const TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20.0),
                                itemCount: _filteredList.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredList[index];
                                  final isLoading = _loadingUsers.contains(user.id);
                                  final isFollowing = !_unfollowedIds.contains(user.id);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 24.0),
                                    child: FollowingSellerCard(
                                      user: user,
                                      isLoading: isLoading,
                                      isFollowing: isFollowing,
                                      onView: () => _viewProfile(user),
                                      onToggleFollow: () => _toggleFollow(user),
                                    ),
                                  );
                                },
                              ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FollowingSellerCard extends StatelessWidget {
  final FollowedUser user;
  final bool isLoading;
  final bool isFollowing;
  final VoidCallback onView;
  final VoidCallback onToggleFollow;

  const FollowingSellerCard({
    super.key,
    required this.user,
    required this.isLoading,
    required this.isFollowing,
    required this.onView,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = user.profilePicUrl != null && user.profilePicUrl!.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 45,
          height: 45,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.grey.shade200),
          child: hasImage
              ? Image.network(user.profilePicUrl!, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey))
              : const Icon(Icons.person, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.username,
                  style: const TextStyle(color: Color(0xFF121111), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${user.productsCount} Products',
                  style: const TextStyle(color: Color(0xFF787676), fontSize: 10, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        InkWell(
          onTap: onView,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: ShapeDecoration(
                color: const Color(0x1A000000),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('View',
                style: TextStyle(color: Colors.black, fontSize: 12, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 85,
          height: 34,
          child: ElevatedButton(
            onPressed: isLoading ? null : onToggleFollow,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              elevation: 0,
              backgroundColor: isFollowing ? Colors.white : const Color(0xFFCCF656),
              side: isFollowing ? BorderSide(color: Colors.grey.shade400) : BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: isLoading
                ? const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Text(
              isFollowing ? 'Following' : 'Follow',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: isFollowing ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
