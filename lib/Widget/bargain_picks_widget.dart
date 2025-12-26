import 'package:flutter/material.dart';
import 'package:zatch/model/ExploreApiRes.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/reel/see_all_bargain_picks_screen.dart';
import 'package:zatch/view/reel_player_screen.dart';
import 'package:zatch/model/categories_response.dart';

class BargainPicksWidget extends StatefulWidget {
  final Category? category;
  final Function(bool)? onLoaded; // Callback added

  const BargainPicksWidget({super.key, this.category, this.onLoaded});

  @override
  State<BargainPicksWidget> createState() => _BargainPicksWidgetState();
}

class _BargainPicksWidgetState extends State<BargainPicksWidget> {
  final ApiService _apiService = ApiService();
  late Future<List<Bits>> _picksFuture;

  @override
  void initState() {
    super.initState();
    _fetchPicks();
  }

  @override
  void didUpdateWidget(BargainPicksWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category?.id != widget.category?.id) {
      setState(() {});
    }
  }

  void _fetchPicks() {
    _picksFuture = _apiService.getExploreBits();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Bits>>(
      future: _picksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final picks = snapshot.data;
        if (picks == null || picks.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onLoaded?.call(false);
          });
          return const SizedBox.shrink();
        }

        List<Bits> filteredPicks = picks;

        if (widget.category != null && widget.category!.name.toLowerCase() != 'explore all') {
          final selectedCatName = widget.category!.name.toLowerCase();
          final selectedCatSlug = widget.category!.slug?.toLowerCase() ?? '';

          filteredPicks = picks.where((bit) {
            return bit.products.any((product) {
              final prodCat = product.category?.toLowerCase() ?? '';
              return prodCat == selectedCatName ||
                  (selectedCatSlug.isNotEmpty && prodCat == selectedCatSlug) ||
                  prodCat.contains(selectedCatName);
            });
          }).toList();
        }

        if (filteredPicks.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onLoaded?.call(false);
          });
          return const SizedBox.shrink();
        }

        // Notify parent that data exists
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onLoaded?.call(true);
        });

        final displayedPicks = filteredPicks.length > 5 ? filteredPicks.sublist(0, 5) : filteredPicks;

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final cardWidth = screenWidth * 0.28;
            final cardHeight = cardWidth * 1.45;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Bargain picks - Zatching now',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        if (filteredPicks.length > 5)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SeeAllBargainPicksScreen(
                                    picks: filteredPicks,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: cardHeight + 80, // Increased height slightly for extra text line
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: displayedPicks.length,
                      itemBuilder: (context, index) {
                        final pick = displayedPicks[index];
                        final List<String> relevantReelIds =
                        filteredPicks.map((p) => p.id).toList();

                        // Get product price info for strikethrough if available
                        double? originalPrice;
                        if (pick.products.isNotEmpty) {
                          originalPrice = pick.products.first.price;
                        }

                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == displayedPicks.length - 1 ? 0 : 12,
                          ),
                          child: InkWell(
                            onTap: () {
                              final tappedIndex = relevantReelIds.indexOf(pick.id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReelPlayerScreen(
                                    bitIds: relevantReelIds,
                                    initialIndex: tappedIndex,
                                  ),
                                ),
                              );
                            },
                            child: BargainPickCard(
                              imageUrl: pick.thumbnail.url,
                              title: pick.title,
                              priceInfo: "Less than ${pick.revenue}",
                              originalPrice: originalPrice,
                              cardImageWidth: cardWidth,
                              cardImageHeight: cardHeight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class BargainPickCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String priceInfo;
  final double? originalPrice;
  final double? cardImageWidth;
  final double? cardImageHeight;

  const BargainPickCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.priceInfo,
    this.originalPrice,
    this.cardImageWidth,
    this.cardImageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage =
        imageUrl.startsWith('http') || imageUrl.startsWith('https');

    return Container(
      width: cardImageWidth,
      height: cardImageHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
              child: imageUrl.isNotEmpty
                  ? (isNetworkImage
                  ? Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[200]),
              )
                  : Image.asset(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ))
                  : Container(color: Colors.grey[200]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF787676),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  "Zatch from",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        priceInfo,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94C800),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (originalPrice != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        "${originalPrice!.toStringAsFixed(0)} ₹",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF787676),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
