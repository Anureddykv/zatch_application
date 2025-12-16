import 'package:flutter/material.dart';
import 'package:zatch_app/model/ExploreApiRes.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/reel/see_all_bargain_picks_screen.dart';
import 'package:zatch_app/view/reel_player_screen.dart';
import 'package:zatch_app/model/categories_response.dart';

class BargainPicksWidget extends StatefulWidget {
  final Category? category;
  const BargainPicksWidget({super.key, this.category});

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
    // If category changes, we just need to rebuild the UI to re-filter.
    // We don't necessarily need to re-fetch from API if the API returns all bits anyway.
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
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final picks = snapshot.data;
        if (picks == null || picks.isEmpty) {
          return const SizedBox.shrink();
        }

        // --- FILTERING LOGIC ---
        List<Bits> filteredPicks = picks;

        if (widget.category != null && widget.category!.name.toLowerCase() != 'explore all') {
          final selectedCatName = widget.category!.name.toLowerCase();
          final selectedCatSlug = widget.category!.slug?.toLowerCase() ?? '';

          filteredPicks = picks.where((bit) {
            // Check if ANY product in this Bit belongs to the selected category
            return bit.products.any((product) {
              final prodCat = product.category?.toLowerCase() ?? '';

              // Match against Name or Slug
              return prodCat == selectedCatName ||
                  (selectedCatSlug.isNotEmpty && prodCat == selectedCatSlug) ||
                  prodCat.contains(selectedCatName);
            });
          }).toList();
        }

        // If no bits match the category, hide the widget
        if (filteredPicks.isEmpty) {
          return const SizedBox.shrink();
        }

        // Limit to 5 for the horizontal preview
        final displayedPicks = filteredPicks.length > 5 ? filteredPicks.sublist(0, 5) : filteredPicks;

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            // CARD RESPONSIVE SIZE
            final cardWidth = screenWidth * 0.28; // 28% of screen width
            final cardHeight = cardWidth * 1.45; // aspect ratio

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
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
                    height: cardHeight + 70, // space for text
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: displayedPicks.length,
                      itemBuilder: (context, index) {
                        final pick = displayedPicks[index];
                        // Pass the filtered list IDs so the player scrolls through relevant bits
                        final List<String> relevantReelIds =
                        filteredPicks.map((p) => p.id).toList();

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
  final double? cardImageWidth;
  final double? cardImageHeight;

  const BargainPickCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.priceInfo,
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
          /// Image Section
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

          /// Text Section
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
                Text(
                  priceInfo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94C800),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
