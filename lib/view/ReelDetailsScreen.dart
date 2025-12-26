import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:zatch/controller/live_stream_controller.dart';
import 'package:zatch/model/ExploreApiRes.dart'; // Ensure this has Comment and Reviewer models
import 'package:zatch/model/bit_details.dart';
import 'package:zatch/model/product_response.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/product_view/product_detail_screen.dart';
import 'package:zatch/view/profile/profile_screen.dart';
import 'package:zatch/view/cart_screen.dart';
import 'package:zatch/utils/snackbar_utils.dart';
import 'package:zatch/view/home_page.dart';
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
  final ApiService _apiService = ApiService();

  // -- Interaction State --
  bool isLiked = false;
  bool isSaved = false;
  bool _isChatMode = false; // Toggles between Product view and Chat Input view
  int likeCount = 0;
  int cartItemCount = 0;

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
    _fetchCartCount();
  }

  Future<void> _fetchCartCount() async {
    try {
      final cart = await _apiService.getCart();
      if (mounted) {
        setState(() {
          cartItemCount = cart?.totalItems ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching cart count: $e");
    }
  }

  void _handleNavigation(Widget page, {bool replace = false}) {
    if (_isVideoInitialized) _videoController.pause();

    if (homePageKey.currentState != null) {
      // If ReelDetailsScreen was pushed via Navigator.push (full screen), 
      // pop it first to reveal HomePage underneath which has the bottom bar.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (replace) {
        homePageKey.currentState!.replaceSubScreen(page);
      } else {
        homePageKey.currentState!.navigateToSubScreen(page);
      }
    } else {
      if (replace) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) {
          _fetchCartCount();
          if (mounted && _isVideoInitialized) {
            _videoController.play();
          }
        });
      }
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

    final tempUser = Reviewer(
      id: _myUserId.isNotEmpty ? _myUserId : "temp_id",
      username: _myUsername.isNotEmpty ? _myUsername : "Me",
      profilePic: ProfilePic(url: _myProfilePic, publicId: ""),
    );

    _commentController.clear();

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
                user: tempUser, 
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
        SnackBarUtils.showTopSnackBar(context, "Couldn't post comment. Please try again.", isError: true);
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

  Widget _buildCircleIcon(IconData icon, VoidCallback onTap, {int badgeCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
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
                    Colors.black.withOpacity(1.0),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
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
                        Expanded(
                          child: SingleChildScrollView(
                            reverse: true,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
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

                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 16.0, bottom: 20, left: 10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SidebarItem(
                                              icon: Icons.share,
                                              onTap: () async {
                                                try {
                                                  final shareLink = await _apiService.shareBit(_bitDetails?.id ??"");
                                                  await Share.share("${shareLink.primaryText}");
                                                } catch (e) {
                                                  SnackBarUtils.showTopSnackBar(context, "Failed to share: $e", isError: true);
                                                }
                                              }),
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

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),

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
          _handleNavigation(ProfileScreen(userId: userId));
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
    if (allProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    final int itemCount = allProducts.length;
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

          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (context, index) {
                final padding =
                EdgeInsets.only(right: index == itemCount - 1 ? 0 : 12);
                final product = displayProducts[index];
                return Padding(
                  padding: padding,
                  child: GestureDetector(
                    onTap: () {
                      _handleNavigation(
                          ProductDetailScreen(
                            productId: product.id ?? "",
                            onNavigate: (page) => _handleNavigation(page),
                          ));
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: _buildProductCard(product),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showCatalogueBottomSheet(context);
                      },
                      child: _buildActionButton(
                          "Zatch", const Color(0xFFCCF656)),
                    )),
                const SizedBox(width: 16),
                Expanded(
                    child: GestureDetector(
                      onTap: () {
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

  Widget _buildProductCard(Product product) {
    final String name = product.name ?? "Featured Product";
    final bool hasDiscount = product.discountedPrice != null && product.discountedPrice! < product.price;
    final String priceToShow = hasDiscount ? product.discountedPrice!.toStringAsFixed(2) : product.price.toStringAsFixed(2);
    final String originalPrice = product.price.toStringAsFixed(2);
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$priceToShow ₹',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w600)),
                if (hasDiscount)
                  Text('$originalPrice ₹',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'Encode Sans',
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          decorationThickness: 2.0)),
              ],
            ),
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
    List<Product> products = _bitDetails?.products ?? [];

    if (products.isEmpty) {
      SnackBarUtils.showTopSnackBar(context, "No products available for this reel.", isError: true);
      return;
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
            _handleNavigation(page);
          },
        );
      },
    );

    if (mounted && _isVideoInitialized) {
      _videoController.play();
    }
  }
}
