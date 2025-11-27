import 'package:flutter/material.dart';
// Import the coupon model file
import 'package:zatch_app/model/coupon_model.dart';

class CouponApplyScreen extends StatefulWidget {
  const CouponApplyScreen({super.key});

  @override
  State<CouponApplyScreen> createState() => _CouponApplyScreenState();
}

class _CouponApplyScreenState extends State<CouponApplyScreen> {
  // --- Data ---
  static final List<Coupon> _coupons = [
    Coupon(code: "ZATCH25", description: "Christmas Sale", discountPercentage: 25.0),
    Coupon(code: "NEWYEAR20", description: "New Year Special", discountPercentage: 20.0),
    Coupon(code: "FIRSTBUY", description: "First Time User", discountPercentage: 15.0),
  ];

  final TextEditingController _couponController = TextEditingController();

  // --- STATE MANAGEMENT ---
  Coupon? _selectedCoupon;
  bool _isNavigating = false;

  // --- LOGIC (No changes needed here, it's already correct) ---

  void _confirmAndNavigate() {
    if (_isNavigating) return;
    setState(() { _isNavigating = true; });
    Navigator.pop(context, _selectedCoupon);
  }

  void _applyCouponFromInput(String code) {
    if (code.isEmpty) {
      _showSnackBar("Please enter a coupon code.", isError: true);
      return;
    }
    final enteredCode = code.toUpperCase();
    try {
      final foundCoupon = _coupons.firstWhere((c) => c.code.toUpperCase() == enteredCode);
      setState(() {
        _selectedCoupon = foundCoupon;
      });
      _showSnackBar("Coupon '${foundCoupon.code}' selected!");
    } catch (e) {
      _showSnackBar("Invalid coupon code.", isError: true);
    }
  }

  void _selectCouponFromCard(Coupon coupon) {
    setState(() {
      if (_selectedCoupon?.code == coupon.code) {
        _selectedCoupon = null; // Deselect
      } else {
        _selectedCoupon = coupon; // Select
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  // --- UI BUILD METHOD (Updated for new Figma Design) ---

  @override
  Widget build(BuildContext context) {
    final String buttonText = _selectedCoupon != null ? "Apply Coupon" : "Continue";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F9),
      appBar: AppBar(
        title: const Text(
          "Apply Coupon", // Title from Figma
          style: TextStyle(
            color: Color(0xFF121111),
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'Encode Sans',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: _isNavigating ? null : () => Navigator.pop(context, null),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 20),
                children: [
                  _buildCouponInputField(),
                  const SizedBox(height: 30),
                  _buildCouponCarousel(), // Horizontal list of new cards
                ],
              ),
            ),
            _buildConfirmationButton(buttonText),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: TextField(
        controller: _couponController,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: "Enter Coupon Code",
          hintStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.07,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          suffixIcon: TextButton(
            onPressed: _isNavigating ? null : () => _applyCouponFromInput(_couponController.text),
            child: const Text(
              "Apply",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.07,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCouponCarousel() {
    // This is the horizontally scrolling list of coupon cards
    return SizedBox(
      height: 280, // Adjusted height to fit new card design
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        itemCount: _coupons.length,
        itemBuilder: (context, index) {
          final coupon = _coupons[index];
          final bool isSelected = _selectedCoupon?.code == coupon.code;
          return _couponCard(coupon, isSelected: isSelected);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 20),
      ),
    );
  }

  Widget _couponCard(Coupon coupon, {required bool isSelected}) {
    // This is the new, smaller coupon card design from Figma
    return GestureDetector(
      onTap: () => _selectCouponFromCard(coupon),
      child: Container(
        width: 240, // Width of the card
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.blueAccent, width: 3) : null,
          gradient: const LinearGradient(
            colors: [Color(0xFF020202), Color(0xFF1F2B00)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              coupon.description.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${coupon.discountPercentage.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text: ' Off',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectCouponFromCard(coupon),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: isSelected ? const BorderSide(width: 2, color: Colors.blueAccent) : BorderSide.none,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: Text(
                isSelected ? "Selected" : "Redeem",
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationButton(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: ElevatedButton(
        onPressed: _isNavigating ? null : _confirmAndNavigate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCCF656),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
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
