import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zatch_app/controller/live_stream_controller.dart';
import 'package:zatch_app/model/CartApiResponse.dart' as cart_model;
import 'package:zatch_app/model/carts_model.dart';
import 'package:zatch_app/model/live_comment.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/product_view/product_detail_screen.dart';
import 'package:zatch_app/view/profile/profile_screen.dart';
import 'package:zatch_app/view/setting_view/payments_shipping_screen.dart';
import 'package:zatch_app/view/zatching_details_screen.dart';


class LiveStreamScreen extends StatefulWidget {
  final LiveStreamController controller;
  final String? username;

  const LiveStreamScreen({super.key, required this.controller, this.username});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  late RtcEngine _engine;
  bool showComments = false;
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  bool isLiked = false;
  int likeCount = 0;
  Map<String, dynamic>? _sessionDetails;
  List<LiveComment> _comments = [];
  int _currentPage = 0;
  int? _remoteUid;

  String _formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else {
      double num = number / 1000.0;
      return '${num.toStringAsFixed(1)}k';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _leaveChannel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  Future<void> _initializeStream() async {
    setState(() => _isLoading = true);

    try {
      final sessionId = widget.controller.session?.id;
      if (sessionId == null || sessionId.isEmpty) throw "Missing sessionId";

      final results = await Future.wait([
        ApiService().getLiveSessionDetails(sessionId),
        ApiService().getLiveSessionComments(sessionId, limit: 20),
        ApiService().joinLiveSession(sessionId),
      ]);

      if (results[0] is Map<String, dynamic>) {
        _sessionDetails = results[0] as Map<String, dynamic>;

        if (_sessionDetails != null && _sessionDetails!.containsKey('products')) {
          final productListData = _sessionDetails!['products'] as List<dynamic>;
          final List<Product> sessionProducts = productListData
              .map((json) => Product.fromJson(json))
              .toList();
          widget.controller.products.clear();
          widget.controller.products.addAll(sessionProducts);
        }

        if (_sessionDetails != null) {
          isLiked = _sessionDetails!['isLiked'] ?? false;
          likeCount = _sessionDetails!['likeCount'] ?? 0;
        }
      }

      _comments = results[1] as List<LiveComment>;

      final joinResponse = results[2] as Map<String, dynamic>;
      final sessionData = joinResponse["session"];

      await [Permission.camera, Permission.microphone].request();

      _engine = createAgoraRtcEngine();
      await _engine.initialize(
        RtcEngineContext(
          appId: sessionData["appId"],
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("Local user ${connection.localUid} joined");
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("Remote user $remoteUid joined");
            setState(() => _remoteUid = remoteUid);
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("Remote user $remoteUid left channel");
            setState(() => _remoteUid = null);
          },
        ),
      );

      await _engine.enableVideo();
      await _engine.joinChannel(
        token: sessionData["token"],
        channelId: sessionData["channelName"],
        uid: sessionData["uid"],
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleAudience,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint("Agora initialization failed: $e");
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    final sessionId = widget.controller.session?.id;
    if (text.isEmpty || sessionId == null) return;

    final originalText = _commentController.text;
    _commentController.clear();
    FocusScope.of(context).unfocus();

    try {
      final newComment = await ApiService().postLiveComment(sessionId, text);
      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
        });
      }
    } catch (e) {
      if (mounted) {
        _commentController.text = originalText;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't post comment. Please try again.")),
        );
      }
      debugPrint("Failed to post comment: $e");
    }
  }

  Future<void> _toggleLike() async {
    final sessionId = widget.controller.session?.id;
    if (sessionId == null) return;

    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    try {
      final response = await ApiService().toggleLiveSessionLike(sessionId);
      if (mounted) {
        setState(() {
          likeCount = response['likeCount'];
          isLiked = response['hasLiked'] ?? response['isLiked'] ?? false;
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFCCF656)),
        ),
      );
    }

    final session = widget.controller.session;
    final hostName = session?.host?.username ?? "Host";
    final rating = session?.host?.rating ?? "5.0";
    final viewersCount = _sessionDetails?['viewersCount'] as int? ?? 0;
    final viewer = _sessionDetails?['views'] as int? ?? 0;
    final hostProfilePic = _sessionDetails?['host']?['profilePicUrl'] ??
        session?.host?.profilePicUrl ??
        "https://placehold.co/100x100?text=H";
    final backgroundUrl = _sessionDetails?['thumbnail'] ??
        session?.host?.profilePicUrl ??
        "https://placehold.co/428x926/333/FFF?text=Live";
    final likeIcon = isLiked ? Icons.favorite : Icons.favorite_border;

    return WillPopScope(
      onWillPop: () async {
        if (showComments) {
          setState(() => showComments = false);
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _buildBackgroundAndHostInfo(
              backgroundUrl,
              hostProfilePic,
              hostName,
              rating,
              viewersCount,
              session?.host?.id,
            ),
            _buildSidebar(likeIcon, likeCount, _comments.length),
            if (widget.controller.products.isNotEmpty) _buildProductAndChatUI(),
            if (showComments) _buildFullChatUI(),
          ],
        ),
      ),
    );
  }

  // Helper to group background and host info widgets
  Widget _buildBackgroundAndHostInfo(
      String backgroundUrl,
      String hostProfilePic,
      String hostName,
      String rating,
      int viewersCount,
      String? hostId,
      ) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            backgroundUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(color: Colors.black),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: 45,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (hostId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(userId: hostId),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(hostProfilePic),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hostName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "⭐ $rating  •  ${_formatNumber(viewersCount)}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      "${_formatNumber(viewersCount)} Live",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper for the sidebar icons
  Widget _buildSidebar(IconData likeIcon, int likeCount, int commentCount) {
    return Positioned(
      right: 15,
      bottom: 180, // Adjusted to sit above product card
      child: Column(
        children: [
          _SidebarItem(
            icon: Icons.share_outlined,
            onTap: () => widget.controller.share(context),
          ),
          const SizedBox(height: 20),
          _SidebarItem(
            icon: likeIcon,
            label: _formatNumber(likeCount),
            onTap: _toggleLike,
          ),
          const SizedBox(height: 20),
          _SidebarItem(
            icon: Icons.chat_bubble_outline,
            label: _formatNumber(commentCount),
            onTap: () => setState(() => showComments = !showComments),
          ),
          const SizedBox(height: 20),
          _SidebarItem(
            icon: Icons.add_shopping_cart_rounded,
            onTap: () => widget.controller.addToCart(context),
          ),
        ],
      ),
    );
  }


  Widget _buildProductAndChatUI() {
    final controller = widget.controller;
    final products = controller.products;

    return Stack(
      children: [
        // 1. Chat Bubbles (Floating above product)
        Positioned(
          left: 20,
          bottom: 260,
          right: 100, // Leave space for sidebar
          height: 150,
          child: IgnorePointer(
            child: ListView.builder(
              reverse: true,
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _ChatBubble(
                    user: comment.user.username,
                    message: comment.text,
                    avatarUrl: comment.user.profilePicUrl,
                  ),
                );
              },
            ),
          ),
        ),

        // 2. "Product" Label and "View All"
        Positioned(
          left: 20,
          right: 20,
          bottom: 190,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Product',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => _showCatalogueBottomSheet(context),
                child: const Text(
                  'View all',
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

        // 3. Product Card (Horizontal Scroll)
        Positioned(
          left: 0,
          right: 0,
          bottom: 100,
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              final product = products[index];
              final bool hasValidImage = product.images.isNotEmpty &&
                  product.images.first.url.isNotEmpty;
              final String productImage = hasValidImage
                  ? product.images.first.url
                  : "https://placehold.co/95x118";

              return Padding(
                padding: EdgeInsets.only(right: index == products.length - 1 ? 0 : 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                  // Matches the Container styling from your design
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 80,
                    padding: const EdgeInsets.all(10), // Padding for inner content
                    decoration: ShapeDecoration(
                      color: Colors.white.withOpacity(0.20),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignOutside,
                          color: Colors.white.withOpacity(0.30),
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Product Image
                        Container(
                          width: 54,
                          height: 54,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: Colors.white.withOpacity(0.30),
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Image.network(
                            productImage,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, _, __) => Container(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 15),

                        // Texts
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Encode Sans',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.name ?? "Category",
                                style: const TextStyle(
                                  color: Colors.white, // Design uses white for subtitle too
                                  fontSize: 10,
                                  fontFamily: 'Encode Sans',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Price
                        Text(
                          "${product.price} ₹",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Encode Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 4. Action Buttons (Zatch / Buy)
        Positioned(
          left: 30,
          right: 30,
          bottom: 25,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCatalogueBottomSheet(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(width: 1, color: Color(0xFFCCF656)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.transparent,
                  ),
                  child: const Text(
                    'Zatch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCatalogueBottomSheet(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(width: 1, color: Color(0xFFCCF656)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.transparent,
                  ),
                  child: const Text(
                    'Buy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullChatUI() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => showComments = false),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {}, // Prevents closing on tap inside
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          itemCount: _comments.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ChatBubble(
                                user: comment.user.username,
                                message: comment.text,
                                avatarUrl: comment.user.profilePicUrl,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            12, 4, 12, MediaQuery.of(context).viewInsets.bottom + 10),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () => setState(() => showComments = false),
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.black, size: 20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _commentController,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: const InputDecoration(
                                          hintText: "Comment",
                                          hintStyle: TextStyle(color: Colors.white54),
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _postComment,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFCCFF55),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.send,
                                            color: Colors.black, size: 22),
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
            ],
          ),
        ),
      ),
    );
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

  void _showCatalogueBottomSheet(BuildContext context) {
    final products = widget.controller.products;

    showModalBottomSheet(
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
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Catalogue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                // --- (FIX) Added Expanded to enable scrolling ---
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      // The rest of the card logic remains the same
                      return _buildProductCard(product);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper widget for product cards in the bottom sheet to avoid repetition
  Widget _buildProductCard(Product product) {
    return StatefulBuilder(
      builder: (context, setState) {
        String? selectedSize;
        Color? selectedColor;

        final areOptionsSelected = selectedSize != null && selectedColor != null;
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
        // In _LiveDetailsScreenState class

        void handleProceed(String action, Product product, String? selectedSize, Color? selectedColor) {
          final areOptionsSelected = selectedSize != null && selectedColor != null;

          if (!areOptionsSelected) {
            _showSelectionRequiredDialog(context);
            return;
          }

          // If options are selected, proceed based on the action
          if (action == "buy" || action == "zatch") {
            Navigator.pop(context); // Close the catalogue sheet
            _showBuyOrZatchBottomSheet(
              context,
              product,
              action,
            );
          } else if (action == "add_to_cart") {
            // This is where you would add the product to your cart state management
            print(
                "Adding to cart: ${product.name}, Size: $selectedSize, Color: $selectedColor");

            // Show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Product added to your cart!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        }


        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: product.id),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.images.isNotEmpty
                            ? product.images.first.url
                            : "https://placehold.co/95x118",
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4.5),
                          Text(
                            product.name,
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
                                product?.name ?? 'Dress modern',
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
                        const Text(
                          'Choose Size',
                          style: TextStyle(
                            color: Color(0xFF121111),
                            fontSize: 12,
                            fontFamily: 'Encode Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children:
                          availableSizes.map((s) {
                            final isSelected = selectedSize == s; // Simplified check
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap:
                                    () =>
                                    setState(() => selectedSize = s),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                    isSelected
                                        ? const Color(0xFF292526)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFDFDEDE),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      color:
                                      isSelected
                                          ? const Color(0xFFFDFDFD)
                                          : const Color(0xFF292526),
                                      fontSize: 12,
                                      fontFamily: 'Encode Sans',
                                      fontWeight:
                                      isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
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
                        const Text(
                          'Color',
                          style: TextStyle(
                            color: Color(0xFF121111),
                            fontSize: 12,
                            fontFamily: 'Encode Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                            availableColors.map((c) {
                              final isSelected = selectedColor == c;
                              return GestureDetector(
                                onTap:
                                    () =>
                                    setState(() => selectedColor = c),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:
                                    isSelected
                                        ? Border.all(
                                      color: const Color(
                                        0xFFAFE80C,
                                      ),
                                      width: 2,
                                    )
                                        : null,
                                  ),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                      border:
                                      c == Colors.white
                                          ? Border.all(
                                        color:
                                        Colors.grey.shade300,
                                      )
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
                    onTap: () => handleProceed(
                      "add_to_cart",
                      product,
                      selectedSize,
                      selectedColor,
                    ),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const ShapeDecoration(
                        shape: OvalBorder(
                          side: BorderSide(
                            width: 2,
                            color: Color(0xFFCCF656),
                          ),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          width: 2,
                          color: Color(0xFFCCF656),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () => handleProceed(
                        "buy",
                        product,
                        selectedSize,
                        selectedColor,
                      ),
                      child: const Text(
                        'Buy',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  /* const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCCF656),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () => handleProceed("zatch"),
                      child: const Text(
                        'Zatch',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                        ),
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
  }

  void _showBuyOrZatchBottomSheet(
      BuildContext context,
      Product product,
      String defaultOption,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        int quantity = 1;
        double bargainPrice = product.price;
        String selectedOption = defaultOption;

        return StatefulBuilder(
          builder: (context, setState) {
            double price = product.price;

            Widget buildCard({
              required String value,
              required String title,
              required Widget child,
            }) {
              bool isSelected = selectedOption == value;
              return GestureDetector(
                onTap: () => setState(() => selectedOption = value),
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
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
                            onChanged:
                                (val) => setState(() => selectedOption = val!),
                          ),
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      child,
                    ],
                  ),
                ),
              );
            }

            return WillPopScope(
              onWillPop: () async {
                Navigator.pop(context);
                _showCatalogueBottomSheet(this.context);
                return false;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                            _showCatalogueBottomSheet(this.context);
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Buy / Zatch",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                              product.images.first.url,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  product.name ?? "Live Item",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "${price.toStringAsFixed(2)} ₹",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed:
                                    () => setState(() {
                                  if (quantity > 1) quantity--;
                                }),
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
                                  product.images.first.url,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      product.name ?? "Live Item",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      "${price.toStringAsFixed(2)} ₹",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed:
                                        () => setState(() {
                                      if (quantity > 1) quantity--;
                                    }),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
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
                                  divisions:
                                  (price - 100).toInt() > 0
                                      ? (price - 100).toInt()
                                      : 1,
                                  onChanged:
                                      (val) =>
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
                       /* if (selectedOption == "buy") {
                          final productForCart = cart_model.ProductModel(
                            id: product.id,
                            name: product.name,
                            price: product.price,
                            discountedPrice: product.price,
                            images: product.images
                                .map((img) => cart_model.ImageModel(
                                id: img.id, publicId: img.publicId, url: img.url))
                                .toList(),
                            productType: cart_model.ProductType(
                              // Mock this data, not critical for checkout
                              hasColor: product.variants.any((v) => v.shade.isNotEmpty),// Check if any variant has a size
                              hasSize: product.variants.any((v) => v.sku != null && v.sku!.isNotEmpty),
                            ),
                          );

                          // 2. Create the correct CartItemModel object
                          final itemToCheckout = cart_model.CartItemModel(
                            id: "temp_live_${product.id}", // A temporary ID for the checkout screen
                            qty: quantity,
                            product: productForCart,
                            variant: cart_model.VariantModel(
                              // You can add selected color/size here if the live stream supports it
                              color: 'Live Item',
                            ),
                          );
                          final List<cart_model.CartItemModel> itemsForCheckout = [itemToCheckout];
                          final double itemsTotal = product.price * quantity;
                          const double shippingFee = 50.0; // Example shipping fee
                          final double subTotal = itemsTotal + shippingFee;

                          // 4. Navigate with the correctly typed list
                          Navigator.push(
                            this.context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutOrPaymentsScreen(
                                isCheckout: true,
                                selectedItems: itemsForCheckout,
                                itemsTotalPrice: itemsTotal,
                                shippingFee: shippingFee,
                                subTotalPrice: subTotal,
                              ),
                            ),
                          );
                        } */ {
                          Navigator.pushReplacement(
                            this.context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ZatchingDetailsScreen(
                                zatch: Zatch(
                                  id:
                                  "temp_${DateTime.now().millisecondsSinceEpoch}",
                                  name: product.name,
                                  description:
                                  product.description ?? "",
                                  seller:
                                  widget
                                      .controller
                                      .session
                                      ?.host
                                      ?.username ??
                                      "Seller",
                                  imageUrl: product.images.first.url,
                                  active: true,
                                  status: "My Offer",
                                  quotePrice:
                                  "${bargainPrice.toStringAsFixed(0)} ₹",
                                  sellerPrice: "",
                                  quantity: quantity,
                                  subTotal:
                                  "${(bargainPrice * quantity).toStringAsFixed(0)} ₹",
                                  date: DateTime.now().toIso8601String(),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(selectedOption == "buy" ? "Buy" : "Bargain"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSelectionRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Options Required"),
          content: const Text("Please select a size and color for the product before proceeding."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Future<void> _leaveChannel() async {
    try {
      await _engine.leaveChannel();
      await _engine.release();
    } catch (e) {
      debugPrint("Error leaving channel: $e");
    }
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.30)),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 59,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.30), width: 1),
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

class _ChatBubble extends StatelessWidget {
  final String user;
  final String message;
  final String? avatarUrl;

  const _ChatBubble({
    required this.user,
    required this.message,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundImage:
          avatarUrl != null && avatarUrl!.isNotEmpty
              ? NetworkImage(avatarUrl!)
              : null,
          child:
          (avatarUrl == null || avatarUrl!.isEmpty)
              ? Text(
            user.isNotEmpty ? user[0].toUpperCase() : 'U',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
              : null,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(18),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white, fontSize: 12),
                children: [
                  TextSpan(
                    text: '$user: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: message),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
