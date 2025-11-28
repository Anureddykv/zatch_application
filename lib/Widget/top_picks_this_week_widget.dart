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
    // No changes here, your loading logic is correct
    if (!mounted) return;
    setState(() => loading = true);
    try {
      topPicks = await _apiService.getTopPicks();
    } catch (e) {
      if (mounted) {
        /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load top picks: ${e.toString()}")),
        );*/
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // --- (FIX) Make formatPrice handle potentially null or zero values better ---
  String formatPrice(num? price) =>
      NumberFormat.currency(locale: 'en_IN', symbol: "₹").format(price ?? 0);

  String formatSold(num? sold) => NumberFormat.decimalPattern().format(sold ?? 0);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      // Using a sized box to prevent layout shifts while loading
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // You can keep `take(5)` if you only want to show a few items
    final displayList = topPicks.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row (No changes needed here)
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
                          builder: (_) => SeeAllTopPicksScreen(products: topPicks),
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

        // Product Cards List
        SizedBox(
          height: 266,
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

              // --- (FIX) Safely get the image URL ---
              // Prioritize product's own image list, then category image, then a placeholder.
              final imgUrl = product.images.isNotEmpty
                  ? product.images.first.url
                  : product.category?.image?.url ?? "https://placehold.co/159x177?text=No+Image";

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
                  width: 159,
                  // Removed fixed height to allow for expansion if needed
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF4F4F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Container(
                        width: double.infinity,
                        height: 177,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            // Use a placeholder on error
                            image: NetworkImage(imgUrl),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // You can log the error if you want
                            },
                          ),
                        ),
                      ),
                      // Details Section
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- (FIX) Use product name first, then category name ---
                            Text(
                              product.name ?? product.category?.name ?? "No Name",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF272727),
                                fontSize: 12,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600, // Make it bolder
                              ),
                            ),
                            const SizedBox(height: 4),
                            // --- (FIX) Use the updated formatPrice method ---
                            Text(
                              formatPrice(product.price),
                              style: const TextStyle(
                                color: Color(0xFF272727),
                                fontSize: 12,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: const Color(0xFFDDDDDD),
                            ),
                            const SizedBox(height: 6),
                            // --- (FIX) Use the updated formatSold method ---
                            Text(
                              '${formatSold(product.stock)} sold this week',
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

