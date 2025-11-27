// lib/view/setting_view/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/profile/following_list_screen.dart';
import 'package:zatch_app/view/profile_image_viewer.dart';

import '../../controller/live_stream_controller.dart';
import '../ReelDetailsScreen.dart';
import '../product_view/product_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfileResponse? userProfile;

  const ProfileScreen(this.userProfile, {super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87, // Darken the background
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Tap anywhere on the background to close
          child: InteractiveViewer( // This widget enables pinch-to-zoom and panning
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Hero( // This widget provides the smooth animation
                tag: imageUrl, // The tag must match the one on the CircleAvatar
                child: Image.network(imageUrl),
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final user = widget.userProfile?.user;

    final name = user?.username ?? "Unknown User";
    final followers = user?.followerCount ?? 0;
    final bool hasImage = user?.profilePic?.url != null && user?.profilePic?.url.isNotEmpty == true;
    final String profilePicUrl = hasImage
        ? user!.profilePic!.url
        : "https://via.placeholder.com/150/FFFFFF/000000?Text=No+Image"; // A default placeholder


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF9CDD1F),
      ),
      backgroundColor: const Color(0xFF9CDD1F),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Container(height: 50, width: double.infinity, color: const Color(0xFF9CDD1F)),
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
                      const SizedBox(height: 60),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(onTap: (){
                        if (user == null || !mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowingScreen(
                              followedUsers: user.following,
                            ),
                          ),
                        );
                      },
                        child: Text(
                          "$followers Sellers Following",
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ✅ Tabs
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorPadding: const EdgeInsets.all(4),
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 2,
                                spreadRadius: 0.5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.black54,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                          tabs: const [
                            Tab(text: "Saved Bits"),
                            Tab(text: "Saved Products"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Tab Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildBitsGallery(user?.savedBits ?? []),
                            _buildSavedProductsGrid(user?.savedProducts ?? []),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            top: 5,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false, // Makes the new page background transparent
                    barrierDismissible: true,
                    pageBuilder: (BuildContext context, _, __) {
                      return ProfileImageViewer(
                        imageUrl: profilePicUrl, // Pass the determined URL
                        heroTag: profilePicUrl,   // Use the URL as the unique Hero tag
                      );
                    },
                  ),
                );
              },
              child: Hero(
                tag: profilePicUrl, // Use a unique tag for the animation
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profilePicUrl),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBitsGallery(List<SavedBit> bits) {
    if (bits.isEmpty) {
      return const Center(child: Text("No saved bits to display."));
    }
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReelDetailsScreen(
              bitId: /*pick.id*/ "68a2772c675bafdd4204ef0b", // Use the real ID from the data
              controller: LiveStreamController(),
            ),
          ),
        );      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          itemCount: bits.length,
          itemBuilder: (context, index) {
            return ClipRRect(
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
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildSavedProductsGrid(List<SavedProduct> products) {
    if (products.isEmpty) {
      return const Center(child: Text("No saved products to display."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: products.map((product) {
          // Pass the entire SavedProduct object to the new stateful widget
          return _ProductCard(product: product);
        }).toList(),
      ),
    );
  }

}

/// A stateful widget for a single product card that handles its own state.
class _ProductCard extends StatefulWidget {
  final SavedProduct product;

  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  // State variables for the card
  late bool isLiked;
  bool isApiCallInProgress = false;
  final ApiService _api = ApiService();
  @override
  void initState() {
    super.initState();
    isLiked = true;
  }
  Future<void> _toggleLike() async {
    if (isApiCallInProgress) return;

    setState(() {
      isApiCallInProgress = true;
      isLiked = !isLiked;
    });

    try {
      await _api.toggleLikeProduct(widget.product.id);
    } catch (e) {
      debugPrint("Failed to toggle product like: $e");
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
      // Ensure the loading indicator is turned off
      if (mounted) {
        setState(() {
          isApiCallInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = (widget.product.images.isNotEmpty && widget.product.images.first.url.isNotEmpty)
        ? widget.product.images.first.url
        : "https://via.placeholder.com/168x140";

    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: widget.product.id),
            ),
          );
        },
        child: Container(
          width: (constraints.maxWidth - 12) / 2, // 2 cards per row
          decoration: ShapeDecoration(
            color: const Color(0xFFF4F4F4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Image.network(
                      imageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        height: 140,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  // --- Like Button ---
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: _toggleLike, // Call the API function
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: isApiCallInProgress
                            ? const Padding(
                          padding: EdgeInsets.all(6.0),
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
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        color: Color(0xFF272727),
                        fontSize: 12,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹ ${widget.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF272727),
                        fontSize: 12,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}


