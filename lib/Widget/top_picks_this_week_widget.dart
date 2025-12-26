import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zatch/model/product_response.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/product_view/product_detail_screen.dart';
import 'package:zatch/view/home_page.dart';
import '../view/product_view/see_all_top_picks_screen.dart';
import 'package:zatch/model/categories_response.dart';

class TopPicksThisWeekWidget extends StatefulWidget {
  final String? title;
  final bool showSeeAll;
  final Category? category;
  final Function(bool)? onLoaded;

  const TopPicksThisWeekWidget({super.key, this.title, this.showSeeAll = true, this.category, this.onLoaded});

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

  @override
  void didUpdateWidget(TopPicksThisWeekWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category?.id != widget.category?.id || 
        oldWidget.category?.easyname != widget.category?.easyname ||
        oldWidget.category?.slug != widget.category?.slug) {
      _loadTopPicks();
    }
  }

  Future<void> _loadTopPicks() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      var fetchedPicks = await _apiService.getTopPicks();
      List<Product> filteredPicks;
      final bool isExploreAll = widget.category == null || 
                               widget.category!.easyname?.toLowerCase() == 'explore_all' ||
                               widget.category!.name.toLowerCase() == 'explore all';

      if (isExploreAll) {
        filteredPicks = fetchedPicks;
      } else {
        final targetFilter = (widget.category!.slug ?? widget.category!.easyname ?? widget.category!.name).toLowerCase();
        filteredPicks = fetchedPicks.where((p) {
          final cat = p.category?.toLowerCase();
          return cat == targetFilter;
        }).toList();
      }

      if (mounted) {
        setState(() {
          topPicks = filteredPicks;
          loading = false;
        });
        widget.onLoaded?.call(filteredPicks.isNotEmpty);
      }
    } catch (e) {
      debugPrint("Failed to load top picks: ${e.toString()}");
      if (mounted) {
        setState(() => loading = false);
        widget.onLoaded?.call(false);
      }
    }
  }

  String formatPrice(num? price) => NumberFormat.currency(locale: 'en_IN', symbol: "\₹", decimalDigits: 0).format(price ?? 0);
  String formatSold(num? sold) => NumberFormat.decimalPattern().format(sold ?? 0);

  String? getDiscountPercentage(num? originalPrice, num? discountedPrice) {
    if (originalPrice == null || discountedPrice == null || originalPrice == 0 || discountedPrice >= originalPrice) return null;
    return '${(((originalPrice - discountedPrice) / originalPrice) * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const SizedBox(height: 266, child: Center(child: CircularProgressIndicator()));
    if (topPicks.isEmpty) return const SizedBox.shrink();
    final displayList = topPicks.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title ?? 'Top Picks This Week', style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600)),
              if (widget.showSeeAll)
                GestureDetector(
                  onTap: () {
                    if (homePageKey.currentState != null) {
                      homePageKey.currentState!.navigateToSubScreen(SeeAllTopPicksScreen(products: topPicks));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SeeAllTopPicksScreen(products: topPicks)));
                    }
                  },
                  child: const Text('See All', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: displayList.length, separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = displayList[index];
              final imgUrl = product.images.isNotEmpty ? product.images.first.url : "https://placehold.co/159x177?text=No+Image";
              final String rating = "5.0";
              final String? discountPercent = getDiscountPercentage(product.price, product.discountedPrice);
              final bool hasDiscount = product.discountedPrice != null && product.discountedPrice! < (product.price ?? 0);
              final num displayPrice = hasDiscount ? product.discountedPrice! : product.price ?? 0;

              return GestureDetector(
                onTap: () {
                  if (homePageKey.currentState != null) {
                    homePageKey.currentState!.navigateToSubScreen(ProductDetailScreen(productId: product.id));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)));
                  }
                },
                child: Container(
                  width: 159, height: 280, clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(color: const Color(0xFFF4F4F4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: double.infinity, height: 170, decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover))),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name ?? "No Name", overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(color: Color(0xFF272727), fontSize: 12, fontWeight: FontWeight.w400, height: 1.5)),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(formatPrice(displayPrice), style: const TextStyle(color: Color(0xFF272727), fontSize: 12, fontWeight: FontWeight.w800)), if (hasDiscount) Text(formatPrice(product.price), style: const TextStyle(color: Color(0xFF787676), fontSize: 10, fontWeight: FontWeight.w400, decoration: TextDecoration.lineThrough))])),
                                      Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 2), Text(rating, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400, height: 1.50))]),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(width: double.infinity, height: 1, color: const Color(0xFFDDDDDD)),
                                  const SizedBox(height: 6),
                                  Text('${formatSold(product.totalStock)} sold this week', style: const TextStyle(color: Color(0xFF249B3E), fontSize: 10, fontWeight: FontWeight.w600, height: 1.50), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (discountPercent != null) Positioned(top: 0, right: 0, child: Container(width: 42, height: 43.65, decoration: const ShapeDecoration(color: Color(0xFFBBF711), shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomLeft: Radius.circular(16)))), child: Center(child: SizedBox(width: 35, child: Text('$discountPercent\nOFF', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800, height: 1.1)))))),
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
