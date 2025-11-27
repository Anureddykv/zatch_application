import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/profile/profile_screen.dart'; // Ensure this import is correct

List<FollowedUser> _generateDummyUsers() {
  return [
    FollowedUser(
      id: 'dummy_1',
      username: 'Fashion Store',
      profilePicUrl: 'https://placehold.co/82x102',
      productsCount: 15,
    ),
    FollowedUser(
      id: 'dummy_2',
      username: 'Gadget World',
      profilePicUrl: 'https://placehold.co/71x98',
      productsCount: 42,
    ),
    FollowedUser(
      id: 'dummy_3',
      username: 'Home Decor',
      profilePicUrl: 'https://placehold.co/62x90',
      productsCount: 28,
    ),
  ];
}

class FollowingScreen extends StatefulWidget {
  final List<FollowedUser> followedUsers;

  const FollowingScreen({
    super.key,
    required this.followedUsers,
  });

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  // ✅ FIX: This flag is what we'll send back to the previous screen.
  bool _hasUnfollowed = false;
  // State variables
  late List<FollowedUser> _originalList; // The full list, for resetting search
  late List<FollowedUser> _filteredList; // The list to be displayed, after filtering
  bool _isDummyData = false;
  // ✅ FIX: Use a Set of Strings to track loading state for each user ID.
  final Set<String> _loadingUsers = {}; // Tracks loading state for each user card
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize lists based on whether real data or dummy data is needed
    if (widget.followedUsers.isEmpty) {
      _originalList = _generateDummyUsers();
      _isDummyData = true;
    } else {
      _originalList = List.from(widget.followedUsers);
      _isDummyData = false;
    }
    _filteredList = _originalList;

    // Add listener for search functionality
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterList);
    _searchController.dispose();
    super.dispose();
  }

  /// Filters the displayed list based on the search query.
  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _originalList.where((user) {
        return user.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  /// Handles the "unfollow" action, including the API call.
  Future<void> _unfollow(FollowedUser user) async {
    if (_isDummyData) {
      _showMessage("Preview Mode", "This is just a preview.", isError: true);
      return;
    }
    // ✅ FIX: Check if this specific user's ID is already in the loading set.
    if (_loadingUsers.contains(user.id)) return;

    // ✅ FIX: Add THIS user's ID to the set to trigger its loading state.
    setState(() => _loadingUsers.add(user.id));

    try {
      // Call the API to toggle the follow status
      await ApiService().toggleFollowUser(user.id);

      // If successful, update the local lists and set the flag
      setState(() {
        _originalList.removeWhere((item) => item.id == user.id);
        _filterList(); // Re-apply the filter to update the UI
        _hasUnfollowed = true; // Set the flag to notify the previous screen
      });

      _showMessage("Success", "You unfollowed ${user.username}");
    } catch (e) {
      _showMessage("Error", "Failed to unfollow. Please try again.", isError: true);
    } finally {
      // ✅ FIX: Always remove THIS user's ID from the set when done.
      if (mounted) {
        setState(() => _loadingUsers.remove(user.id));
      }
    }
  }

  /// Navigates to the selected user's profile screen.
  void _viewProfile(FollowedUser user) {
    if (_isDummyData) {
      _showMessage("Preview Mode", "This is just a preview.", isError: true);
      return;
    }
    // Navigate to the ProfileScreen, passing the tapped user's ID
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: user.id),
      ),
    );
  }

  /// Helper function to display notifications (Flushbar).
  void _showMessage(String title, String message, {bool isError = false}) {
    if (!mounted) return;
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
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

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Use WillPopScope to send a result back when the user navigates away.
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasUnfollowed);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF2F2F2),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            // ✅ FIX: The app bar back button should also send the result.
            onPressed: () => Navigator.of(context).pop(_hasUnfollowed),
          ),
          title: const Text(
            'Following',
            style: TextStyle(
              color: Color(0xFF121111),
              fontSize: 16,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Search Bar
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // List of Sellers
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Opacity(
                  opacity: _isDummyData ? 0.5 : 1.0,
                  child: _filteredList.isEmpty
                      ? Center(
                    child: Text(
                      _searchController.text.isNotEmpty
                          ? "No users found for '${_searchController.text}'"
                          : "You are not following anyone yet.",
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      final user = _filteredList[index];
                      // ✅ FIX: The check is now specific to THIS user's ID.
                      final isLoading = _loadingUsers.contains(user.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: FollowingSellerCard(
                          user: user,
                          isLoading: isLoading, // Pass the specific loading state
                          onView: () => _viewProfile(user),
                          onUnfollow: () => _unfollow(user),
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

/// Reusable card widget for each followed user.
class FollowingSellerCard extends StatelessWidget {
  final FollowedUser user;
  final bool isLoading; // Handles loading state for the unfollow action
  final VoidCallback onView;
  final VoidCallback onUnfollow;

  const FollowingSellerCard({
    super.key,
    required this.user,
    required this.isLoading,
    required this.onView,
    required this.onUnfollow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seller Image
        Container(
          width: 45,
          height: 45,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.grey.shade200,
          ),
          child: user.profilePicUrl != null && user.profilePicUrl!.isNotEmpty
              ? Image.network(
            user.profilePicUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.person, color: Colors.grey),
          )
              : const Icon(Icons.person, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        // Seller Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,
                style: const TextStyle(
                  color: Color(0xFF121111),
                  fontSize: 14,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${user.productsCount} Products',
                style: const TextStyle(
                  color: Color(0xFF787676),
                  fontSize: 10,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        // View Button
        GestureDetector(
          onTap: onView,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: ShapeDecoration(
              color: const Color(0x1A000000), // Black with 10% opacity
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('View', style: TextStyle(color: Colors.black, fontSize: 12, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500)),
          ),
        ),
        // More Options (for Unfollow)
        isLoading
            ? const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        )
            : PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'unfollow') {
              onUnfollow();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'unfollow', child: Text('Unfollow')),
          ],
          icon: const Icon(Icons.more_horiz, color: Color(0xFF292526)),
        ),
      ],
    );
  }
}
