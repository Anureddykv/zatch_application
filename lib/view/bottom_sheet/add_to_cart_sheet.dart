import 'package:flutter/material.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/services/api_service.dart'; // Import your ApiService

class AddToCartSheet extends StatefulWidget {
  final Product product;

  const AddToCartSheet({super.key, required this.product});

  @override
  State<AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<AddToCartSheet> {
  final ApiService _apiService = ApiService(); // 1. Initialize API Service
  int quantity = 1;
  bool _isLoading = false; // 2. Add loading state

  Future<void> _handleAddToCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Call the API
      await _apiService.updateCartItem(
        productId: widget.product.id,
        quantity: quantity,
        color: null,
        size: null,
      );

      if (!mounted) return;

      // 4. Handle Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product added to cart successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Close the sheet
    } catch (e) {
      if (!mounted) return;

      // 5. Handle Error
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
              const Text('Cart',
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
                                Text(widget.product.name ?? 'Product Name',
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
                                const SizedBox(height: 16),
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
            onTap: _isLoading ? null : _handleAddToCart, // 6. Connect the function
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
      onTap: _isLoading ? null : onTap, // Disable buttons while loading
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
