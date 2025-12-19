import 'package:flutter/material.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/model/CartApiResponse.dart' as cart_model;
import 'package:zatch_app/model/carts_model.dart';
import 'package:zatch_app/view/setting_view/payments_shipping_screen.dart';
import 'package:zatch_app/view/zatching_details_screen.dart';
import 'package:zatch_app/view/bottom_sheet/catalogue_sheet.dart'; // Import CatalogueSheet

class BuyZatchSheet extends StatefulWidget {
  final Product product;
  final String defaultOption;
  final List<Product> allProducts;
  final Function(Widget) onNavigate;
  final VoidCallback? onBackToCatalogue; // Callback to trigger re-opening catalogue

  const BuyZatchSheet({
    super.key,
    required this.product,
    required this.allProducts,
    this.defaultOption = "buy",
    required this.onNavigate,
    this.onBackToCatalogue,
  });

  @override
  State<BuyZatchSheet> createState() => _BuyZatchSheetState();
}

class _BuyZatchSheetState extends State<BuyZatchSheet> {
  late String selectedOption;
  int quantity = 1;
  late double bargainPrice;

  final String placeholderUrl = "https://placehold.co/400x400?text=No+Image";

  @override
  void initState() {
    super.initState();
    selectedOption = widget.defaultOption;
    bargainPrice = widget.product.price;
  }

  void _goBackToCatalogue() {
    Navigator.pop(context);

    if (widget.onBackToCatalogue != null) {      widget.onBackToCatalogue!();
    } else {
      // Fallback: Show the FULL catalogue again
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => CatalogueSheet(
          products: widget.allProducts, // <--- USE FULL LIST HERE
          onNavigate: widget.onNavigate,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    double price = widget.product.price;

    return WillPopScope(
      onWillPop: () async {
        _goBackToCatalogue();
        return false; // Prevent default pop since we handled it manually
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goBackToCatalogue, // Use the helper method
                ),
                const SizedBox(width: 8),
                const Text("Buy / Zatch",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            _buildOptionCard(
              value: "buy",
              title: "Buy Product",
              price: price,
              child: _buildProductRow(price, false),
            ),
            _buildOptionCard(
              value: "zatch",
              title: "Zatch",
              price: price,
              child: Column(
                children: [
                  _buildProductRow(price, false),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("Bargain Price"),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: bargainPrice,
                          min: 100,
                          max: price > 100 ? price : 200,
                          divisions: 14,
                          onChanged: (val) => setState(() => bargainPrice = val),
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
              onPressed: _handleAction,
              child: Text(selectedOption == "buy" ? "Buy" : "Bargain"),
            )
          ],
        ),
      ),
    );
  }

  // ... (Rest of your _buildOptionCard, _buildProductRow, and _handleAction methods remain unchanged)

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
                  color: isSelected ? Colors.black : Colors.grey.shade300,
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

  Widget _buildProductRow(double price, bool isZatch) {
    final hasImage = widget.product.images.isNotEmpty;
    final String imageUrl =
    hasImage ? (widget.product.images.first.url ?? placeholderUrl) : placeholderUrl;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade100,
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name ?? "Unknown Product",
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                "Dress modern",
                style: TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${price.toStringAsFixed(2)} ₹",
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                if (quantity > 1) setState(() => quantity--);
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("$quantity"),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => setState(() => quantity++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  void _handleAction() {
    Navigator.pop(context);

    if (selectedOption == "buy") {
      String safeImageUrl = placeholderUrl;
      try {
        if (widget.product.images.isNotEmpty) {
          safeImageUrl = widget.product.images.first.url ?? placeholderUrl;
        }

        final itemToCheckout = cart_model.CartItemModel(
          id: "temp_reel_${widget.product.id ?? 'unknown'}",
          productId: widget.product.id ?? "",
          name: widget.product.name ?? "Unknown Product",
          description: widget.product.description ?? "",
          price: widget.product.price,
          discountedPrice: widget.product.discountedPrice ?? widget.product.price,
          image: safeImageUrl,
          images: widget.product.images
              .map((e) => cart_model.ImageModel(
            id: e.id ?? "",
            publicId: e.publicId ?? "",
            url: e.url ?? placeholderUrl,
          ))
              .toList(),
          selectedVariant: null,
          quantity: quantity,
          category: widget.product.category ?? "",
          subCategory: widget.product.subCategory ?? "",
          lineTotal: (widget.product.price * quantity).round(),
          variant: cart_model.VariantModel(color: ""),
        );

        final List<cart_model.CartItemModel> itemsForCheckout = [
          itemToCheckout
        ];

        final double itemsTotal = widget.product.price * quantity;
        const double shippingFee = 50.0;
        final double subTotal = itemsTotal + shippingFee;

        Future.delayed(const Duration(milliseconds: 200), () {
          widget.onNavigate(
            CheckoutOrPaymentsScreen(
              isCheckout: true,
              selectedItems: itemsForCheckout,
              itemsTotalPrice: itemsTotal,
              shippingFee: shippingFee,
              subTotalPrice: subTotal,
            ),
          );
        });

      } catch (e, stack) {
        debugPrint("Error creating cart item: $e");
        debugPrint(stack.toString());
      }
    } else {
      try {
        String safeImageUrl = placeholderUrl;
        if (widget.product.images.isNotEmpty) {
          safeImageUrl = widget.product.images.first.url ?? placeholderUrl;
        }

        final zatchDetails = ZatchingDetailsScreen(
          zatch: Zatch(
            id: "temp1",
            name: widget.product.name ?? 'Unknown',
            description: widget.product.description ?? "",
            seller: "Seller Name",
            imageUrl: safeImageUrl,
            active: true,
            status: "My Offer",
            quotePrice: "${bargainPrice.toStringAsFixed(0)} ₹",
            sellerPrice: "",
            quantity: quantity,
            subTotal: "${(bargainPrice * quantity).toStringAsFixed(0)} ₹",
            date: DateTime.now().toString(),
          ),
        );

        Future.delayed(const Duration(milliseconds: 200), () {
          widget.onNavigate(zatchDetails);
        });

      } catch (e) {
        debugPrint("Error creating Zatch item: $e");
      }
    }
  }
}
