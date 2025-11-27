// lib/view/profile/profile_screen.dart

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zatch_app/controller/live_stream_controller.dart';
import 'package:zatch_app/model/carts_model.dart';
import 'package:zatch_app/model/live_session_res.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/LiveDetailsScreen.dart';
import 'package:zatch_app/view/ReelDetailsScreen.dart';
import 'package:zatch_app/view/product_view/product_detail_screen.dart';
import 'package:zatch_app/view/profile_image_viewer.dart';
import 'package:zatch_app/view/zatching_details_screen.dart';

import '../../model/user_profile_response.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ["Buy Bits", "Shop", "Upcoming Live"];

  User? _userProfile;
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isSharing = false;
  bool _isFollowLoading = false;
  int _followerCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _fetchUserProfile();
  }

  void _showMessage(String title, String message, {bool isError = false}) {
    if (!mounted) return;
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.red : Colors.green,
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

  Future<void> _fetchUserProfile() async {
    if (widget.userId == null) {
      debugPrint(" No userId provided for ProfileScreen");
      if (mounted) setState(() => _isLoading = false);      return;
    }
    if (_userProfile == null) {
      if (mounted) setState(() => _isLoading = true);
    }

    debugPrint("Fetching profile for userId: ${widget.userId!}");

    try {
      final profile = await ApiService().getUserProfileById(widget.userId!);

      debugPrint("Success! Profile data received: ${profile.toString()}");
      if (mounted) {
        setState(() {
          _userProfile = profile.user;
          _isFollowing = profile.user.isFollowing ?? false;
          _followerCount = profile.user.followerCount; // Initialize follower count here
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint("Error fetching profile: $e");
      debugPrint(stackTrace.toString());
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onFollowPressed() async {
    if (widget.userId == null || _isFollowLoading) return;

    // 1. Keep the optimistic UI for the loading spinner
    setState(() {
      _isFollowLoading = true;
    });

    final originalFollowState = _isFollowing; // Store original state for error rollback

    try {
      // 2. Call the API and wait for the response
      final response = await ApiService().toggleFollowUser(widget.userId!);
 if (mounted) {
          setState(() {
            _isFollowing = response.isFollowing;
            _followerCount = response.followerCount;
          });
          // Show the message from the server response
          _showMessage(
            _isFollowing ? "Followed" : "Unfollowed",
            response.message,
          );
        }
      } catch (e) {
      debugPrint("Error toggling follow: $e");
      // 4. If the API call fails, revert to the original state
      if (mounted) {
        setState(() {
          _isFollowing = originalFollowState;
        });
        _showMessage("Error", "Action failed. Please try again.", isError: true);
      }
    } finally {
      // 5. Always stop the loading indicator
      if (mounted) {
        setState(() => _isFollowLoading = false);
      }
    }
  }
  Future<void> _onSharePressed() async {
    if (_userProfile == null) return;
    // Create a shareable link. Replace with your actual app's URL structure.
    final shareLink = "https://zatch.app/profile/${_userProfile!.id}";
    await Share.share(
        "Check out ${_userProfile!.username ?? 'this user'}'s profile on Zatch!\n$shareLink");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFA3DD00),
      ),
      backgroundColor: const Color(0xFFA3DD00),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _userProfile == null
          ? const Center(child: Text("User not found"))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final user = _userProfile!;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Container(height: 50, color: const Color(0xFFA3DD00)),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 120),
                    _buildStats(user),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildTabBar(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildBitsView(user),
                          _buildShopView(user),
                          _buildLiveView(user),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        _buildProfileHeader(user),
      ],
    );
  }

  Widget _buildProfileHeader(User user) {
    const heroTag = "profile-picture-hero";
    // Determine if the URL is valid. Use a placeholder if not.
    final hasImage = user.profilePic.url.isNotEmpty;
    final imageUrl = hasImage
        ? user.profilePic.url
        : "https://via.placeholder.com/150/FFFFFF/000000?Text=No+Image"; // A default placeholder

    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Column(
        children: [
          GestureDetector(
            // MODIFIED: This onTap will now always trigger
            onTap: () {
              if (!hasImage) return; // Prevent opening placeholder image
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  barrierDismissible: true,
                  pageBuilder: (BuildContext context, _, __) {
                    return ProfileImageViewer(
                      // Pass the determined imageUrl (real or placeholder)
                      imageUrl: imageUrl,
                      heroTag: heroTag,
                    );
                  },
                ),
              );
            },
            child: Hero(
              tag: heroTag,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  // MODIFIED: Use the determined 'hasImage' boolean
                  backgroundImage: hasImage ? NetworkImage(user.profilePic.url) : null,
                  // REMOVED: onBackgroundImageError to prevent the crash
                  // Show a placeholder icon only if there's no image
                  child: !hasImage
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.username, // Using user.username directly as it's non-nullable in the model
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(width: 6),/*
              // Conditionally show verified icon based on user data
              if (user.isVerified)*/
              const Icon(Icons.verified,
                  size: 18, color: Color(0xFFCCF656)),
            ],
          ),
          Text(
            "${_followerCount} Followers",
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(User user) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(value: "${user.customerRating} ⭐", label: "Customer Rating"),
          _StatItem(value: "${user.reviewsCount}", label: "Reviews"),
          _StatItem(value: "${user.productsSoldCount}", label: "Products Sold"),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54),
              onPressed: () {
                // This navigation is hardcoded. It should ideally use dynamic data from the user profile.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ZatchingDetailsScreen(
                      zatch: Zatch(
                        id: "3",
                        name: "Modern light clothes",
                        description: "Dress modern",
                        seller: "Neu Fashions, Hyderabad",
                        imageUrl: "https://picsum.photos/202/300",
                        active: false,
                        status: "Offer Rejected",
                        quotePrice: "212.99 ₹",
                        sellerPrice: "800 ₹",
                        quantity: 4,
                        subTotal: "800 ₹",
                        date: "Yesterday 12:00PM",
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            // ✅ UPDATED STYLE LOGIC
            style: ElevatedButton.styleFrom(
              // Change color based on the state
              backgroundColor: _isFollowing ? Colors.white : const Color(0xFFCCF656),
              foregroundColor: Colors.black, // Set text/icon color for both states
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              // Add a border only when "Following"
              side: _isFollowing
                  ? const BorderSide(color: Color(0xFFCCF656), width: 1.5)
                  : BorderSide.none,
              padding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              elevation: 2,
            ),
            onPressed: _isFollowLoading ? null : _onFollowPressed,
            child: _isFollowLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
            )
                : Text(
              _isFollowing ? "Following" : "Follow",
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
            child: IconButton(
              icon: _isSharing
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.share, color: Colors.black54),
              onPressed: _isSharing ? null : _onSharePressed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          padding: EdgeInsets.zero,
          indicatorPadding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 25.0),
          dividerColor: Colors.transparent,
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              )
            ],
          ),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey.shade700,
          labelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: _tabs.map((String name) => Tab(text: name)).toList(),
        ),
      ),
    );
  }


  /// TAB 1: Buy Bits (Saved Bits)
  Widget _buildBitsView(User user) {
    final bits = user.savedBits;

    if (bits.isEmpty) {
      return const Center(
        child: Text("No saved bits yet!", style: TextStyle(color: Colors.grey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        itemCount: bits.length,
        itemBuilder: (context, index) {
          final bit = bits[index];
          return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReelDetailsScreen(
                    bitId: bit.id, // bit.id is not nullable in the corrected model
                    controller: LiveStreamController(),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 9 / 16, // Common aspect ratio for video shorts
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const Center(
                        child: Icon(Icons.play_circle_fill, color: Colors.white54, size: 40),
                      ),
                      // Gradient overlay to make text readable
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  /// TAB 2: Shop (Selling Products)
  Widget _buildShopView(User user) {
    // This list correctly contains SavedProduct objects.
    final products = user.savedProducts;

    if (products.isEmpty) {
      return const Center(
          child: Text("No products available",
              style: TextStyle(color: Colors.grey)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        // Get the SavedProduct object.
        final SavedProduct productItem = products[index];
        // Pass the object directly to the card.
        return _ProductCard(
          product: productItem,
        );
      },
    );
  }

  /// TAB 3: Upcoming Live
  Widget _buildLiveView(User user) {
    final liveEvents = user.upcomingLives;if (liveEvents.isEmpty) {
      return const Center(
        child: Text("No live events scheduled yet!", style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 179 / 300, // Aspect ratio from Figma design (width / (image_height + text_height))
      ),
      itemCount: liveEvents.length,
      itemBuilder: (context, index) {
        final event = liveEvents[index];
        return GestureDetector(
          onTap: () {
            final session = Session(
              id: event.id,
              title: event.title,
              status: event.scheduledStartTime.toIso8601String(),
              viewersCount: 0,
              scheduledStartTime: event.scheduledStartTime.toIso8601String(),
            );

            final liveController = LiveStreamController(session: session);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LiveStreamScreen(controller: liveController, username: user.username),
              ),
            );
          },
          child: _LiveEventCard(event: event),
        );
      },
    );
  }
}
class _LiveEventCard extends StatefulWidget {
  final UpcomingLive event;

  const _LiveEventCard({required this.event});

  @override
  State<_LiveEventCard> createState() => _LiveEventCardState();
}

class _LiveEventCardState extends State<_LiveEventCard> {
  late bool isLiked;
  bool isApiCallInProgress = false;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    isLiked = false;
  }

  Future<void> _toggleLike() async {
    if (isApiCallInProgress) return;

    setState(() {
      isApiCallInProgress = true;
      isLiked = !isLiked;
    });

    try {
      await _api.toggleLike(widget.event.id);
    } catch (e) {
      debugPrint("Failed to toggle live event like: $e");
      setState(() {
        isLiked = !isLiked;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Action failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isApiCallInProgress = false;
        });
      }
    }
  }

  String _getDateLabel(DateTime eventTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventTime.year, eventTime.month, eventTime.day);

    if (eventDay == today) {
      return 'Today';
    } else if (eventDay.difference(today).inDays == 1) {
      return 'Tomorrow';
    } else {
      return DateFormat.MMMd().format(eventTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access event via widget.event in a StatefulWidget
    final formattedTime = DateFormat('h.mm a').format(widget.event.scheduledStartTime);
    final dateLabel = _getDateLabel(widget.event.scheduledStartTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  "https://picsum.photos/seed/${widget.event.id}/200/300",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(48),
                    ),
                    child: Text(
                      '$dateLabel ${formattedTime.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // 4. Updated the favorite icon to be interactive.
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _toggleLike, // Call the like function on tap
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF292526).withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      // Display a loader or an icon based on the state
                      child: isApiCallInProgress
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Live Show',
                style: TextStyle(
                  color: Color(0xFF787676),
                  fontSize: 10,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _ProductCard extends StatefulWidget {
  // Changed from Map<String, dynamic> to SavedProduct
  final SavedProduct product;

  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  late bool isLiked;
  bool isApiCallInProgress = false;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    // API response doesn't seem to include 'isLiked' for saved products,
    // so we initialize it to a default value (e.g., false or true if they are saved).
    // Let's assume saved means liked for this example.
    isLiked = true;
  }

  Future<void> _toggleLike() async {
    // Use the product's id directly from the object.
    final productId = widget.product.id;
    if (isApiCallInProgress) return;

    setState(() {
      isApiCallInProgress = true;
      isLiked = !isLiked;
    });

    try {
      // This call will add/remove the product from the user's saved list.
      await _api.toggleLikeProduct(productId);
    } catch (e) {
      debugPrint("Failed to toggle product like: $e");
      // Revert state on failure
      setState(() {
        isLiked = !isLiked;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Action failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isApiCallInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract data directly from the SavedProduct object.
    final product = widget.product;
    final imageUrl = product.images.isNotEmpty ? product.images.first.url : '';
    final title = product.name;
    final price = '₹ ${product.price.toStringAsFixed(2)}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: _toggleLike,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: isApiCallInProgress
                            ? const Padding(
                          padding: EdgeInsets.all(7.0),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                            : Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.black,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF272727),
                  fontSize: 12,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
              child: Text(
                price,
                style: const TextStyle(
                  color: Color(0xFF272727),
                  fontSize: 12,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
