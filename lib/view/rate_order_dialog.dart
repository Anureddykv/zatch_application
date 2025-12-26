import 'package:flutter/material.dart';
// Make sure this path is correct for your project
import 'package:zatch/model/product_response.dart';

// --- Main Function to Show the Dialog ---
void showReviewDialog(BuildContext context, Product product) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      // Pass the product to the dialog
      return RateOrderDialog(product: product);
    },
  );
}

// --- The Dialog Widget ---
class RateOrderDialog extends StatefulWidget {
  // ✅ FIX: Accept a product object to display its data
  final Product product;
  const RateOrderDialog({super.key, required this.product});

  @override
  State<RateOrderDialog> createState() => _RateOrderDialogState();
}

class _RateOrderDialogState extends State<RateOrderDialog> {
  int _currentRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 100,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductInfoCard(),
              const SizedBox(height: 24),
              const Text('Rating', style: TextStyle(color: Color(0xFF354152), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildRatingStars(),
              const SizedBox(height: 24),
              const Text('Review', style: TextStyle(color: Color(0xFF354152), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildReviewTextField(),
              const SizedBox(height: 24),
              const Text('Upload Images', style: TextStyle(color: Color(0xFF354152), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500)),
              const SizedBox(height: 14),
              _buildImageUploader(),
              const SizedBox(height: 8),
              const Text('Upload at least 3 high-quality images. First image will be the main product image.', style: TextStyle(color: Color(0xFF697282), fontSize: 10.50, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400, height: 1.33)),
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12.75),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.75),
            child: Image.network(
              // ✅ FIX: Use dynamic product image
              widget.product.images.isNotEmpty ? widget.product.images.first.url : "https://placehold.co/56x56",
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) => const Icon(Icons.image_not_supported, size: 56),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ FIX: Use dynamic product name
                Text(widget.product.name, style: const TextStyle(color: Color(0xFF101727), fontSize: 12.30, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Women Dress', style: TextStyle(color: Color(0xFF697282), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400)), // This could also be from product data if available
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Cost - ', style: TextStyle(color: Color(0xFF666666), fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w400)),
                      // ✅ FIX: Use dynamic product price
                      TextSpan(text: '${widget.product.price} ₹', style: const TextStyle(color: Color(0xFF272727), fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Centered stars look better
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => setState(() => _currentRating = index + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(index < _currentRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 48),
          ),
        );
      }),
    );
  }

  Widget _buildReviewTextField() {
    return TextField(
      controller: _reviewController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Enter your review...',
        hintStyle: const TextStyle(color: Color(0xFF717182), fontSize: 12.30, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFCCF656), width: 1.5)),
      ),
    );
  }

  Widget _buildImageUploader() {
    return GestureDetector(
      onTap: () {
        // TODO: Implement image picking logic using a package like image_picker
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image picker tapped!")));
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.75),
          border: Border.all(width: 2, color: const Color(0xFFD0D5DB)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, color: Color(0xFF697282), size: 24),
            SizedBox(height: 4),
            Text('Add Image', style: TextStyle(color: Color(0xFF697282), fontSize: 10.50, fontFamily: 'Plus Jakarta Sans')),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: const BorderSide(width: 1, color: Colors.black),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // This is where you would make an API call to submit the review
              final reviewText = _reviewController.text;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submitting Rating: $_currentRating, Review: $reviewText')));
              // You might want to pop only after a successful API response
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCF656),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('Submit Review', style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
