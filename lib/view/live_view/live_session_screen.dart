import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/ReelDetailsScreen.dart';

class LiveSessionScreen extends StatefulWidget {
  final String sessionId;
  const LiveSessionScreen({super.key, required this.sessionId});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  // --- UI State ---
  bool _isChatMode = false;

  // --- Data State ---
  bool _isLoading = true;
  Map<String, dynamic>? _sessionDetails;
  List<dynamic> _comments = [];
  List<dynamic> _products = [];
  final TextEditingController _chatController = TextEditingController();

  // --- Agora / Video State ---
  RtcEngine? _engine;
  int? _remoteUid;
  bool _isJoined = false;

  // --- Stats ---
  String _currentViewers = "0";
  String _totalViews = "0";
  String _peakViewers = "0";
  int _likeCount = 0;
  bool _isLiked = false;
  bool _showHeart = false;

  int _totalComments = 0;

  // --- Current User Info ---
  String _myUsername = "Me";
  String _myProfilePic = "";


  @override
  void initState() {
    super.initState();
    _initAgoraAndFetchData();
  }

  @override
  void dispose() {
    _disposeAgora();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _disposeAgora() async {
    await _engine?.leaveChannel();
    await _engine?.release();
  }
  Future<void> _fetchComments() async {    try {
    final commentData = await ApiService().getLiveSessionComments(widget.sessionId);
    if (mounted) {
      setState(() {
        // completely replace the list to avoid duplicates
        _comments = commentData.comments.map((c) => c.toJson()).toList();
        _totalComments = commentData.total;
      });
    }
  } catch (e) {
    debugPrint("Error refreshing comments: $e");
  }
  }

  Future<void> _initAgoraAndFetchData() async {
    await [Permission.microphone, Permission.camera].request();
    try {
      // 1. Fetch User Profile along with other data
      final userProfileFuture = ApiService().getUserProfile();
      final joinDataFuture = ApiService().joinLiveSessionWithToken(widget.sessionId);
      final detailsDataFuture = ApiService().getLiveSessionFullDetails(widget.sessionId);
      final commentsListFuture = ApiService().getLiveSessionComments(widget.sessionId);

      // Wait for all
      final results = await Future.wait([
        userProfileFuture,
        joinDataFuture,
        detailsDataFuture,
        commentsListFuture,
      ]);

      final userProfile = results[0] as dynamic; // Cast to your UserProfileResponse type if imported
      final joinData = results[1] as Map<String, dynamic>;
      final detailsData = results[2] as Map<String, dynamic>;
      final commentsList = results[3] as dynamic; // Cast to LiveCommentResponse

      final sessionData = joinData['session'];
      final String appId = sessionData['appId'];
      final String token = sessionData['token'];
      final String channelName = sessionData['channelName'];
      final int localUid = sessionData['uid'];

      if (mounted) {
        setState(() {
          // Set current user info
          _myUsername = userProfile.user.username;
          _myProfilePic = userProfile.user.profilePic.url ?? "";

          _sessionDetails = detailsData['sessionDetails'];
          _comments = commentsList.comments.map((c) => c.toJson()).toList();
          _totalComments = commentsList.total;
          _products = detailsData['sessionDetails']['products'] ?? [];
          _currentViewers = (detailsData['sessionDetails']['viewersCount'] ?? 0).toString();
          _peakViewers = (detailsData['sessionDetails']['peakViewers'] ?? 0).toString();
          final stats = detailsData['sessionDetails']['statsSummary'] ?? {};
          _totalViews = (stats['views'] ?? detailsData['sessionDetails']['views'] ?? 0).toString();
          _likeCount = detailsData['sessionDetails']['likeCount'] ?? 0;
          _isLiked = detailsData['sessionDetails']['isLiked'] ?? false;
          _isLoading = false;
        });
      }

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: appId, channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
      _engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (c, e) { if (mounted) setState(() => _isJoined = true); },
        onUserJoined: (c, uid, e) { if (mounted) setState(() => _remoteUid = uid); },
        onUserOffline: (c, uid, r) { if (mounted) setState(() => _remoteUid = null); },
      ));
      await _engine!.setClientRole(role: ClientRoleType.clientRoleAudience);
      await _engine!.enableVideo();
      await _engine!.startPreview();
      await _engine!.joinChannel(token: token, channelId: channelName, uid: localUid, options: const ChannelMediaOptions());
    } catch (e) {
      debugPrint("Error init: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    if (_chatController.text
        .trim()
        .isNotEmpty) {
      if (_chatController.text
          .trim()
          .isNotEmpty) {
        final text = _chatController.text.trim();

        _chatController.clear();
        final tempId = DateTime
            .now()
            .millisecondsSinceEpoch
            .toString();

        final tempComment = {
          '_id': tempId,
          'user': {
            'username': _myUsername,
            'profilePic': {'url': _myProfilePic}
          },
          'text': text,
          'createdAt': DateTime.now().toIso8601String(),
          'isOptimistic': true
        };
        setState(() {
          _comments.insert(0, tempComment);
        });

        try {
          await ApiService().postLiveComment(widget.sessionId, text);
          if (mounted) {
            setState(() {
              _comments.removeWhere((c) => c['_id'] == tempId);
            });
          }
          await _fetchComments();
        } catch (e) {
          debugPrint("Error sending comment: $e");
          if (mounted) {
            setState(() {
              // Remove the fake comment on error too
              _comments.removeWhere((c) => c['_id'] == tempId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to send comment")),
              );
            });
          }
        }
      }
    }
  }



  Future<void> _toggleLike() async {
    if (_isLiked) return;
    setState(() {
      _isLiked = true;
      _likeCount++;
    });
    try {
      final result = await ApiService().toggleLiveSessionLike(widget.sessionId);
      if (mounted) {
        setState(() {
          _likeCount = result['likeCount'];
          _isLiked = result['isLiked'];
          // Use result['triggerAnimation'] here if you want to show a flying heart
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = false;
          _likeCount = (_likeCount > 0) ? _likeCount - 1 : 0;
        });
      }
    }
  }
  Future<void> _onShareTap() async {
    try {
      final String link = await ApiService().shareLiveSession(widget.sessionId);
      await Share.share(link, subject: "Check out this live session on Zatch!");
    } catch (e) {
      debugPrint("Error sharing: $e");
    }
  }
  void _triggerHeartAnimation() {
    setState(() => _showHeart = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showHeart = false);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFCCF656))),
      );
    }

    final String bgImage = _sessionDetails?['thumbnail']?['url'] ?? "";
    final hostData = _sessionDetails?['host'] ?? {};
    final String hostName = (hostData['username'] ?? "Host").toString();
    final String hostPic = hostData['profilePic']?['url'] ?? "https://placehold.co/53x53";

    dynamic featuredProduct;
    if (_products.isNotEmpty) {
      featuredProduct = _products.first;
    } else {
      featuredProduct = {'name': 'Modern light clothes', 'price': 212.99, 'images': [{'url': 'https://placehold.co/95x118'}]};
    }

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onDoubleTap: (){
          _toggleLike();
          _triggerHeartAnimation();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layers 1 & 2: Video and Gradient (Unchanged)
            if (_remoteUid != null)
              AgoraVideoView(
                controller: VideoViewController.remote(rtcEngine: _engine!, canvas: VideoCanvas(uid: _remoteUid), connection: RtcConnection(channelId: _sessionDetails?['channelName'])),
              )
            else
              Image.network(bgImage, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[900])),
        
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: const Alignment(0.50, -0.00), end: const Alignment(0.50, 1.00), colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.67), Colors.black]),
              ),
            ),
            // ⭐ 3. DOUBLE TAP HEART ANIMATION (PLACE HERE)
            if (_showHeart)
              Center(
                child: AnimatedOpacity(
                  opacity: _showHeart ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 120,
                  ),
                ),
              ),
        
            // Layer 4: Main UI
            LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Top Header (Unchanged)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFigmaHostBadge(
                                  hostName, hostPic, _totalViews),
                              const Spacer(),
                              _buildFigmaLiveBadge(_currentViewers),
                            ],
                          ),
                        ),
        
                        // Middle Content: Chat List and Sidebar
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SingleChildScrollView(
                              reverse: true,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 10.0, bottom: 10),
                                      child: SizedBox(
                                        height: 250,
                                        child: ShaderMask(
                                          shaderCallback: (Rect bounds) =>
                                              const LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.white
                                                  ],
                                                  stops: [0.0, 0.3]).createShader(
                                                  bounds),
                                          blendMode: BlendMode.dstIn,
                                          child: ListView.builder(
                                            reverse: true,
                                            padding: EdgeInsets.zero,
                                            itemCount: _comments.length,
                                            itemBuilder: (context, index) =>
                                                _buildChatMessage(_comments[index]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 16.0, bottom: 20, left: 10),
                                    child: _buildRightSidebar(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
        
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<
                              double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                  begin: const Offset(0, 1), end: Offset.zero)
                                  .animate(animation),
                              child: child,
                            );
                          },
                          child: _isChatMode
                              ? _buildChatInputUI()
                              : _buildProductAndBuyUI(featuredProduct),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ],
        ),
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
          onTap: (){
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 28),
          ),
        ),
        const SizedBox(width: 10),
        // Comment Input Field
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
                    controller: _chatController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      hintText: 'Comment',
                      hintStyle: TextStyle(color: Color(0xFFB5B5B5), fontSize: 14),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendComment(),
                  ),
                ),
                // Send Button
                GestureDetector(
                  onTap: _sendComment,
                  child: Container(
                    width: 42,
                    height: 41,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const ShapeDecoration(
                      color: Color(0xFFCCF656),
                      shape: OvalBorder(),
                    ),
                    child: const Icon(Icons.send, color: Colors.black, size: 20),
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

  Widget _buildProductAndBuyUI(dynamic featuredProduct) {
    final displayProducts = _products.isNotEmpty ? _products : [featuredProduct];

    return Container(
      key: const ValueKey('productUI'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Product', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
                Text('View all', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayProducts.length,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (context, index) {
                final product = displayProducts[index];
                return Padding(
                  padding: EdgeInsets.only(right: index == displayProducts.length - 1 ? 0 : 12),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: _buildFigmaProductCard(product),
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
                Expanded(child: _buildFigmaActionButton("Zatch", const Color(0xFFCCF656))),
                const SizedBox(width: 16),
                Expanded(child: _buildFigmaActionButton("Buy", const Color(0xFFCCF656))),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRightSidebar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Share
        SidebarItem(icon: Icons.share, onTap: _onShareTap, ),
        const SizedBox(height: 20),
        // Like
        SidebarItem(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            iconColor: _isLiked ? Colors.red : Colors.white,
            label: _likeCount.toString(),
            onTap: _toggleLike
        ),        const SizedBox(height: 20),
        // Chat Bubble
        SidebarItem(
          icon: Icons.chat_bubble_outline,
          onTap: () {
            setState(() {
              _isChatMode = !_isChatMode;
            });
          },
          label: _totalComments.toString(),
        ),
        const SizedBox(height: 20),
        // Bag / Cart
        SidebarItem(icon: Icons.add_shopping_cart, onTap: () {}),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFigmaHostBadge(String name, String imgUrl, String viewCount) {
    return Container(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 59, height: 59,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFF7A50), width: 2)),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover))),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400)),
              Row(
                children: [
                  const Icon(Icons.star, size: 12, color: Colors.amber),
                  const SizedBox(width: 4),
                  const Text('5.0', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text(viewCount, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaLiveBadge(String viewers) {
    return SizedBox(
      height: 40,
      width: 125,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 34,
            width: 90,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.only(left: 8, right: 25),
            decoration: ShapeDecoration(
              color: Colors.black.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: Colors.white.withOpacity(0.20)),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(viewers, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: const Color(0xFFF5153D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              alignment: Alignment.center,
              child: const Text('Live', style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaProductCard(dynamic product) {
    final String name = (product['name'] ?? "Featured Product").toString();
    final String price = (product['price'] ?? 0).toString();
    final String img = (product['images'] != null && product['images'].isNotEmpty)
        ? product['images'][0]['url']
        : "https://placehold.co/95x118";

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
            width: 54, height: 54,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: Colors.white.withOpacity(0.30)),
                borderRadius: BorderRadius.circular(14),
              ),
              image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Tap to view', style: TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text('$price ₹', style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaActionButton(String text, Color borderColor) {
    return Container(
      height: 59,
      decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: BorderSide(width: 1, color: borderColor), borderRadius: BorderRadius.circular(20))),
      alignment: Alignment.center,
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400)),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> chat) {
    final userObj = chat['user'] is Map ? chat['user'] : {};
    final username = (userObj['username'] as String?)
        ?? (chat['username'] as String?)
        ?? "User";
    String? profilePic;
    if (userObj['profilePic'] is Map) {
      profilePic = userObj['profilePic']['url'];
    } else if (userObj['profilePicUrl'] != null) {
      profilePic = userObj['profilePicUrl'];
    } else if (chat['profilePicUrl'] != null) {
      profilePic = chat['profilePicUrl'];
    }
    final message = chat['text'] ?? "";
    final bool hasImage = profilePic != null && profilePic.toString().isNotEmpty;

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
                side: hasImage ? BorderSide.none : const BorderSide(color: Colors.white54, width: 1),
              ),
              image: hasImage
                  ? DecorationImage(
                image: NetworkImage(profilePic),
                fit: BoxFit.fill,
                onError: (exception, stackTrace) { debugPrint("Error loading profile pic: $exception"); },
              )
                  : null,
            ),
            child: hasImage ? null : const Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "$username: ", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                    TextSpan(text: message, style: const TextStyle(color: Color(0xFF2A2A2A), fontSize: 14, fontFamily: 'Plus Jakarta Sans')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
