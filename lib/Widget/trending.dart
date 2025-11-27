import 'package:flutter/material.dart';
// Import the staggered grid view package
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zatch_app/controller/live_stream_controller.dart';
import 'package:zatch_app/model/TrendingBit.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/ReelDetailsScreen.dart';
import 'package:zatch_app/view/live_view/see_all_live_screen.dart';
import 'package:zatch_app/view/reel/AllTrendingScreen.dart';

class TrendingSection extends StatefulWidget {
  const TrendingSection({super.key});

  @override
  State<TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<TrendingSection> {
  late Future<List<TrendingBit>> trendingFuture;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    trendingFuture = _api.fetchTrendingBits();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TrendingBit>>(
      future: trendingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No trending items"));
        }

        final bits = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Trending",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AllTrendingScreen()),
                      );
                    },
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Use AlignedGridView for the staggered effect
            AlignedGridView.count(
              itemCount: bits.length,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                // Determine a different height for even/odd items to create stagger
                final isEven = index % 2 == 0;
                final double imageHeight = isEven ? 251 : 290;
                return TrendingCard(
                  bit: bits[index],
                  imageHeight: imageHeight,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class TrendingCard extends StatefulWidget {
  final TrendingBit bit;
  final double imageHeight; // Accept image height to create stagger
  const TrendingCard(
      {super.key, required this.bit, required this.imageHeight});

  @override
  State<TrendingCard> createState() => _TrendingCardState();
}

class _TrendingCardState extends State<TrendingCard> {
  late bool isLiked;
  late int likeCount;
  bool isApiCallInProgress = false;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    likeCount = widget.bit.likeCount;
    // This logic is still flawed and should be updated once the API provides `isLikedByUser`
    isLiked = widget.bit.likeCount > 0;
  }

  Future<void> _toggleLike() async {
    if (isApiCallInProgress) return;
    setState(() => isApiCallInProgress = true);

    // Simplified optimistic update
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    try {
      final response = await _api.toggleLike(widget.bit.id);
      final serverLikeCount = response['likeCount'] as int;
      final serverIsLiked = response['isLiked'] as bool;

      widget.bit.likeCount = serverLikeCount;
      if (mounted) {
        setState(() {
          likeCount = serverLikeCount;
          isLiked = serverIsLiked;
        });
      }
    } catch (e) {
      // Revert on failure
      if (mounted) {
        setState(() {
          isLiked = !isLiked;
          likeCount += isLiked ? 1 : -1;
        });
        debugPrint("Failed to toggle like: $e");
      }
    } finally {
      if (mounted) {
        setState(() => isApiCallInProgress = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.bit.isLive) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const SeeAllLiveScreen(liveSessions: [])),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ReelDetailsScreen(
                    bitId: widget.bit.id, controller: LiveStreamController())),
          );
        }
      },
      // The card is now just a Column, the container/decoration is removed
      // as the new design doesn't show a card background for the text part.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container with rounded corners and widgets on top
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Image.network(
                  widget.bit.thumbnailUrl,
                  height: widget.imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: widget.imageHeight,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.error)),
                  ),
                ),
                if (widget.bit.isLive)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBBF711),
                        borderRadius: BorderRadius.circular(48),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Live', // The design has 'Live' and a count, but the model doesn't have a viewer count
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Encode Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: _toggleLike,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF292526).withOpacity(0.8),
                        shape: const CircleBorder(),
                      ),
                      child: isApiCallInProgress
                          ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        ),
                      )
                          : Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Text section below the image
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bit.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.bit.description,
                  style: const TextStyle(
                    color: Color(0xFF787676),
                    fontSize: 10,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // BUG: Using viewCount for price. Update when model has `price`.
                      '₹${widget.bit.viewCount}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          // BUG: Using viewCount for rating. Update when model has `rating`.
                          widget.bit.viewCount.toString(),
                          style: const TextStyle(
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
              ],
            ),
          )
        ],
      ),
    );
  }
}
