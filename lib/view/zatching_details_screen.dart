import 'package:flutter/material.dart';
import 'package:zatch_app/model/carts_model.dart';
import 'package:zatch_app/view/cart_screen.dart';
import 'package:zatch_app/view/home_page.dart'; // Import homePageKey

class ZatchingDetailsScreen extends StatelessWidget {
  final Zatch zatch;

  const ZatchingDetailsScreen({super.key, required this.zatch});

  void _onBackTap(BuildContext context) {
    if (homePageKey.currentState != null) {
      homePageKey.currentState!.closeSubScreen();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F9),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF3F4F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => _onBackTap(context),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      zatch.imageUrl, 
                    ),
                    radius: 18,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zatch.seller ?? "Seller Name",
                      style: const TextStyle(
                        color: Color(0xFF121111),
                        fontSize: 16,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Zatching",
                      style: TextStyle(
                        color: Color(0xFF121111),
                        fontSize: 12,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 20),
                _offerCard(),
                const SizedBox(height: 24),
                if (zatch.status == "Zatch Expired") _expiredSection(context),
                if (zatch.status == "Offer Rejected")
                  _offerRejectedSection(context),
                if (zatch.status == "Seller Offer")
                  _sellerOfferSection(context),
              ],
            ),
          ),
          _bottomInfo(),
        ],
      ),
    );
  }

  /// My Offer Card
  Widget _offerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFCCF656),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Offer',
                style: TextStyle(
                  color: Color(0xFF121111),
                  fontSize: 16,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                zatch.date,
                style: const TextStyle(
                  color: Color(0xFF787676),
                  fontSize: 10,
                  fontFamily: 'Encode Sans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildProductRow(),
          const SizedBox(height: 12),
          Divider(color: Colors.black.withOpacity(0.1)),
          const SizedBox(height: 12),
          _buildSubTotalRow(zatch.subTotal),
        ],
      ),
    );
  }

  /// Expired Section
  Widget _expiredSection(BuildContext context) {
    return Column(
      children: [
        _statusBubble(
          icon: const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFCCF656),
            child: Icon(Icons.flash_on, size: 22, color: Colors.black),
          ),
          title: "Zatch Expired",
        ),
        const SizedBox(height: 12),
        _priceCard(
          "Original Price",
          showAddToCart: true,
          context: context,
        ),
      ],
    );
  }

  /// Offer Rejected Section
  Widget _offerRejectedSection(BuildContext context) {
    return Column(
      children: [
        _statusBubble(
          icon: const CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(
              "https://randomuser.me/api/portraits/men/32.jpg", 
            ),
          ),
          title: "Offer Rejected",
        ),
        const SizedBox(height: 12),
        _priceCard(
          "Original Price",
          showAddToCart: true,
          context: context,
        ),
      ],
    );
  }

  /// Seller Offer Section
  Widget _sellerOfferSection(BuildContext context) {
    return Column(
      children: [
        _statusBubble(
          icon: const CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(
              "https://randomuser.me/api/portraits/men/45.jpg", 
            ),
          ),
          title: "Seller Offer",
        ),
        const SizedBox(height: 12),
        _priceCard(
          "Seller Offer",
          showAddToCart: true,
          showPay: true,
          context: context,
        ),
      ],
    );
  }

  /// Status Bubble
  Widget _statusBubble({required Widget icon, required String title}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF121111),
                    fontSize: 16,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  zatch.date,
                  style: const TextStyle(
                    color: Color(0xFF787676),
                    fontSize: 10,
                    fontFamily: 'Encode Sans',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Price Card
  Widget _priceCard(
      String title, {
        bool showAddToCart = false,
        bool showPay = false,
        required BuildContext context,
      }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                zatch.date,
                style: const TextStyle(
                  color: Color(0xFF787676),
                  fontSize: 10,
                  fontFamily: 'Encode Sans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildProductRow(),
          const SizedBox(height: 12),
          Divider(color: Colors.black.withOpacity(0.1)),
          const SizedBox(height: 12),
          _buildSubTotalRow(
            zatch.sellerPrice.isNotEmpty ? zatch.sellerPrice : zatch.subTotal,
          ),
          const SizedBox(height: 22),
          if (showAddToCart)
            _buildButton("Add To Cart", isPrimary: showPay ? false : true,
                onPressed: () {
                  if (homePageKey.currentState != null) {
                    homePageKey.currentState!.navigateToSubScreen(const CartScreen());
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  }
                }),
          if (showPay) const SizedBox(height: 16),
          if (showPay)
            _buildButton("Pay", isPrimary: true, onPressed: () {
              // Handle Pay action
            }),
        ],
      ),
    );
  }

  /// Common Widget for Product Row
  Widget _buildProductRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            zatch.imageUrl,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zatch.name,
                style: const TextStyle(
                  color: Color(0xFF121111),
                  fontSize: 14,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                zatch.description ?? '—',
                style: const TextStyle(
                  color: Color(0xFF787676),
                  fontSize: 10,
                  fontFamily: 'Encode Sans',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                zatch.quotePrice,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(Icons.more_horiz, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              '${zatch.quantity}PCS',
              style: const TextStyle(
                color: Color(0xFF292526),
                fontSize: 14,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Common Widget for SubTotal Row
  Widget _buildSubTotalRow(String amount) {
    return Row(
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
          amount,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color(0xFF121111),
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Common Button Widget
  Widget _buildButton(String text,
      {required bool isPrimary, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isPrimary ? const Color(0xFFCCF656) : Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(width: 1, color: Colors.black),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Bottom Info Widget
  Widget _bottomInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.info_outline, size: 20, color: Colors.black),
          SizedBox(width: 8),
          Text(
            'Zatches will expire in 2 business days',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
