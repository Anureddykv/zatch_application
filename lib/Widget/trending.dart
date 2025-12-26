import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zatch/controller/live_stream_controller.dart';
import 'package:zatch/model/TrendingBit.dart';
import 'package:zatch/model/live_session_res.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/ReelDetailsScreen.dart';
import 'package:zatch/view/home_page.dart';
import 'package:zatch/view/live_view/live_session_screen.dart';
import 'package:zatch/view/reel/AllTrendingScreen.dart';
import 'package:zatch/model/ExploreApiRes.dart';
import 'package:zatch/model/categories_response.dart';

class TrendingSection extends StatefulWidget {
  final Category? category;
  final Function(bool)? onLoaded; // Callback added

  const TrendingSection({super.key, this.category, this.onLoaded});

  @override
  State<TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<TrendingSection> {
  late Future<List<TrendingBit>> trendingFuture;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    // This fetches and merges both 'live' and 'bits'
    _fetchTrending();
  }

  @override
  void didUpdateWidget(TrendingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category?.id != widget.category?.id || 
        oldWidget.category?.easyname != widget.category?.easyname ||
        oldWidget.category?.slug != widget.category?.slug) {
      _fetchTrending();
    }
  }

  void _fetchTrending() {
     trendingFuture = _api.fetchTrendingBits();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TrendingBit>>(
      future: trendingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onLoaded?.call(false);
          });
          return const SizedBox.shrink();
        }
        
        var bits = snapshot.data!;
        
        // Filter bits based on category
        List<TrendingBit> filteredBits;
        
        final bool isExploreAll = widget.category == null || 
                                 widget.category!.easyname?.toLowerCase() == 'explore_all' ||
                                 widget.category!.name.toLowerCase() == 'explore all';

        if (isExploreAll) {
          filteredBits = bits;
        } else {
          final targetFilter = (widget.category!.slug ?? widget.category!.easyname ?? widget.category!.name).toLowerCase();
          
          filteredBits = bits.where((bit) {
            if (bit.category?.toLowerCase() == targetFilter) return true;
            return bit.products.any((product) => 
              product.category?.toLowerCase() == targetFilter
            );
          }).toList();
        }

        // Notify parent about data availability
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onLoaded?.call(filteredBits.isNotEmpty);
        });

        if (filteredBits.isEmpty) {
          return const SizedBox.shrink();
        }

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
                      if (homePageKey.currentState != null) {
                        homePageKey.currentState!.navigateToSubScreen(const AllTrendingScreen());
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AllTrendingScreen()),
                        );
                      }
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
            AlignedGridView.count(
              itemCount: filteredBits.length,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final isEven = index % 2 == 0;
                final double imageHeight = isEven ? 251 : 290;
                return TrendingCard(
                  bit: filteredBits[index],
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
  final double imageHeight;
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
    isLiked = widget.bit.isLiked;
  }

  Future<void> _toggleLike() async {
    if (isApiCallInProgress) return;

    setState(() => isApiCallInProgress = true);

    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    try {
      final response = await _api.toggleLike(widget.bit.id);
      final serverLikeCount = response['likeCount'] as int;
      final serverIsLiked = response['isLiked'] as bool;

      if (mounted) {
        setState(() {
          likeCount = serverLikeCount;
          isLiked = serverIsLiked;
        });
      }
    } catch (e) {
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
        Widget screen;
        if (widget.bit.isLive) {
          final thumbnailObj = Thumbnail.fromJson({
            'url': widget.bit.thumbnailUrl
          });
          final liveSession = Session(
            id: widget.bit.id,
            title: widget.bit.title,
            host: Host(
              id: widget.bit.creatorId,
              username: widget.bit.creatorUsername,
            ),
            status: "live",
            viewersCount: widget.bit.viewCount,
            channelName: '',
            thumbnail: thumbnailObj,
          );
          screen = LiveSessionScreen(sessionId: liveSession.id ?? "");
        } else {
          screen = ReelDetailsScreen(bitId: widget.bit.id);
        }

        // Use HomePage's internal stack to keep Bottom Nav visible
        if (homePageKey.currentState != null) {
          homePageKey.currentState!.navigateToSubScreen(screen);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    child: const Center(child: Icon(Icons.image_not_supported)),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Live',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: 'Encode Sans',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.bit.viewCount.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: 'Encode Sans',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

               if(!widget.bit.isLive)Positioned(
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
                          ? const Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
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
                  widget.bit.creatorUsername,
                  style: const TextStyle(
                    color: Color(0xFF787676),
                    fontSize: 10,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.bit.price > 0 || widget.bit.rating > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.bit.price > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${widget.bit.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Encode Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Strikethrough price for TrendingCard if products have discounts
                            if (widget.bit.products.isNotEmpty && 
                                widget.bit.products.first.discountedPrice != null && 
                                widget.bit.products.first.discountedPrice! < widget.bit.products.first.price)
                              Text(
                                '₹${widget.bit.products.first.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF787676),
                                  fontSize: 12,
                                  fontFamily: 'Encode Sans',
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      if (widget.bit.rating > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 18, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              widget.bit.rating.toStringAsFixed(1),
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
