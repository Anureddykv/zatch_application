import 'package:flutter/material.dart';
import 'package:zatch/controller/live_stream_controller.dart';
import 'package:zatch/model/TrendingBit.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/LiveDetailsScreen.dart';
import 'package:zatch/view/ReelDetailsScreen.dart';
import 'package:zatch/view/live_view/live_session_screen.dart';
import 'package:zatch/view/live_view/see_all_live_screen.dart';

class AllTrendingScreen extends StatefulWidget {
  const AllTrendingScreen({super.key});

  @override
  State<AllTrendingScreen> createState() => _AllTrendingScreenState();
}

class _AllTrendingScreenState extends State<AllTrendingScreen> {
  late Future<List<TrendingBit>> trendingFuture;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    trendingFuture = _api.fetchTrendingBits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trending"),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<TrendingBit>>(
        future: trendingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No trending items found."));
          }

          final bits = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 320, // Keep this for card height
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: bits.length,
            itemBuilder: (context, index) {
              // We can reuse the same TrendingCard logic here
              return TrendingCard(bit: bits[index]);
            },
          );
        },
      ),
    );
  }
}

// ✅ USING THE FULLY-FEATURED TRENDING CARD
class TrendingCard extends StatelessWidget {
  final TrendingBit bit;

  const TrendingCard({super.key, required this.bit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Your existing navigation logic is correct
        if (bit.isLive == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>  LiveSessionScreen(sessionId: bit.id))
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReelDetailsScreen(
                bitId: bit.id, // bit.id is not nullable in the corrected model
                controller: LiveStreamController(),
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    // ✅ CORRECTED: Use thumbnailUrl for the image
                    bit.thumbnailUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.error)),
                      );
                    },
                  ),
                  if (bit.isLive) // No need for '== true'
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBBF711),
                          borderRadius: BorderRadius.circular(48),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black.withOpacity(0.6),
                      child: const Icon(Icons.favorite_border,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bit.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Encode Sans',
                      ),
                    ),
                    Text(
                      bit.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                        fontFamily: 'Encode Sans',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // Assuming you want to show view count as the primary stat
                          '${bit.viewCount} views',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Encode Sans',
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              bit.likeCount.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Encode Sans',
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
        ),
      ),
    );
  }
}
