import 'package:flutter/material.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/cart_screen.dart';

class AddToCartSheet extends StatefulWidget {
  final Product product;
  final String? size;
  final String? color;
  final Function(Widget) onNavigate;

  const AddToCartSheet({
    super.key,
    required this.product,
    this.size,
    this.color,
    required this.onNavigate,
  });

  @override
  State<AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<AddToCartSheet> {
  final ApiService _apiService = ApiService();
  int quantity = 1;
  bool _isLoading = false;

  Future<void> _handleAddToCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.updateCartItem(
        productId: widget.product.id,
        quantity: quantity,
        color: widget.color,
        size: widget.size,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product added to cart successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      // 1. Close the AddToCart Sheet
      Navigator.pop(context);
      widget.onNavigate(
        CartScreen(
          // Important: Pass the navigation logic so CartScreen can stay within context
          onNavigate: (Widget nextScreen) => widget.onNavigate(nextScreen),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add to cart: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double subTotal = (widget.product.price) * quantity;
    final bool hasValidImage = widget.product.images.isNotEmpty &&
        widget.product.images.first.url.isNotEmpty;
    final String productImage = hasValidImage
        ? widget.product.images.first.url
        : "https://placehold.co/95x118";

    String variantText = "";
    if (widget.size != null) variantText += "Size: ${widget.size}  ";
    if (widget.color != null) variantText += "Color: ${widget.color}";

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.close, color: Colors.transparent),
                  onPressed: () {}),
              const Text('Add to Cart',
                  style: TextStyle(
                      color: Color(0xFF121111),
                      fontSize: 18,
                      fontFamily: 'Encode Sans',
                      fontWeight: FontWeight.w600)),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFC2C2C2)),
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        productImage,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.product.name,
                                    style: const TextStyle(
                                        color: Color(0xFF121111),
                                        fontSize: 14,
                                        fontFamily: 'Encode Sans',
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(widget.product.category ?? 'Category',
                                    style: const TextStyle(
                                        color: Color(0xFF787676),
                                        fontSize: 10,
                                        fontFamily: 'Encode Sans')),
                                if (variantText.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(variantText,
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Encode Sans')),
                                  ),
                                const SizedBox(height: 10),
                                Text(
                                    '${widget.product.price.toStringAsFixed(2)} ₹',
                                    style: const TextStyle(
                                        color: Color(0xFF292526),
                                        fontSize: 14,
                                        fontFamily: 'Encode Sans',
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  _buildQuantityButton(
                                      icon: Icons.remove,
                                      onTap: () {
                                        if (quantity > 1) {
                                          setState(() => quantity--);
                                        }
                                      }),
                                  SizedBox(
                                      width: 25,
                                      child: Text('$quantity',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Color(0xFF292526),
                                              fontSize: 14,
                                              fontFamily: 'Encode Sans',
                                              fontWeight: FontWeight.w600))),
                                  _buildQuantityButton(
                                      icon: Icons.add,
                                      onTap: () => setState(() => quantity++)),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sub Total',
                        style: TextStyle(
                            color: Color(0xFF292526),
                            fontSize: 14,
                            fontFamily: 'Encode Sans')),
                    Text('${subTotal.toStringAsFixed(2)} ₹',
                        style: const TextStyle(
                            color: Color(0xFF121111),
                            fontSize: 14,
                            fontFamily: 'Encode Sans',
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _isLoading ? null : _handleAddToCart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: ShapeDecoration(
                  color: const Color(0xFFCCF656),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
                    : const Text(
                  'Add to Cart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Encode Sans',
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFFDFDEDE)),
                borderRadius: BorderRadius.circular(32))),
        child: Icon(icon, size: 16, color: const Color(0xFF292526)),
      ),
    );
  }
}
