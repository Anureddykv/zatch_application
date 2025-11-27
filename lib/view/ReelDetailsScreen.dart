import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:zatch_app/controller/live_stream_controller.dart';
import 'package:zatch_app/model/ExploreApiRes.dart';
import 'package:zatch_app/model/bit_details.dart';
import 'package:zatch_app/model/carts_model.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/cart_screen.dart';
import 'package:zatch_app/view/product_view/product_detail_screen.dart';
import 'package:zatch_app/view/profile/profile_screen.dart';
import 'package:zatch_app/view/setting_view/payments_shipping_screen.dart';
import 'package:zatch_app/view/zatching_details_screen.dart';

class ReelDetailsScreen extends StatefulWidget {
  final String bitId;
  final LiveStreamController? controller;

  const ReelDetailsScreen({
    super.key,
    required this.bitId,
    this.controller,
  });

  @override
  State<ReelDetailsScreen> createState() => _ReelDetailsScreenState();
}

class _ReelDetailsScreenState extends State<ReelDetailsScreen>
    with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  bool _isLoading = true;
  bool _isVideoInitialized = false;
  BitDetails? _bitDetails;

  bool isLiked = false;
  bool isSaved = false;
  bool showComments = false;
  bool _isMuted = false;
  int likeCount = 4200;
  final TextEditingController _commentController = TextEditingController();

  final List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeReel();
  }

  Future<void> _pushAndPause(Widget page) async {
    if (_isVideoInitialized) _videoController.pause();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted && _isVideoInitialized) {
      _videoController.play();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isVideoInitialized) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _videoController.pause();
    } else if (state == AppLifecycleState.resumed) {
      _videoController.play();
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final optimisticCommentId = DateTime.now().millisecondsSinceEpoch.toString();
    FocusScope.of(context).unfocus();
    _commentController.clear();
    final optimisticComment = Comment(
      id: optimisticCommentId,
      userId: "temp_user", // A temporary user ID
      text: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, optimisticComment);
    });

    try {
      final serverComment = await ApiService().addCommentToBit(widget.bitId, text);
if (mounted) {
        setState(() {
          final index = _comments.indexWhere((c) => c.id == optimisticCommentId);
          if (index != -1) {
            _comments[index] = serverComment;
          } else {
            _comments.insert(0, serverComment);
          }
        });
      }
    } catch (e) {
      debugPrint("Failed to post comment: $e");
      if (mounted) {
        setState(() {
          _comments.removeWhere((c) => c.id == optimisticCommentId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't post comment. Please try again.")),
        );
      }
    }
  }

  Future<void> _initializeReel() async {
    try {
      final bitDetails = await ApiService().fetchBitDetails(widget.bitId);
      if (mounted) {
        setState(() {
          _bitDetails = bitDetails;
          likeCount = bitDetails.likeCount;
          isLiked = bitDetails.likeCount > 0;
          isSaved = bitDetails.saveCount > 0;
          _comments.clear();
          _comments.addAll(bitDetails.comments);
           });
      } else {
        return;
      }
      if (bitDetails.video.url.isNotEmpty) {
        final videoUrl = bitDetails.video.url.replaceFirst(
          '/upload/',
          '/upload/q_auto:good/',
        );

        _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await _videoController.initialize();
        if (mounted) {
          await _videoController.setVolume(1.0);
          _videoController.play();
          _videoController.setLooping(true);
          _isVideoInitialized = true;
        }
      } else {
        debugPrint("Video URL is empty.");
        _isVideoInitialized = false;
      }
    } catch (e) {
      debugPrint("Failed to initialize reel: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleMute() {
    if (!_isVideoInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _videoController.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }


// In _ReelDetailsScreenState class

  Future<void> _toggleSave() async {
    final previousState = isSaved;
    setState(() {
      isSaved = !isSaved;
    });

    try {
      final response = await ApiService().toggleSaveBit(widget.bitId);
      final serverState = response.isSaved;

      // ✅ PRINT THE RESPONSE
      // Assuming your response model has a toJson() method or a readable toString()
      print("Save Toggled: Server responded with: ${response.toJson()}"); // Or response.toString()

      if (mounted && isSaved != serverState) {
        setState(() {
          isSaved = serverState;
        });
      }
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(serverState ? "Saved to collection" : "Removed from collection"),
          duration: const Duration(seconds: 2),
        ),
      );*/
    } catch (e) {
      if (mounted) {
        setState(() {
          isSaved = previousState;
        });
      }
      debugPrint("Failed to update save status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't update save status. Please try again.")),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isVideoInitialized) {
      _videoController.dispose();
    }
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = _bitDetails?.products ?? [];

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_bitDetails == null || !_isVideoInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Failed to load reel.", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // ✅ FIX: Use resizeToAvoidBottomInset: false to prevent the UI from resizing when the keyboard appears.
      // The comments section will handle the adjustment itself.
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ... (Video Player, Gradient, Mute Icon, Top Bar, and Sidebar are unchanged)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMute,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: _isMuted || !_videoController.value.isPlaying ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isMuted
                      ? Icons.volume_off
                      : (_videoController.value.isPlaying
                      ? Icons.play_arrow
                      : Icons.pause),
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                _pushAndPause(ProfileScreen(userId: _bitDetails?.userId ?? ""));
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF7A50),
                        width: 2,
                      ),
                    ),
                    // In the main build() method's top bar
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(_bitDetails?.thumbnail.url ?? "..."),
                    ),

                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _bitDetails?.title ?? "Jemma Ray",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          const Text(
                            "5.0",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "${_bitDetails?.viewCount.toString()}K",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 15,
            bottom: MediaQuery.of(context).padding.bottom + 230,
            child: Column(
              children: [
                _SidebarItem(
                    icon: Icons.share_outlined,
                    onTap: () {
                      widget.controller?.share(context);
                    }),
                const SizedBox(height: 20),
                _SidebarItem(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: likeCount.toString(),
                  onTap: _toggleLike,
                ),
                const SizedBox(height: 20),
                _SidebarItem(
                  icon: Icons.chat_bubble_outline,
                  label: _comments.length.toString(),
                  onTap: () => setState(() => showComments = !showComments),
                ),
                const SizedBox(height: 20),
                _SidebarItem(
                  icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                  onTap: _toggleSave,
                ),
                const SizedBox(height: 20),
                _SidebarItem(
                  icon: Icons.add_shopping_cart_sharp,
                  onTap: () => _pushAndPause(CartScreen()),
                ),
              ],
            ),
          ),

          // ✅ RENDER EITHER PRODUCT/BUTTONS OR THE COMMENT SECTION
          // This removes the overlap and ensures only one is visible.
          if (!showComments)
            _buildProductAndActionUI(products)
          else
            _buildCommentsSection(),
        ],
      ),
    );
  }

  // ✅ WIDGET FOR PRODUCTS AND BUTTONS
  Widget _buildProductAndActionUI(List<Product> products) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        Positioned(
          left: 30,
          right: 30,
          bottom: MediaQuery.of(context).padding.bottom + 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Product",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_isVideoInitialized) _videoController.pause();
                  _showCatalogueBottomSheet(context).then((_) {
                    if (mounted && _isVideoInitialized) {
                      _videoController.play();
                    }
                  });
                },
                child: const Text(
                  "View all",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).padding.bottom + 85,
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              final product = products[index];
              final bool hasValidImage = product.images.isNotEmpty &&
                  product.images.first.url.isNotEmpty &&
                  (product.images.first.url.startsWith('http://') ||
                      product.images.first.url.startsWith('https://'));

              final String productImage = hasValidImage
                  ? product.images.first.url
                  : "https://placehold.co/95x118"; // A reliable placeholder URL

              return Padding(
                padding: EdgeInsets.only(right: index == products.length - 1 ? 0 : 12),
                child: GestureDetector(
                  onTap: () {
                    _pushAndPause(
                      ProductDetailScreen(productId: product.id ?? ""),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            productImage,
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 54,
                                height: 54,
                                color: Colors.grey[800],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.name ?? "Modern light clothes",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Encode Sans',
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                product.category?.name ?? "Dress modern",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: 'Encode Sans',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${product.price} ₹",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Encode Sans',
                            fontWeight: FontWeight.w600,
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
        Positioned(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (_isVideoInitialized) _videoController.pause();
                    _showCatalogueBottomSheet(context).then((_) {
                      if (mounted && _isVideoInitialized) {
                        _videoController.play();
                      }
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCCF656)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Zatch",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_isVideoInitialized) _videoController.pause();
                    _showCatalogueBottomSheet(context).then((_) {
                      if (mounted && _isVideoInitialized) {
                        _videoController.play();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCCF656),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Buy",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.transparent,
          // ✅ FIX: Changed from a percentage to a more compact, fixed height
          // to match the design.
          height: 380, // Previously: MediaQuery.of(context).size.height * 0.55
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.2, 0.7, 1.0],
                    ),
                  ),
                  child: ListView.builder(
                    reverse: true, // Shows newest comments at the bottom
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      // Use a temporary username format until you have real user data
                      final String username = "User ${comment.userId.substring(comment.userId.length - 4)}";
                      final userColor = _getUserColor(username);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: userColor.withOpacity(0.8),
                              child: Text(
                                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // The comment input bar remains the same
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16, 8, 16, MediaQuery.of(context).padding.bottom + 10,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => showComments = false),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        padding: const EdgeInsets.only(left: 20, right: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "Comment...",
                                  hintStyle: TextStyle(
                                    color: Color(0xFFB5B5B5),
                                    fontFamily: 'Inter',
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _postComment,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCCF656),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.send, color: Colors.black, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Color _getUserColor(String username) {
    final hash = username.hashCode;
    final colors = [
      const Color(0xC94FFFFF),
      const Color(0xC9FFC6F5),
      const Color(0xE8CDC9FF),
      Colors.red.withOpacity(0.8),
      Colors.blue.withOpacity(0.8),
      Colors.orange.withOpacity(0.8),
    ];
    return colors[hash % colors.length];
  }

  Future<void> _toggleLike() async {
    // 1. Optimistic UI Update (for immediate feedback)
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    try {
      final response = await ApiService().toggleLike(widget.bitId); // Assuming this returns a Map
      final int serverLikeCount = response['likeCount'];
      final bool serverIsLiked = response['isLiked'];

      print("Like Toggled: Server responded with count: $serverLikeCount, isLiked: $serverIsLiked");
      if (mounted) {
        setState(() {
          likeCount = serverLikeCount;
          isLiked = serverIsLiked;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLiked = !isLiked;
          likeCount += isLiked ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't update like status. Please try again.")),
        );
      }
      debugPrint("Failed to toggle like: $e");
    }
  }

  Color _getColorFromString(String colorString) {
    switch (colorString.toUpperCase()) {
      case 'BLUE':
        return Colors.blue;
      case 'BLACK':
        return Colors.black;
      case 'BEIGE':
        return const Color(0xFFF5F5DC);
      case 'RED':
        return Colors.red;
      case 'WHITE':
        return Colors.white;
      case 'DUSKY PURPLE':
        return const Color(0xFF895B8A);
      case 'GREEN':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showCatalogueBottomSheet(BuildContext context) async {
    final products = _bitDetails?.products;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.6,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                            Icons.arrow_back_ios, color: Colors.black),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Catalogue",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: products?.length ?? 0,
                    itemBuilder: (context, index) {
                      final product = products?[index];
                      if (product == null) return const SizedBox.shrink();
                      final bool hasValidImage = product.images.isNotEmpty &&
                          product.images.first.url.isNotEmpty &&
                          (product.images.first.url.startsWith('http://') ||
                              product.images.first.url.startsWith('https://'));

                      final String productImage = hasValidImage
                          ? product.images.first.url
                          : "https://placehold.co/95x118";

                      String? selectedSize;
                      Color? selectedColor;

                      final availableSizes = ["S", "M", "L", "XL"];
                      final availableColors = [
                        _getColorFromString("BLUE"),
                        _getColorFromString("BLACK"),
                        _getColorFromString("BEIGE"),
                        _getColorFromString("RED"),
                        _getColorFromString("WHITE"),
                        _getColorFromString("DUSKY PURPLE"),
                        _getColorFromString("GREEN"),
                      ];

                      return StatefulBuilder(
                        builder: (context, setState) {
                          final bool areOptionsSelected = selectedSize != null && selectedColor != null;                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: 16, left: 16, right: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _pushAndPause(
                                      ProductDetailScreen(productId: product.id ?? ""),
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          // ✅ FIX: Add safety check
                                          productImage,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 56,
                                              height: 56,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.broken_image, color: Colors.grey),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4.5),
                                            Text(
                                              product.name ?? 'Product Name',
                                              style: const TextStyle(
                                                color: Color(0xFF121111),
                                                fontSize: 14,
                                                fontFamily: 'Encode Sans',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  product.category?.name ?? 'Dress modern',
                                                  style: const TextStyle(
                                                    color: Color(0xFF787676),
                                                    fontSize: 10,
                                                    fontFamily: 'Encode Sans',
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  product.likeCount != null
                                                      ? "${product.likeCount} ⭐"
                                                      : "⭐ 5.0",
                                                  style: const TextStyle(
                                                    color: Color(0xFF121111),
                                                    fontSize: 10,
                                                    fontFamily: 'Encode Sans',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 14.0),
                                        child: Text(
                                          "${product.price.toStringAsFixed(2)} ₹",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Encode Sans',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Choose Size',
                                            style: TextStyle(
                                              color: Color(0xFF121111),
                                              fontSize: 12,
                                              fontFamily: 'Encode Sans',
                                              fontWeight: FontWeight.w700,),),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: availableSizes.map((s) {
                                              final isSelected = selectedSize?.toLowerCase() == s.toLowerCase();
                                              return Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: GestureDetector(
                                                  onTap: () => setState(() => selectedSize = s),
                                                  child: Container(
                                                    width: 26,
                                                    height: 26,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? const Color(0xFF292526)
                                                          : Colors.transparent,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: const Color(0xFFDFDEDE),
                                                        width: 1,),
                                                    ),
                                                    child: Text(s,
                                                      style: TextStyle(
                                                        color: isSelected
                                                            ? const Color(0xFFFDFDFD)
                                                            : const Color(0xFF292526),
                                                        fontSize: 12,
                                                        fontFamily: 'Encode Sans',
                                                        fontWeight: isSelected
                                                            ? FontWeight.w700
                                                            : FontWeight.w400,),),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Color',
                                            style: TextStyle(
                                              color: Color(0xFF121111),
                                              fontSize: 12,
                                              fontFamily: 'Encode Sans',
                                              fontWeight: FontWeight.w700,),),
                                          const SizedBox(height: 8),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: availableColors.map((c) {
                                                final isSelected = selectedColor == c;
                                                return GestureDetector(
                                                  onTap: () => setState(() => selectedColor = c),
                                                  child: Container(
                                                    margin: const EdgeInsets.only(right: 8),
                                                    padding: const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: isSelected
                                                          ? Border.all(
                                                        color: const Color(0xFFAFE80C),
                                                        width: 2,)
                                                          : null,
                                                    ),
                                                    child: Container(
                                                      width: 22,
                                                      height: 22,
                                                      decoration: BoxDecoration(
                                                        color: c,
                                                        shape: BoxShape.circle,
                                                        border: c == Colors.white
                                                            ? Border.all(color: Colors.grey.shade300)
                                                            : null,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                         Navigator.pop(context);
                                          _showAddToCartBottomSheet(context, product);
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const ShapeDecoration(
                                          shape: OvalBorder(side: BorderSide(
                                            width: 2,
                                            color: Color(0xFFCCF656),),),
                                        ),
                                        child: const Center(child: Icon(
                                          Icons.add_shopping_cart_sharp,
                                          color: Colors.black, size: 24,),),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Opacity(
                                        opacity: areOptionsSelected
                                            ? 1.0
                                            : 0.5,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(width: 2,
                                              color: Color(0xFFCCF656),),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(16),),
                                            minimumSize: const Size
                                                .fromHeight(50),),
                                          onPressed: () {
                                            if (areOptionsSelected) {
                                              Navigator.pop(context);
                                              _showBuyOrZatchBottomSheet(
                                                  context, product, "buy");
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Please select size and color"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Buy',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontWeight: FontWeight.w400,),),
                                        ),
                                      ),
                                    ),
                                   /* const SizedBox(width: 12),
                                    Expanded(
                                      child: Opacity(
                                        opacity: areOptionsSelected
                                            ? 1.0
                                            : 0.5,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                                0xFFCCF656),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(16),),
                                            minimumSize: const Size
                                                .fromHeight(50),),
                                          onPressed: () {
                                            if (areOptionsSelected) {
                                              Navigator.pop(context);
                                              _showBuyOrZatchBottomSheet(
                                                  context, product, "zatch");
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Please select size and color"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Zatch',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontWeight: FontWeight.w400,),),
                                        ),
                                      ),
                                    ),*/
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBuyOrZatchBottomSheet(BuildContext context, Product? product,
      String defaultOption) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int quantity = 1;
        double bargainPrice = product?.price ?? 0;
        String selectedOption = defaultOption;

        return StatefulBuilder(builder: (context, setState) {
          double price = product?.price ?? 0;
          double subTotal = selectedOption == "buy"
              ? price * quantity
              : bargainPrice * quantity;

          Widget buildCard({
            required String value,
            required String title,
            required Widget child,
          }) {
            bool isSelected = selectedOption == value;
            return Column(
              children: [
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => selectedOption = value),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                          width: isSelected ? 2 : 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              value: value,
                              groupValue: selectedOption,
                              onChanged: (val) =>
                                  setState(() => selectedOption = val!),
                            ),
                            Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        child,
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context);
              _showCatalogueBottomSheet(context);
              return false;
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                          _showCatalogueBottomSheet(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Buy / Zatch",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  buildCard(
                    value: "buy",
                    title: "Buy Product",
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            // ✅ FIX: Add safety check
                              (product?.images.isNotEmpty ?? false)
                                  ? product!.images.first.url
                                  : "https://placehold.co/100x100?text=P",
                              width: 60, height: 60, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product?.name ?? "",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const Text("Dress modern",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              Text("${price.toStringAsFixed(2)} ₹",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (quantity > 1) setState(() => quantity--);
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text("$quantity"),
                            IconButton(
                              onPressed: () => setState(() => quantity++),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  buildCard(
                    value: "zatch",
                    title: "Zatch",
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                // ✅ FIX: Add safety check
                                  (product?.images.isNotEmpty ?? false)
                                      ? product!.images.first.url
                                      : "https://placehold.co/100x100?text=P",
                                  width: 60, height: 60, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product?.name ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const Text("Dress modern",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  Text("${price.toStringAsFixed(2)} ₹",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (quantity > 1) setState(() => quantity--);
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text("$quantity"),
                                IconButton(
                                  onPressed: () => setState(() => quantity++),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text("Bargain Price"),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Slider(
                                value: bargainPrice,
                                min: 100,
                                max: price,
                                divisions: 14,
                                onChanged: (val) =>
                                    setState(() => bargainPrice = val),
                              ),
                            ),
                            Text("${bargainPrice.toStringAsFixed(0)} ₹"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCCF656),
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (selectedOption == "buy") {
                        final itemToCheckout = CartItem(
                          name: product?.name ?? "Product Name",
                          price: product?.price ?? 0.0,
                          quantity: quantity,
                          imageUrl: (product?.images.isNotEmpty ?? false)
                              ? product!.images.first.url
                              : "https://placehold.co/100x100?text=P",
                          description: product?.description ?? "",
                        );

                        double itemsTotal = itemToCheckout.price * itemToCheckout.quantity;
                        double shippingFee = 50.0;
                        double subTotalPrice = itemsTotal + shippingFee;

                        _pushAndPause(
                          CheckoutOrPaymentsScreen(isCheckout: true,
                            itemsTotalPrice: itemsTotal,
                            selectedItems: [itemToCheckout],
                            shippingFee: shippingFee,
                            subTotalPrice: subTotalPrice,),
                        );
                      } else {
                        _pushAndPause(
                          ZatchingDetailsScreen(
                            zatch: Zatch(
                              id: "temp1",
                              name: product?.name ?? '',
                              description: product?.category?.description ?? "",
                              seller: "Seller Name",
                              imageUrl: (product?.images.isNotEmpty ?? false)
                                  ? product!.images.first.url
                                  : "https://placehold.co/100x100?text=P",
                              active: true,
                              status: "My Offer",
                              quotePrice: "${bargainPrice.toStringAsFixed(0)} ₹",
                              sellerPrice: "",
                              quantity: quantity,
                              subTotal: "${(bargainPrice * quantity).toStringAsFixed(0)} ₹",
                              date: DateTime.now().toString(),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(selectedOption == "buy" ? "Buy" : "Bargain"),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

// In _ReelDetailsScreenState class...

// In _ReelDetailsScreenState class...

  void _showAddToCartBottomSheet(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int quantity = 1; // Stateful quantity for the bottom sheet

        // Use a StatefulBuilder to manage the quantity state locally
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final double subTotal = (product.price ?? 0.0) * quantity;
            final bool hasValidImage = product.images.isNotEmpty &&
                product.images.first.url.isNotEmpty &&
                (product.images.first.url.startsWith('http://') ||
                    product.images.first.url.startsWith('https://'));
            final String productImage = hasValidImage
                ? product.images.first.url
                : "https://placehold.co/95x118";

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                // Accommodate the keyboard if it appears
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // This IconButton is for visual balance; it's transparent.
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.transparent),
                        onPressed: () {},
                      ),
                      const Text(
                        'Cart',
                        style: TextStyle(
                          color: Color(0xFF121111),
                          fontSize: 18,
                          fontFamily: 'Encode Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // The actual close button
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Product Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0xFFC2C2C2)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Product Info Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                productImage,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image,
                                          color: Colors.grey),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Product Text and Quantity
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name, Category, Price
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name ?? 'Product Name',
                                          style: const TextStyle(
                                            color: Color(0xFF121111),
                                            fontSize: 14,
                                            fontFamily: 'Encode Sans',
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.category?.name ?? 'Category',
                                          style: const TextStyle(
                                            color: Color(0xFF787676),
                                            fontSize: 10,
                                            fontFamily: 'Encode Sans',
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          '${product.price?.toStringAsFixed(2) ?? '0.00'} ₹',
                                          style: const TextStyle(
                                            color: Color(0xFF292526),
                                            fontSize: 14,
                                            fontFamily: 'Encode Sans',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Quantity Selector
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Placeholder for the three-dot menu if needed
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          _buildQuantityButton(
                                            icon: Icons.remove,
                                            onTap: () {
                                              if (quantity > 1) {
                                                setState(() => quantity--);
                                              }
                                            },
                                          ),
                                          SizedBox(
                                            width: 25,
                                            child: Text(
                                              '$quantity',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Color(0xFF292526),
                                                fontSize: 14,
                                                fontFamily: 'Encode Sans',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          _buildQuantityButton(
                                            icon: Icons.add,
                                            onTap: () => setState(() => quantity++),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        // Subtotal Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sub Total',
                              style: TextStyle(
                                color: Color(0xFF292526),
                                fontSize: 14,
                                fontFamily: 'Encode Sans',
                              ),
                            ),
                            Text(
                              '${subTotal.toStringAsFixed(2)} ₹',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF121111),
                                fontSize: 14,
                                fontFamily: 'Encode Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 3. Add to Cart Button
                  GestureDetector(
                    onTap: () {
                      // Final logic to update your cart state
                      print(
                          "Confirmed: Adding $quantity x ${product.name} to cart.");

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Product has been added to your cart"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFCCF656),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Add to Cart',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Encode Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Helper widget for the quantity +/- buttons
  Widget _buildQuantityButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFDFDEDE)),
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF292526)),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // If there is NO label, it's a simple circular icon (Share, Bookmark, Cart)
    if (label == null || label!.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.30),
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      );
    }

    // If there IS a label, use the rounded rectangle container (Like, Comment)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 59,
        height: 80, // Fixed height from the design reference
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.30),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 5),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
