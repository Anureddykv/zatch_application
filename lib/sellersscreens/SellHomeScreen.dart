import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zatch_app/sellersscreens/faq_screen.dart';
import 'package:zatch_app/sellersscreens/registration/seller_registration_screen.dart';
import 'package:zatch_app/sellersscreens/sellerdashbord/SellerDashboardScreen.dart';
import 'package:zatch_app/sellersscreens/status/seller_status_screen.dart';

// Data Model for a selling benefit.
class SellBenefit {
  final String iconAsset; // Using local assets is better for icons
  final String title;
  final String description;

  SellBenefit({
    required this.iconAsset,
    required this.title,
    required this.description,
  });
}

// The main screen widget, now dynamic and responsive.
class SellHomeScreen extends StatelessWidget {
  SellHomeScreen({super.key});

  // A list of benefit data. To change the content or order, you only need to edit this list.
  final List<SellBenefit> benefits = [
    SellBenefit(
      iconAsset: "assets/icons/minutes_icon.png", // TODO: Replace with your actual asset path
      title: 'Sell in Minutes',
      description: 'Get started in minutes with our simple setup process.',
    ),
    SellBenefit(
      iconAsset: "assets/icons/bargain_icon.png", // TODO: Replace with your actual asset path
      title: 'Bargain in Real-Time',
      description: 'Let buyers fight for your\nproducts',
    ),
    SellBenefit(
      iconAsset: "assets/icons/video_icon.png", // TODO: Replace with your actual asset path
      title: 'Video-First Approach',
      description: 'Connect directly with your\nbuyers',
    ),
    SellBenefit(
      iconAsset: "assets/icons/buyer_base_icon.png", // TODO: Replace with your actual asset path
      title: 'Massive Buyer Base',
      description: 'Access India’s fastest-growing live shopping community lowest commison in the industry',
    ),
    SellBenefit(
      iconAsset: "assets/icons/commission_icon.png", // TODO: Replace with your actual asset path
      title: 'Lowest Commission',
      description: 'Lowest Commission in\nthe Industry',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // --- CODE MODIFIED HERE ---
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(134.0),
        child: _buildAppBar(),
      ),
      body: SingleChildScrollView(
        // Added bottom padding for better spacing at the end of the scroll.
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 38),
              _buildHeaderCard(),
              const SizedBox(height: 30),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: benefits.length,
                itemBuilder: (context, index) {
                  final benefit = benefits[index];
                  return BenefitCard(benefit: benefit);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 20),
              ),
              const SizedBox(height: 30),
              _buildFooterLinks(context),
              const SizedBox(height: 30),
              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for the top AppBar
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
      decoration: const ShapeDecoration(
        color: Color(0xFFCCF656),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Why Sell on Zatch?',
            style: TextStyle(
              color: Color(0xFF121111),
              fontSize: 24,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          SizedBox(
            width: 294,
            child: Text(
              'Join thousands of successful sellers and grow your business',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF121111),
                fontSize: 14,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w400,
                height: 1.40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    // Data for the scrolling images at the top of the card.
    final List<String> sellerImages = [
      "https://placehold.co/66x66/333/fff?text=S1",
      "https://placehold.co/66x66/444/fff?text=S2",
      "https://placehold.co/66x66/555/fff?text=S3",
      "https://placehold.co/66x66/666/fff?text=S4",
      "https://placehold.co/66x66/777/fff?text=S5",
      "https://placehold.co/66x66/888/fff?text=S6",
      "https://placehold.co/66x66/999/fff?text=S7",
    ];

    return Container(
      height: 255,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFF1E1E1E), // The dark background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(21),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // This SizedBox will contain the horizontally scrolling list of images.
          SizedBox(
            height: 66, // Give it a fixed height matching the images
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: sellerImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    // Using a placeholder color while images load
                    color: Colors.grey.shade800,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(sellerImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 20),
            ),
          ),
          const Text(
            'Join Successful Seller',
            style: TextStyle(
              color: Color(0xFFA2DC00),
              fontSize: 16,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(value: '1M+', label: 'Active Buyers'),
              _StatItem(value: '50k+', label: 'Sellers Earning'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 1.64,
        ),
        children: [
          const TextSpan(text: 'Still Having questions?  '),
          TextSpan(
            text: 'FAQ’s',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FaqScreen()),
                );
                print("Navigate to FAQs");
              },
          ),
        ],
      ),
    );
  }
  Widget _buildBottomActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The main button
        GestureDetector(
          onTap: () {
          /*  Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SellerRegistrationScreen()),
            );*/
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SellerDashboardScreen()),
            );
            print("Become a Seller tapped");
          },
          child: Container(
            width: double.infinity, // Takes full width of the padding
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: ShapeDecoration(
              color: const Color(0xFFCCF656),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Become a Seller',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // The terms and conditions text
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              height: 1.64,
            ),
            children: [
              const TextSpan(text: 'By continuing you are accepting all \n'),
              TextSpan(
                text: 'Terms & Conditions',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // TODO: Handle Terms & Conditions navigation
                    print("Navigate to Terms & Conditions");
                  },
              ),
            ],
          ),
        ),
        SizedBox(height: 24,)
      ],
    );
  }
}

class BenefitCard extends StatelessWidget {
  final SellBenefit benefit;
  const BenefitCard({super.key, required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: const Color(0xFFF2F4F5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 51,
            height: 51,
            decoration: const ShapeDecoration(
              color: Color(0xFFA2DC00),
              shape: OvalBorder(),
            ),
            child: Center(
              // Using Image.asset for local icons is recommended.
              child: Image.asset(
                benefit.iconAsset,
                width: 28,
                height: 28,
                // Add error handling for images
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: const TextStyle(
                    color: Color(0xFF191919),
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  benefit.description,
                  style: const TextStyle(
                    color: Color(0xFF4A5565),
                    fontSize: 15,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// A small helper widget for the stats in the header.
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
