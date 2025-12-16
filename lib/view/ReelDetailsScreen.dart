import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:zatch_app/controller/live_stream_controller.dart';
import 'package:zatch_app/model/ExploreApiRes.dart'; // Ensure this has Comment and Reviewer models
import 'package:zatch_app/model/bit_details.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/product_view/product_detail_screen.dart';
import 'package:zatch_app/view/profile/profile_screen.dart';
import 'SidebarItem.dart';
import 'bottom_sheet/catalogue_sheet.dart';

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

  // -- Interaction State --
  bool isLiked = false;
  bool isSaved = false;
  bool _isChatMode = false; // Toggles between Product view and Chat Input view
  int likeCount = 0;

  // -- Double Tap Animation State --
  bool _showHeartAnimation = false;

  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];

  // -- Current User Info for Optimistic Comments --
  String _myUsername = "";
  String _myProfilePic = "";
  String _myUserId = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
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

  // --- Initialization ---
  Future<void> _initializeData() async {
    try {
      // 1. Fetch Current User Profile
      try {
        final userProfile = await ApiService().getUserProfile();
        if (userProfile != null) {
          _myUsername = userProfile.user.username;
          _myProfilePic = userProfile.user.profilePic?.url ?? "";
          _myUserId = userProfile.user.id ?? "";
        }
      } catch (e) {
        debugPrint("Could not fetch user profile: $e");
      }

      // 2. Fetch Bit Details
      final bitDetails = await ApiService().fetchBitDetails(widget.bitId);

      if (mounted) {
        setState(() {
          _bitDetails = bitDetails;
          likeCount = bitDetails.likeCount;
          isLiked = bitDetails.isLiked;
          isSaved = bitDetails.isSaved;
          _comments.clear();
          // Assuming we want newest comments at bottom, and API gives oldest first
          _comments.addAll(bitDetails.comments);
        });
      } else {
        return;
      }

      // 3. Init Video
      if (bitDetails.video.url?.isNotEmpty == true) {
        final videoUrl = bitDetails.video.url?.replaceFirst(
          '/upload/',
          '/upload/q_auto:good/',
        );

        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl ?? ""));
        await _videoController.initialize();
        if (mounted) {
          await _videoController.setVolume(1.0);
          _videoController.play();
          _videoController.setLooping(true);
          _isVideoInitialized = true;
        }
      } else {
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

  // --- Comment Logic ---
  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final optimisticCommentId =
    DateTime.now().millisecondsSinceEpoch.toString();

    // Create temp user object using current loaded profile
    final tempUser = Reviewer(
      id: _myUserId.isNotEmpty ? _myUserId : "temp_id",
      username: _myUsername.isNotEmpty ? _myUsername : "Me",
      profilePic: ProfilePic(url: _myProfilePic, publicId: ""),
    );

    _commentController.clear();
    // FocusScope.of(context).unfocus(); // Optional

    final optimisticComment = Comment(
      id: optimisticCommentId,
      user: tempUser,
      text: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, optimisticComment);
    });

    try {
      final serverComment =
      await ApiService().addCommentToBit(widget.bitId, text);

      if (mounted) {
        setState(() {
          final index =
          _comments.indexWhere((c) => c.id == optimisticCommentId);

          if (index != -1) {
            Comment finalComment = serverComment;

            bool serverUserIsIncomplete = serverComment.user == null ||
                (serverComment.user?.username ?? "").isEmpty ||
                (serverComment.user?.username == "User");

            if (serverUserIsIncomplete) {
              finalComment = Comment(
                id: serverComment.id,
                user: tempUser, // Keep the correct local user
                text: serverComment.text,
                createdAt: serverComment.createdAt,
              );
            } else {
              if (serverComment.user != null) {
                if (_myUsername == "Me" || _myUsername.isEmpty) {
                  _myUsername = serverComment.user!.username;
                }
                if (_myProfilePic.isEmpty &&
                    serverComment.user!.profilePic.url.isNotEmpty) {
                  _myProfilePic = serverComment.user!.profilePic.url;
                }
              }
            }
            _comments[index] = finalComment;
          } else {
            // Edge case: Comment was removed from list before server replied
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
          const SnackBar(
              content: Text("Couldn't post comment. Please try again.")),
        );
      }
    }
  }

  // --- Interaction Logic ---
  Future<void> _toggleSave() async {
    final previousState = isSaved;
    setState(() {
      isSaved = !isSaved;
    });

    try {
      final response = await ApiService().toggleSaveBit(widget.bitId);
      final serverState = response.isSaved;
      if (mounted && isSaved != serverState) {
        setState(() {
          isSaved = serverState;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSaved = previousState;
        });
      }
    }
  }

  // --- Like & Animation Logic ---
  void _triggerHeartAnimation() {
    setState(() => _showHeartAnimation = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showHeartAnimation = false);
      }
    });
  }

  void _onDoubleTapLike() {
    if (!isLiked) {
      _toggleLike();
    }
    _triggerHeartAnimation();
  }

  Future<void> _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    try {
      final result = await ApiService().toggleLike(widget.bitId);
      if (mounted && result['success'] == true) {
        setState(() {
          likeCount = result['likeCount'];
          isLiked = result['isLiked'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLiked = !isLiked;
          likeCount += isLiked ? 1 : -1;
        });
      }
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFFCCF656))),
      );
    }
    if (_bitDetails == null || !_isVideoInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Text("Failed to load.",
                style: TextStyle(color: Colors.white))),
      );
    }

    final uploadedBy = _bitDetails?.uploadedBy;
    final username = uploadedBy?.username ?? "Unknown";
    final profilePicUrl = uploadedBy?.profilePic.url;
    final products = _bitDetails?.products ?? [];

    Product? featuredProduct;
    if (products.isNotEmpty) featuredProduct = products.first;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onDoubleTap: _onDoubleTapLike,
        onTap: () {
          if (_isChatMode) {
            FocusScope.of(context).unfocus();
            setState(() => _isChatMode = false);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Video Layer
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            ),

            // 2. Gradient Layer
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(0.50, -0.00),
                  end: const Alignment(0.50, 1.00),
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),

            // 3. Heart Animation
            if (_showHeartAnimation)
              Center(
                child: AnimatedOpacity(
                  opacity: _showHeartAnimation ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.favorite, color: Colors.red, size: 120),
                ),
              ),

            // 4. MAIN UI LAYOUT
            LayoutBuilder(
              builder: (context, constraints) {
                final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

                return Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // --- TOP SECTION (Scrollable Content: Header, Chat, Sidebar) ---
                        Expanded(
                          child: SingleChildScrollView(
                            reverse: true, // Start scrolling from bottom up
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Spacer pushes content down initially
                                SizedBox(height: MediaQuery.of(context).size.height * 0.2),

                                // --- MIDDLE CONTENT (Chat & Sidebar) ---
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Chat List
                                    if (_isChatMode)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0, right: 10.0, bottom: 10),
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxHeight: 250,
                                            ),
                                            child: ShaderMask(
                                              shaderCallback: (Rect bounds) =>
                                                  const LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.white
                                                    ],
                                                    stops: [0.0, 0.3],
                                                  ).createShader(bounds),
                                              blendMode: BlendMode.dstIn,
                                              child: ListView.builder(
                                                reverse: true,
                                                padding: EdgeInsets.zero,
                                                shrinkWrap: true,
                                                physics: const ClampingScrollPhysics(),
                                                itemCount: _comments.length,
                                                itemBuilder: (context, index) =>
                                                    _buildChatMessage(_comments[index]),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      const Spacer(),

                                    // Sidebar
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 16.0, bottom: 20, left: 10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SidebarItem(
                                              icon: Icons.share,
                                              onTap: () => widget.controller
                                                  ?.share(context)),
                                          const SizedBox(height: 20),
                                          SidebarItem(
                                              icon: isLiked
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              iconColor: isLiked
                                                  ? Colors.red
                                                  : Colors.white,
                                              label: likeCount.toString(),
                                              onTap: _toggleLike),
                                          const SizedBox(height: 20),
                                          SidebarItem(
                                            icon: Icons.chat_bubble_outline,
                                            onTap: () {
                                              setState(() =>
                                              _isChatMode = !_isChatMode);
                                            },
                                            label: _comments.length.toString(),
                                          ),
                                          const SizedBox(height: 20),
                                          SidebarItem(
                                              icon: isSaved
                                                  ? Icons.bookmark
                                                  : Icons.bookmark_border,
                                              onTap: _toggleSave),
                                          const SizedBox(height: 20),
                                          SidebarItem(
                                              icon: Icons.add_shopping_cart,
                                              onTap: () =>
                                                  _showCatalogueBottomSheet(
                                                      context)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // --- BOTTOM FIXED CONTENT (Input or Product) ---
                        // This is separate from SingleChildScrollView, ensuring visibility
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                          child: _isChatMode
                              ? _buildChatInputUI()
                              : _buildProductAndBuyUI(
                              featuredProduct, products),
                        ),

                        const SizedBox(height: 10), // Bottom padding
                      ],
                    ),
                  ),
                );
              },
            ),

            // 5. TOP LEFT HEADER (Placed last in Stack to be clickable)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      // Profile Info
                      Expanded(
                        child: _buildHeaderProfile(username, profilePicUrl),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderProfile(String username, String? profilePicUrl) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final userId = _bitDetails?.uploadedBy.id;
        if (userId != null && userId.isNotEmpty) {
          _pushAndPause(ProfileScreen(userId: userId));
        } else {
          debugPrint("Cannot navigate: User ID is null");
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF7A50), width: 2),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              backgroundImage:
              (profilePicUrl != null && profilePicUrl.isNotEmpty)
                  ? NetworkImage(profilePicUrl)
                  : null,
              child: (profilePicUrl == null || profilePicUrl.isEmpty)
                  ? Text(username.isNotEmpty ? username[0].toUpperCase() : "U")
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 12),
                  const SizedBox(width: 4),
                  const Text("5.0",
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  const SizedBox(width: 8),
                  Text("${_bitDetails?.viewCount ?? 0} Views",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(Comment comment) {
    final username = comment.user?.username ?? "User";
    final profilePic = comment.user?.profilePic.url;
    final message = comment.text;
    final bool hasImage = profilePic != null && profilePic.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: ShapeDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
                side: hasImage
                    ? BorderSide.none
                    : const BorderSide(color: Colors.white54, width: 1),
              ),
              image: hasImage
                  ? DecorationImage(
                image: NetworkImage(profilePic!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: hasImage
                ? null
                : const Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$username: ",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: message,
                      style: const TextStyle(
                        color: Color(0xFF2A2A2A),
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInputUI() {
    return Container(
      key: const ValueKey('chatUI'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isChatMode = false;
                FocusScope.of(context).unfocus();
              });
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black, size: 28),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 56,
              decoration: ShapeDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        hintText: 'Comment',
                        hintStyle: TextStyle(
                            color: Color(0xFFB5B5B5), fontSize: 14),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _postComment(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _postComment,
                    child: Container(
                      width: 42,
                      height: 41,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const ShapeDecoration(
                        color: Color(0xFFCCF656),
                        shape: OvalBorder(),
                      ),
                      child:
                      const Icon(Icons.send, color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductAndBuyUI(
      Product? featuredProduct, List<Product> allProducts) {
    // Check if we need to show dummy data
    final bool useDummyData = allProducts.isEmpty;

    // If using dummy data, we will show 5 items. If real, show actual count.
    final int itemCount = useDummyData ? 5 : allProducts.length;

    final displayProducts = allProducts;

    return Container(
      key: const ValueKey('productUI'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Product',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () {
                    // FIX: Allow opening sheet even if using dummy data
                    _showCatalogueBottomSheet(context);
                  },
                  child: const Text('View all',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Product List
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (context, index) {
                // Logic to determine padding
                final padding =
                EdgeInsets.only(right: index == itemCount - 1 ? 0 : 12);

                if (useDummyData) {
                  // --- RENDER DUMMY CARD ---
                  return Padding(
                    padding: padding,
                    child: GestureDetector(
                      onTap: () {
                        // FIX: Allow opening sheet on card tap too
                        _showCatalogueBottomSheet(context);
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: _buildDummyProductCard(index),
                      ),
                    ),
                  );
                } else {
                  // --- RENDER REAL CARD ---
                  final product = displayProducts[index];
                  return Padding(
                    padding: padding,
                    child: GestureDetector(
                      onTap: () {
                        _pushAndPause(
                            ProductDetailScreen(productId: product.id ?? ""));
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: _buildProductCard(product),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // FIX: Allow opening sheet
                        _showCatalogueBottomSheet(context);
                      },
                      child: _buildActionButton(
                          "Zatch", const Color(0xFFCCF656)),
                    )),
                const SizedBox(width: 16),
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // FIX: Allow opening sheet
                        _showCatalogueBottomSheet(context);
                      },
                      child: _buildActionButton("Buy", const Color(0xFFCCF656)),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDummyProductCard(int index) {
    // Hardcoded dummy values
    final String name = "Demo Product ${index + 1}";
    final String price = "${(index + 1) * 500}";
    const String img = "https://placehold.co/95x118"; // Placeholder image

    return Container(
      height: 80,
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.20),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withOpacity(0.30)),
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 54,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 1, color: Colors.white.withOpacity(0.30)),
                borderRadius: BorderRadius.circular(14),
              ),
              image: const DecorationImage(
                image: NetworkImage(img),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Tap to view',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text('$price ₹',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final String name = product.name ?? "Product Name";
    final String price = product.price.toString();
    final bool hasImage =
        product.images.isNotEmpty && product.images.first.url.isNotEmpty;
    final String img =
    hasImage ? product.images.first.url : "https://placehold.co/95x118";

    return Container(
      height: 80,
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.20),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withOpacity(0.30)),
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 54,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 1, color: Colors.white.withOpacity(0.30)),
                borderRadius: BorderRadius.circular(14),
              ),
              image: DecorationImage(
                image: NetworkImage(img),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Tap to view',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text('$price ₹',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color borderColor) {
    return Container(
      height: 59,
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: borderColor),
              borderRadius: BorderRadius.circular(20))),
      alignment: Alignment.center,
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400)),
    );
  }

  Future<void> _showCatalogueBottomSheet(BuildContext context) async {
    // 1. Get real products
    List<Product> products = _bitDetails?.products ?? [];

    // 2. If empty, generate Dummy Products for the bottom sheet
    if (products.isEmpty) {
      products = List.generate(
          5,
              (index) => Product(
            id: "dummy_$index",
            name: "Demo Product ${index + 1}",
            price: (index + 1) * 500,
            images: [
              ProductImage(
                  url: "https://placehold.co/95x118",
                  publicId: "dummy",
                  id: '')
            ],
            description: "This is a demo product description.",
            reviews: [],
            variants: [],
            isTopPick: false,
            saveCount: 0,
            likeCount: 0,
            viewCount: 0,
            commentCount: 0,
            averageRating: 0.0,
            totalStock: 10,
          ));
    }

    if (_isVideoInitialized) _videoController.pause();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CatalogueSheet(
          products: products,
          onNavigate: (Widget page) {
            if (products.first.id?.startsWith("dummy") == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("This is a demo product")),
              );
            } else {
              _pushAndPause(page);
            }
          },
        );
      },
    );

    if (mounted && _isVideoInitialized) {
      _videoController.play();
    }
  }
}
