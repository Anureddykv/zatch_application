import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zatch/model/product_response.dart';
import 'package:zatch/view/product_view/product_detail_screen.dart';

class SeeAllTopPicksScreen extends StatelessWidget {
  final List<Product> products;

  const SeeAllTopPicksScreen({super.key, required this.products});

  String formatPrice(num? price) => NumberFormat.currency(
    locale: 'en_IN',
    symbol: "\₹",
    decimalDigits: 0,
  ).format(price ?? 0);

  String formatSold(num? sold) =>
      NumberFormat.decimalPattern().format(sold ?? 0);

  // Helper to calculate discount percentage
  String? getDiscountPercentage(num? originalPrice, num? discountedPrice) {
    if (originalPrice == null ||
        discountedPrice == null ||
        originalPrice == 0 ||
        discountedPrice >= originalPrice) {
      return null;
    }
    final double discount =
        ((originalPrice - discountedPrice) / originalPrice) * 100;
    return '${discount.round()}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Or Colors.white depending on preference
      appBar: AppBar(
        title: const Text('Top Picks This Week'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // Flat style often looks better with modern UI
        surfaceTintColor: Colors.transparent,
      ),
      body: products.isEmpty
          ? const Center(
        child: Text(
          'No products available',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12, // Matched spacing
            crossAxisSpacing: 12, // Matched spacing
            childAspectRatio: 159 / 280, // Adjusted ratio to prevent overflow
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            // Image Logic: safely access images
            final imgUrl = (product.images != null && product.images.isNotEmpty)
                ? product.images.first.url
                : "https://placehold.co/159x177?text=No+Image";

            // 2. Rating Logic
            final String rating = "5.0";

            // 3. Discount Logic
            final String? discountPercent = getDiscountPercentage(
                product.price, product.discountedPrice);

            // 4. Display Price Logic
            final bool hasDiscount = product.discountedPrice != null &&
                product.discountedPrice! < (product.price ?? 0);

            final num displayPrice = hasDiscount
                ? product.discountedPrice!
                : product.price ?? 0;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(productId: product.id),
                  ),
                );
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF4F4F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Area
                        Container(
                          width: double.infinity,
                          height: 170, // Fixed height like the horizontal widget
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(imgUrl),
                              fit: BoxFit.cover, // Changed to cover for better look
                              onError: (e, s) {},
                            ),
                          ),
                        ),

                        // Details Section
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  product.name ?? "No Name",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF272727),
                                    fontSize: 12,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Price & Rating Row
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            formatPrice(displayPrice),
                                            style: const TextStyle(
                                              color: Color(0xFF272727),
                                              fontSize: 12,
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          if (hasDiscount)
                                            Text(
                                              formatPrice(product.price),
                                              style: const TextStyle(
                                                color: Color(0xFF787676),
                                                fontSize: 10,
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontWeight: FontWeight.w400,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star,
                                            size: 14, color: Colors.amber),
                                        const SizedBox(width: 2),
                                        Text(
                                          rating,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontFamily: 'Encode Sans',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Divider
                                Container(
                                  width: double.infinity,
                                  height: 1,
                                  color: const Color(0xFFDDDDDD),
                                ),
                                const SizedBox(height: 6),

                                // Sold Count
                                Text(
                                  '${formatSold(product.totalStock)} sold this week',
                                  style: const TextStyle(
                                    color: Color(0xFF249B3E),
                                    fontSize: 10,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w600,
                                    height: 1.50,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Discount Badge
                    if (discountPercent != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 42,
                          height: 43.65,
                          decoration: const ShapeDecoration(
                            color: Color(0xFFBBF711),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 35,
                              child: Text(
                                '$discountPercent\nOFF',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 9,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
