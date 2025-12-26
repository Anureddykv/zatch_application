import 'package:flutter/material.dart';
import 'package:zatch/model/product_response.dart';
import 'package:zatch/model/CartApiResponse.dart' as cart_model;
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/cart_screen.dart';
import 'package:zatch/view/home_page.dart';
import 'package:zatch/view/setting_view/payments_shipping_screen.dart';
import 'package:zatch/view/bottom_sheet/catalogue_sheet.dart';
import 'package:zatch/utils/snackbar_utils.dart';

class BuyZatchSheet extends StatefulWidget {
  final Product product;
  final String defaultOption;
  final List<Product> allProducts;
  final Function(Widget) onNavigate;
  final VoidCallback? onBackToCatalogue;
  final String? selectedColor;
  final String? selectedSize;

  const BuyZatchSheet({
    super.key,
    required this.product,
    required this.allProducts,
    this.defaultOption = "buy",
    required this.onNavigate,
    this.onBackToCatalogue,
    this.selectedColor,
    this.selectedSize,
  });

  @override
  State<BuyZatchSheet> createState() => _BuyZatchSheetState();
}

class _BuyZatchSheetState extends State<BuyZatchSheet> {
  final ApiService _apiService = ApiService();
  late String selectedOption;
  int buyQuantity = 1;
  int zatchQuantity = 1;
  late double bargainPrice;
  bool _isLoading = false;

  final String placeholderUrl = "https://placehold.co/400x400?text=No+Image";

  @override
  void initState() {
    super.initState();
    selectedOption = widget.defaultOption;
    bargainPrice = (widget.product.discountedPrice ?? widget.product.price).toDouble();
  }

  void _goBackToCatalogue() {
    Navigator.pop(context);
    if (widget.onBackToCatalogue != null) {
      widget.onBackToCatalogue!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double originalPrice = widget.product.price;
    final double discountedPrice = widget.product.discountedPrice ?? originalPrice;
    final double sliderMax = discountedPrice;
    final double maxDiscountPercent = widget.product.bargainSettings?.maximumDiscount ?? 0.0;
    double floorPrice = originalPrice * (1 - (maxDiscountPercent / 100));
    
    if (floorPrice >= sliderMax || floorPrice <= 0) {
      floorPrice = sliderMax * 0.7;
    }

    final bool hasDiscount = widget.product.discountedPrice != null &&
        widget.product.discountedPrice! < widget.product.price;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBackToCatalogue,
              ),
              const SizedBox(width: 8),
              const Text("Buy / Zatch",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          _buildOptionCard(
            value: "buy",
            title: "Buy Product",
            price: discountedPrice,
            child: _buildProductRow(
              discountedPrice, 
              buyQuantity, 
              (val) => setState(() => buyQuantity = val),
              strikePrice: hasDiscount ? originalPrice : null,
            ),
          ),
          _buildOptionCard(
            value: "zatch",
            title: "Zatch",
            price: originalPrice,
            child: Column(
              children: [
                _buildProductRow(originalPrice, zatchQuantity, (val) => setState(() => zatchQuantity = val)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Bargain Price (Per Unit)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("${bargainPrice.toStringAsFixed(0)} ₹",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        if (originalPrice > bargainPrice)
                          Text("${originalPrice.toStringAsFixed(0)} ₹",
                              style: const TextStyle(
                                  color: Color(0xFF787676),
                                  fontSize: 12,
                                  fontFamily: 'Encode Sans',
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: Colors.black,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: Colors.black,
                    overlayColor: Colors.black.withOpacity(0.1),
                    valueIndicatorColor: Colors.black,
                  ),
                  child: Slider(
                    value: bargainPrice.clamp(floorPrice, sliderMax),
                    min: floorPrice, 
                    max: sliderMax,
                    divisions: (sliderMax - floorPrice) > 0 ? (sliderMax - floorPrice).toInt().clamp(1, 1000) : 1,
                    onChanged: (val) => setState(() => bargainPrice = val.roundToDouble()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Max Discount Price", style: TextStyle(color: Colors.grey, fontSize: 10)),
                          Text("${floorPrice.toStringAsFixed(0)} ₹", 
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Current Price", style: TextStyle(color: Colors.grey, fontSize: 10)),
                          Text("${sliderMax.toStringAsFixed(0)} ₹", 
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCF656),
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _handleAction,
            child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : Text(
                  selectedOption == "buy" ? "Buy Now" : "Place Zatch",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
      {required String value,
      required String title,
      required double price,
      required Widget child}) {
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
                  color: isSelected ? const Color(0xFFCCF656) : Colors.grey.shade300,
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
                      activeColor: const Color(0xFFCCF656),
                      groupValue: selectedOption,
                      onChanged: (val) => setState(() => selectedOption = val!),
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

  Widget _buildProductRow(double price, int qty, Function(int) onQtyChanged, {double? strikePrice}) {
    final hasImage = widget.product.images.isNotEmpty;
    final String imageUrl =
        hasImage ? (widget.product.images.first.url) : placeholderUrl;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60,
              height: 60,
              color: Colors.grey.shade300,
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.product.category ?? "Product",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${price.toStringAsFixed(2)} ₹",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (strikePrice != null) ...[
                    Text(
                      "${strikePrice.toStringAsFixed(2)} ₹",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                if (qty > 1) onQtyChanged(qty - 1);
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => onQtyChanged(qty + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  void _handleAction() async {
    if (selectedOption == "buy") {
      try {
        final double currentSellingPrice = (widget.product.discountedPrice ?? widget.product.price).toDouble();
        final String safeImageUrl = widget.product.images.isNotEmpty 
            ? widget.product.images.first.url 
            : placeholderUrl;

        final itemToCheckout = cart_model.CartItemModel(
          id: "temp_reel_${widget.product.id}",
          productId: widget.product.id,
          sellerId: widget.product.seller?.id,
          name: widget.product.name,
          description: widget.product.description,
          price: widget.product.price.toDouble(),
          discountedPrice: currentSellingPrice,
          image: safeImageUrl,
          images: widget.product.images
              .map((e) => cart_model.ImageModel(
                    id: e.id,
                    publicId: e.publicId,
                    url: e.url,
                  ))
              .toList(),
          selectedVariant: null,
          quantity: buyQuantity,
          category: widget.product.category,
          subCategory: widget.product.subCategory,
          lineTotal: (currentSellingPrice * buyQuantity).round(),
          variant: cart_model.VariantModel(color: widget.selectedColor ?? ""),
        );

        final double itemsTotal = currentSellingPrice * buyQuantity;
        const double shippingFee = 50.0;
        final double subTotal = itemsTotal + shippingFee;

        Navigator.pop(context); // Close sheet

        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onNavigate(
            CheckoutOrPaymentsScreen(
              isCheckout: true,
              isDirectOrder: true,
              selectedItems: [itemToCheckout],
              itemsTotalPrice: itemsTotal,
              shippingFee: shippingFee,
              subTotalPrice: subTotal,
            ),
          );
        });
      } catch (e) {
        SnackBarUtils.showTopSnackBar(context, "Error preparing checkout: $e", isError: true);
      }
    } else {
      final double cleanOfferedPrice = bargainPrice.roundToDouble();
      setState(() => _isLoading = true);
      try {
        final response = await _apiService.createBargain(
          productId: widget.product.id,
          offeredPrice: cleanOfferedPrice,
          color: widget.selectedColor,
          size: widget.selectedSize,
          quantity: zatchQuantity,
          buyerNote: "Please accept!",
        );

        if (!mounted) return;

        if (response.success && response.bargain != null) {
          final bargainId = response.bargain!.id;
          Navigator.pop(context); // Close sheet
          _showZatchSuccessOverlay(bargainId);
        } else {
          SnackBarUtils.showTopSnackBar(context, response.message, isError: true);
        }
      } catch (e) {
        SnackBarUtils.showTopSnackBar(context, "Failed to place zatch: $e", isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showZatchSuccessOverlay(String bargainId) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.50),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 299,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 299,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCCF656),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: (MediaQuery.of(context).size.width / 2) - 65,
                        top: 70,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: const ShapeDecoration(
                            color: Colors.black,
                            shape: OvalBorder(),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFFCCF656),
                            size: 80,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: 245,
                        child: Text(
                          'Zatch Placed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: 296,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 68),
                          child: Text(
                            'You can find all previous Zatch section',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 21,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 27,
                        right: 27,
                        top: 461,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Close Success Overlay
                            
                            // Navigate to CartScreen via onNavigate callback
                            widget.onNavigate(CartScreen(
                              initialIndex: 1,
                              onNavigate: (next) => widget.onNavigate(next),
                            ));
                          },
                          child: Container(
                            height: 59,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 1, color: Colors.black),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'View Zatches',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 27,
                        right: 27,
                        top: 536,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 59,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            decoration: ShapeDecoration(
                              color: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Continue',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Encode Sans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
