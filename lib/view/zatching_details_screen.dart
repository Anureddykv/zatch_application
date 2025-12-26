import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zatch/model/bargain_model.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/home_page.dart';
import 'package:zatch/view/profile/profile_screen.dart';
import 'package:zatch/utils/snackbar_utils.dart';
import 'package:zatch/view/cart_screen.dart';

class ZatchingDetailsScreen extends StatefulWidget {
  final String bargainId;
  final Function(Widget)? onNavigate;

  const ZatchingDetailsScreen({super.key, required this.bargainId, this.onNavigate});

  @override
  State<ZatchingDetailsScreen> createState() => _ZatchingDetailsScreenState();
}

class _ZatchingDetailsScreenState extends State<ZatchingDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isActionLoading = false;
  BargainModel? _bargain;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getBargainDetails(widget.bargainId);
      if (mounted) {
        setState(() {
          _bargain = response.bargain;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarUtils.showTopSnackBar(context, "Error: $e", isError: true);
      }
    }
  }

  void _onBackTap() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    } else if (homePageKey.currentState != null) {
      homePageKey.currentState!.closeSubScreen();
    }
  }

  void _handleNavigation(Widget screen) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(screen);
    } else if (homePageKey.currentState != null) {
      homePageKey.currentState!.navigateToSubScreen(screen);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  Future<void> _handleAccept() async {
    setState(() => _isActionLoading = true);
    try {
      final success = await _apiService.acceptCounter(widget.bargainId);
      if (success && mounted) {
        SnackBarUtils.showTopSnackBar(context, "Zatch Accepted!");
        _fetchDetails();
      }
    } catch (e) {
      if (mounted) SnackBarUtils.showTopSnackBar(context, "Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _handleDecline() async {
    setState(() => _isActionLoading = true);
    try {
      final success = await _apiService.rejectCounter(widget.bargainId);
      if (success && mounted) {
        SnackBarUtils.showTopSnackBar(context, "Zatch Declined");
        _fetchDetails();
      }
    } catch (e) {
      if (mounted) SnackBarUtils.showTopSnackBar(context, "Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _handleAddToCart() async {
    final product = _bargain?.product;
    if (product == null) return;
    setState(() => _isActionLoading = true);
    try {
      await _apiService.updateCartItem(productId: product.id, quantity: _bargain!.quantity);
      if (mounted) {
        SnackBarUtils.showTopSnackBar(context, "Added to cart!");
        _handleNavigation(const CartScreen());
      }
    } catch (e) {
      if (mounted) SnackBarUtils.showTopSnackBar(context, "Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _handlePay() async {
    _handleNavigation(const CartScreen());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFFF3F4F9), body: Center(child: CircularProgressIndicator(color: Colors.black)));
    if (_bargain == null) return const Scaffold(backgroundColor: Color(0xFFF3F4F9), body: Center(child: Text("Bargain not found")));

    final seller = _bargain!.seller;
    final String timeStr = _bargain!.createdAt != null ? DateFormat('hh:mm a').format(_bargain!.createdAt!) : "Just now";

    final bool hasSellerPic = seller?.profilePic?.url != null && seller!.profilePic!.url!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F9),
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _onBackTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Color(0xFFDFDEDE)),
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleNavigation(ProfileScreen(userId: seller?.id)),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            margin: const EdgeInsets.only(top: 4, right: 8),
                            decoration: BoxDecoration(
                              color: hasSellerPic ? null : const Color(0xFFCCF656),
                              shape: BoxShape.circle,
                              image: hasSellerPic 
                                  ? DecorationImage(
                                      image: NetworkImage(seller!.profilePic!.url!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: hasSellerPic 
                                ? null 
                                : Center(
                                    child: Image.asset(
                                      "assets/images/logo.png",
                                      width: 24, // LOGO SIZE
                                      height: 24,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                seller?.username ?? "Seller Name",
                                style: const TextStyle(color: Color(0xFF121111), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600),
                              ),
                              const Text(
                                "Zatching",
                                style: TextStyle(color: Color(0xFF121111), fontSize: 12, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: [
                  _buildChatRow(
                    isMe: true,
                    child: _buildOfferCard(
                      title: "My Offer",
                      time: timeStr,
                      price: _bargain!.offeredPrice,
                      subTotal: _bargain!.offeredPrice * _bargain!.quantity,
                      isLime: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_bargain!.status == "rejected" || _bargain!.status == "expired")
                    _buildChatRow(
                      isMe: false,
                      hasSellerPic: hasSellerPic,
                      sellerPic: seller?.profilePic?.url,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusCard(
                            _bargain!.status == "rejected" ? "Offer Rejected" : "Zatch Expired",
                            timeStr,
                          ),
                          const SizedBox(height: 12),
                          _buildOfferCard(
                            title: "Original Price",
                            time: timeStr,
                            price: _bargain!.originalPrice,
                            subTotal: _bargain!.originalPrice * _bargain!.quantity,
                            isLime: false,
                            showActions: true,
                          ),
                        ],
                      ),
                    ),

                  if (_bargain!.status == "seller_countered" || _bargain!.status == "accepted")
                    _buildChatRow(
                      isMe: false,
                      hasSellerPic: hasSellerPic,
                      sellerPic: seller?.profilePic?.url,
                      child: _buildOfferCard(
                        title: _bargain!.status == "accepted" ? "Zatch Accepted" : "Seller Offer",
                        time: _bargain!.respondedAt != null ? DateFormat('hh:mm a').format(_bargain!.respondedAt!) : timeStr,
                        price: _bargain!.currentPrice,
                        subTotal: _bargain!.currentPrice * _bargain!.quantity,
                        isLime: false,
                        showActions: true,
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 6,  bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(color: Color(0xFFCCF656), shape: BoxShape.circle),
                    child: const Icon(Icons.info_outline, color: Colors.black, size: 12),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Zatches will expire in 2 business days',
                    style: TextStyle(color: Colors.black, fontSize: 13, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRow({required bool isMe, required Widget child, bool hasSellerPic = false, String? sellerPic}) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe) ...[
          Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.only(top: 4, right: 8),
            decoration: BoxDecoration(
              color: hasSellerPic ? null : const Color(0xFFCCF656),
              shape: BoxShape.circle,
              image: hasSellerPic 
                  ? DecorationImage(
                      image: NetworkImage(sellerPic!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasSellerPic 
                ? null 
                : Center(
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 24, // LOGO SIZE
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        ],
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard({
    required String title,
    required String time,
    required double price,
    required double subTotal,
    required bool isLime,
    bool showActions = false,
  }) {
    final product = _bargain!.product;
    final status = _bargain!.status;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: isLime ? const Color(0xFFCCF656) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadows: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF121111),
                  fontSize: 16,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                  height: 1.40,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: Color(0xFF787676),
                  fontSize: 10,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: NetworkImage(product?.images.isNotEmpty == true ? product!.images.first.url : "https://placehold.co/54x54"),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? "Product",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF121111), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product?.productCategory ?? "Category",
                      style: const TextStyle(color: Color(0xFF787676), fontSize: 10, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${price.toStringAsFixed(2)} ₹',
                      style: const TextStyle(color: Color(0xFF292526), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.more_horiz, size: 24, color: Color(0xFF292526)),
                  const SizedBox(height: 20),
                  Text(
                    '${_bargain!.quantity}PCS',
                    style: const TextStyle(color: Color(0xFF292526), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600, height: 1.20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Divider(color: Colors.black.withOpacity(0.10), height: 1),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sub Total',
                style: TextStyle(color: Color(0xFF292526), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400),
              ),
              Text(
                '${subTotal.toStringAsFixed(0)} ₹',
                textAlign: TextAlign.right,
                style: const TextStyle(color: Color(0xFF121111), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 16),
            if (_isActionLoading)
              const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(color: Colors.black)))
            else if (status == "seller_countered")
              Row(
                children: [
                  Expanded(child: _actionButton("Decline", Colors.white, Colors.black, _handleDecline, border: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _actionButton("Accept", const Color(0xFFCCF656), Colors.black, _handleAccept)),
                ],
              )
            else if (status == "accepted")
              Column(
                children: [
                  _actionButton("Add To Cart", Colors.white, Colors.black, _handleAddToCart, border: true),
                  const SizedBox(height: 16),
                  _actionButton("Pay", const Color(0xFFCCF656), Colors.black, _handlePay),
                ],
              )
            else if (status == "expired" || status == "rejected")
              _actionButton("Add To Cart", const Color(0xFFCCF656), Colors.black, _handleAddToCart),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(status, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Text(time, style: const TextStyle(color: Color(0xFF787676), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color bg, Color textColor, VoidCallback onTap, {bool border = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: border ? Border.all(color: Colors.black, width: 1) : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w700,
            height: 1.40,
          ),
        ),
      ),
    );
  }
}
