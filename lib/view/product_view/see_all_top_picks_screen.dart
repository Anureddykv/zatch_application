import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/view/product_view/product_detail_screen.dart';

class SeeAllTopPicksScreen extends StatelessWidget {
  final List<Product> products;

  const SeeAllTopPicksScreen({super.key, required this.products});

  String formatPrice(num price) =>
      NumberFormat.currency(locale: 'en_US', symbol: "\$").format(price);
  String formatSold(num sold) => NumberFormat.decimalPattern().format(sold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Top Picks This Week'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
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
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 159 / 266, // Aspect ratio from the reference card
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            // Using category image URL as in the reference widget
            final imgUrl = product.category?.image?.url ??
                "https://via.placeholder.com/159x177";

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: product.id),
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
                        // Product Image - using Expanded to fill available space
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(imgUrl),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        // Details Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.category?.name ?? "No Category",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF272727),
                                  fontSize: 12,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatPrice(product.price),
                                    style: const TextStyle(
                                      color: Color(0xFF272727),
                                      fontSize: 12,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Row(
                                    children: const [
                                      Icon(Icons.star,
                                          size: 14, color: Colors.amber),
                                      SizedBox(width: 2),
                                      Text(
                                        '5.0', // Assuming a static value
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontFamily: 'Encode Sans',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                height: 1,
                                color: const Color(0xFFDDDDDD),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${formatSold(product.stock ?? 0)} sold this week',
                                style: const TextStyle(
                                  color: Color(0xFF249B3E),
                                  fontSize: 12,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Discount Badge
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFBBF711),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '56% OFF', // Assuming a static value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w800,
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
