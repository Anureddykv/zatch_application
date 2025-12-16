import 'package:flutter/material.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/view/product_view/product_detail_screen.dart';
import 'add_to_cart_sheet.dart';
import 'buy_zatch_sheet.dart';

class CatalogueSheet extends StatefulWidget {
  final List<Product> products;
  final Function(Widget) onNavigate; // Callback to handle _pushAndPause

  const CatalogueSheet({
    super.key,
    required this.products,
    required this.onNavigate,
  });

  @override
  State<CatalogueSheet> createState() => _CatalogueSheetState();
}

class _CatalogueSheetState extends State<CatalogueSheet> {
  // --- UPDATED: Dynamic Color Parser (Hex Support) ---
  Color _getColorFromString(String colorString) {
    try {
      // 1. Clean the string
      String hex = colorString.replaceAll("#", "").trim();

      // 2. Parse Hex (6 digit or 8 digit)
      if (hex.length == 6) {
        return Color(int.parse("0xFF$hex"));
      } else if (hex.length == 8) {
        return Color(int.parse("0x$hex"));
      }

      // 3. Fallback if the backend sends simple names instead of Hex
      // (You can assume your backend sends Hex now, otherwise this defaults to grey)
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child:
                    const Icon(Icons.arrow_back_ios, color: Colors.black),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Catalogue",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.products.length,
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  return _ProductItem(
                    product: product,
                    getColorFromString: _getColorFromString,
                    onNavigate: widget.onNavigate,
                  );
                },
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        );
      },
    );
  }
}
class _ProductItem extends StatefulWidget {
  final Product product;
  final Color Function(String) getColorFromString;
  final Function(Widget) onNavigate;

  const _ProductItem({
    super.key,
    required this.product,
    required this.getColorFromString,
    required this.onNavigate,
  });

  @override
  State<_ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<_ProductItem> {
  String? selectedSize;
  Color? selectedColor;

  // --- 1. GETTERS: Extract Unique & Non-Null Values ---

  List<String> get availableSizes {
    if (widget.product.variants.isEmpty) return [];

    return widget.product.variants
        .map((v) => v.size) // Extract size
        .where((s) => s != null && s.isNotEmpty) // Filter out nulls/empty
        .map((s) => s!) // Safe cast
        .toSet() // Remove duplicates
        .toList();
  }

  List<String> get availableColors {
    if (widget.product.variants.isEmpty) return [];

    return widget.product.variants
        .map((v) => v.color) // Extract color
        .where((c) => c != null && c.isNotEmpty) // Filter out nulls/empty
        .map((c) => c!) // Safe cast
        .toSet() // Remove duplicates
        .toList();
  }

  // --- Helper for Top SnackBar ---
  void _showTopSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 150,
        left: 16,
        right: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    // Check which lists have data
    final hasSizes = availableSizes.isNotEmpty;
    final hasColors = availableColors.isNotEmpty;

    // --- Validation Logic ---
    // If sizes exist, one must be selected. If no sizes exist, it's considered valid.
    final bool isSizeValid = !hasSizes || selectedSize != null;
    // If colors exist, one must be selected. If no colors exist, it's considered valid.
    final bool isColorValid = !hasColors || selectedColor != null;

    final bool areOptionsSelected = isSizeValid && isColorValid;

    // Image Fallback
    final bool hasValidImage = widget.product.images.isNotEmpty &&
        widget.product.images.first.url.isNotEmpty;
    final String productImage = hasValidImage
        ? widget.product.images.first.url
        : "https://placehold.co/95x118";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: Image, Title, Price ---
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onNavigate(
                    ProductDetailScreen(productId: widget.product.id));
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Image.network(
                      productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 24),
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
                          style: const TextStyle(
                            color: Color(0xFF121111),
                            fontSize: 14,
                            fontFamily: 'Encode Sans',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              widget.product.category ?? 'Category',
                              style: const TextStyle(
                                color: Color(0xFF787676),
                                fontSize: 10,
                                fontFamily: 'Encode Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star,
                                size: 12, color: Color(0xFFF5A623)),
                            const SizedBox(width: 2),
                            Text(
                              "${widget.product.averageRating > 0 ? widget.product.averageRating : 5.0}",
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
                  Text(
                    "${widget.product.price.toStringAsFixed(2)} ₹",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Encode Sans',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- DYNAMIC SECTIONS (Size & Color) ---
            if (hasSizes || hasColors)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SIZES COLUMN (Only render if hasSizes is true)
                  if (hasSizes)
                    Expanded(
                      flex: 3, // Give more space to size names
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
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableSizes.map((s) {
                              final isSelected =
                                  selectedSize?.toLowerCase() == s.toLowerCase();
                              return GestureDetector(
                                onTap: () => setState(() => selectedSize = s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: ShapeDecoration(
                                    color: isSelected
                                        ? const Color(0xFF292526)
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: isSelected
                                            ? Colors.transparent
                                            : const Color(0xFFDFDEDE),
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFFFDFDFD)
                                          : const Color(0xFF292526),
                                      fontSize: 12,
                                      fontFamily: 'Encode Sans',
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                  // Spacer between columns if both exist
                  if (hasSizes && hasColors)
                    const SizedBox(width: 16),

                  // 2. COLORS COLUMN (Only render if hasColors is true)
                  if (hasColors)
                    Expanded(
                      flex: 2,
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
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableColors.map((cString) {
                              final c = widget.getColorFromString(cString);
                              final isSelected = selectedColor == c;

                              return GestureDetector(
                                onTap: () => setState(() => selectedColor = c),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                        color: const Color(0xFFAFE80C),
                                        width: 2)
                                        : null,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                    decoration: ShapeDecoration(
                                      color: c,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: c == Colors.white
                                              ? const Color(0xFFDFDEDE)
                                              : Colors.transparent,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(100),
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
                ],
              ),

            const SizedBox(height: 24),

            // --- BOTTOM BUTTONS ---
            Row(
              children: [
                // Add to Cart
                GestureDetector(
                  onTap: () {
                    if (areOptionsSelected) {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) =>
                            AddToCartSheet(product: widget.product),
                      );
                    } else {
                      _showTopSnackBar(context, "Please select options first");
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const ShapeDecoration(
                      shape: OvalBorder(
                        side: BorderSide(width: 2, color: Color(0xFFCCF656)),
                      ),
                    ),
                    child: const Icon(Icons.add_shopping_cart, size: 20),
                  ),
                ),
                const SizedBox(width: 12),

                // Buy Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (areOptionsSelected) {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => BuyZatchSheet(
                              product: widget.product,
                              defaultOption: "buy",
                              onNavigate: widget.onNavigate,
                              onBackToCatalogue: () {}),
                        );
                      } else {
                        _showTopSnackBar(context, "Please select options first");
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 2, color: Color(0xFFCCF656)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Buy',
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
                const SizedBox(width: 12),

                // Zatch Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (areOptionsSelected) {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => BuyZatchSheet(
                              product: widget.product,
                              defaultOption: "zatch",
                              onNavigate: widget.onNavigate,
                              onBackToCatalogue: () {}),
                        );
                      } else {
                        _showTopSnackBar(context, "Please select options first");
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFCCF656),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Zatch',
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}


