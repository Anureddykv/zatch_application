import 'package:flutter/material.dart';
import 'package:zatch_app/model/coupon_model.dart';
import 'package:zatch_app/services/api_service.dart';

class CouponApplyScreen extends StatefulWidget {
  final double cartTotal;
  final List<String> productIds;

  // Constructor now requires cart details to validate the coupon via API
  const CouponApplyScreen({
    super.key,
    this.cartTotal = 0.0,
    this.productIds = const [],
  });

  @override
  State<CouponApplyScreen> createState() => _CouponApplyScreenState();
}

class _CouponApplyScreenState extends State<CouponApplyScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _couponController = TextEditingController();

  // --- STATE ---
  List<Coupon> _coupons = [];
  Coupon? _selectedCoupon;

  bool _isLoading = true; // For fetching list
  bool _isApplying = false; // For applying coupon
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    try {
      final coupons = await _apiService.getCoupons();
      if (mounted) {
        setState(() {
          _coupons = coupons;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load coupons";
          _isLoading = false;
        });
        _showSnackBar("Error loading coupons: $e", isError: true);
      }
    }
  }

  // --- LOGIC ---

  void _applyCouponFromInput(String code) {
    if (code.isEmpty) {
      _showSnackBar("Please enter a coupon code.", isError: true);
      return;
    }

    // Check if the code exists in our fetched list to get the ID
    try {
      final enteredCode = code.toUpperCase();
      final foundCoupon = _coupons.firstWhere(
            (c) => c.code.toUpperCase() == enteredCode,
      );

      // If found in list, select it
      _selectCouponFromCard(foundCoupon);
      _showSnackBar("Coupon found! Click 'Apply Coupon' to redeem.");
    } catch (e) {
      // If not in list, we can't get the ID easily.
      // You might need a specific endpoint to "search by code" if it's hidden.
      _showSnackBar("Invalid coupon code or not applicable.", isError: true);
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

  Future<void> _confirmAndNavigate() async {
    if (_selectedCoupon == null || _isApplying) return;

    setState(() => _isApplying = true);

    try {
      // Call API to validate and apply
      final response = await _apiService.applyCoupon(
        couponId: _selectedCoupon!.id,
        code: _selectedCoupon!.code,
        cartTotal: widget.cartTotal,
        productIds: widget.productIds,
      );

      if (mounted) {
        _showSnackBar("Coupon applied successfully!");

        // Pass the FULL Coupon object back, plus the calculated discount from API if needed
        // Or you can create a wrapper object to return.
        // For now, we return the Coupon model. The checkout screen can re-verify or use the discount.
        Navigator.pop(context, _selectedCoupon);
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceAll("Exception:", "").trim(), isError: true);
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
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

  // --- UI BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    final String buttonText = _selectedCoupon != null ? "Apply Coupon" : "Continue";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F9),
      appBar: AppBar(
        title: const Text(
          "Apply Coupon",
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
          onPressed: () => Navigator.pop(context, null),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFCCF656)))
            : Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 20),
                children: [
                  _buildCouponInputField(),
                  const SizedBox(height: 30),

                  if (_coupons.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text("No coupons available at the moment.")),
                    )
                  else
                    _buildCouponCarousel(),
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
          hintStyle: const TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Encode Sans'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
          suffixIcon: TextButton(
            onPressed: _isApplying ? null : () => _applyCouponFromInput(_couponController.text),
            child: const Text(
              "Apply",
              style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCouponCarousel() {
    return SizedBox(
      height: 280,
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
    // Determine display logic based on API data types
    String bigText = "";
    String smallText = " Off";

    if (coupon.discountType == "percentage") {
      bigText = "${coupon.discountValue.toInt()}%";
    } else {
      // Fixed amount
      bigText = "₹${coupon.discountValue.toInt()}";
    }

    return GestureDetector(
      onTap: () => _selectCouponFromCard(coupon),
      child: Container(
        width: 240,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                coupon.name.toUpperCase(), // Using 'name' from API
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: bigText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48, // Slightly smaller to fit "₹" if needed
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: smallText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Min Spend: ₹${coupon.minSpend}",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 15),
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
        onPressed: _isApplying ? null : _confirmAndNavigate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCCF656),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isApplying
            ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
        )
            : Text(
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
