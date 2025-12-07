import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/product_view/product_detail_screen.dart';
import '../view/product_view/see_all_top_picks_screen.dart';

class TopPicksThisWeekWidget extends StatefulWidget {
  final String? title;
  final bool showSeeAll;
  const TopPicksThisWeekWidget({super.key, this.title, this.showSeeAll = true});

  @override
  State<TopPicksThisWeekWidget> createState() => _TopPicksThisWeekWidgetState();
}

class _TopPicksThisWeekWidgetState extends State<TopPicksThisWeekWidget> {
  final ApiService _apiService = ApiService();
  bool loading = true;
  List<Product> topPicks = [];

  @override
  void initState() {
    super.initState();
    _loadTopPicks();
  }

  Future<void> _loadTopPicks() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      topPicks = await _apiService.getTopPicks();
    } catch (e) {
      debugPrint("Failed to load top picks: ${e.toString()}");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

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
    if (loading) {
      return const SizedBox(
        height: 266,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final displayList = topPicks.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header Section ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title ?? 'Top Picks This Week',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.showSeeAll)
                GestureDetector(
                  onTap: () {
                    if (topPicks.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SeeAllTopPicksScreen(products: topPicks),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // --- Product Cards List ---
        SizedBox(
          height: 280,
          child: displayList.isEmpty
              ? const Center(
            child: Text(
              "No active top picks available",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          )
              : ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: displayList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = displayList[index];

              // Image Logic
              final imgUrl = product.images.isNotEmpty
                  ? product.images.first.url
                  : product.category?.image?.url ??
                  "https://placehold.co/159x177?text=No+Image";

              final String rating = "5.0";

              // Calculate Discount
              // Assuming product.price is original and product.discountedPrice is the sale price
              // If your model uses different field names, adjust here.
              final String? discountPercent = getDiscountPercentage(
                  product.price, product.discountedPrice);

              // Determine which price to show as the main price
              final num displayPrice = product.discountedPrice != null &&
                  product.discountedPrice! < (product.price ?? 0)
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
                  width: 159,
                  // Fixed Height to prevent overflow
                  height: 280,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF4F4F4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Image Area
                          Container(
                            width: double.infinity,
                            height: 170, // Reduced from 177
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(imgUrl),
                                fit: BoxFit.cover,
                                onError: (e, s) {},
                              ),
                            ),
                          ),

                          // 2. Details Section
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Text(
                                    product.name ?? "No Name",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          formatPrice(displayPrice),
                                          style: const TextStyle(
                                            color: Color(0xFF272727),
                                            fontSize: 12,
                                            fontFamily:
                                            'Plus Jakarta Sans',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star,
                                              size: 14,
                                              color: Colors.amber),
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

                      // 3. Discount Badge (Top Right)
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
      ],
    );
  }
}
