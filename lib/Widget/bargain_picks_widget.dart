import 'package:flutter/material.dart';
// Note: We don't need the BargainPickController for this widget anymore.
// import 'package:zatch_app/controller/bargain_pick_controller.dart';
import 'package:zatch_app/model/ExploreApiRes.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/reel/see_all_bargain_picks_screen.dart';
import 'package:zatch_app/view/reel_player_screen.dart';

class BargainPicksWidget extends StatefulWidget {
  const BargainPicksWidget({super.key});

  @override
  State<BargainPicksWidget> createState() => _BargainPicksWidgetState();
}

class _BargainPicksWidgetState extends State<BargainPicksWidget> {
  final ApiService _apiService = ApiService();
  late Future<List<Bits>> _picksFuture;
  // The local controller instance is no longer needed here.
  // final BargainPickController _controller = BargainPickController();

  final double cardImageWidth = 120.0;
  final double cardImageHeight = 175.0;

  @override
  void initState() {
    super.initState();
    _picksFuture = _apiService.getExploreBits();
  }

  @override
  Widget build(BuildContext context) {
    const double textSectionHeight = 65.0;
    final double totalCardHeight = cardImageHeight + textSectionHeight;

    return FutureBuilder<List<Bits>>(
      future: _picksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // This is the full list of picks fetched from the API
        final picks = snapshot.data;
        if (picks == null || picks.isEmpty) {
          return const SizedBox.shrink();
        }

        // This is the shortened list for display purposes only
        final displayedPicks = picks.length > 5 ? picks.sublist(0, 5) : picks;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Bargain picks - Zatching now',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeeAllBargainPicksScreen(
                              // ✅ FIX: Pass the full 'picks' list from the FutureBuilder snapshot
                              picks: picks,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: totalCardHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayedPicks.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemBuilder: (context, index) {
                    final pick = displayedPicks[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == displayedPicks.length - 1 ? 0 : 12.0,
                      ),
                      child: InkWell(
                        onTap: () {
                          // Pass the full list of IDs to the player
                          final List<String> allReelIds = picks.map((p) => p.id).toList();
                          final int tappedIndex = allReelIds.indexOf(pick.id);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReelPlayerScreen(
                                bitIds: allReelIds,
                                initialIndex: tappedIndex,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(9),
                        child: BargainPickCard(
                          imageUrl: pick.video.publicId ?? 'zatch/Bits/jts9qktp7en8nrlemo2y',
                          title: pick.title,
                          priceInfo: "Zatch now!",
                          cardImageWidth: cardImageWidth,
                          cardImageHeight: cardImageHeight,
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
  }
}

// ... BargainPickCard widget remains the same
class BargainPickCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String priceInfo;
  final double cardImageWidth;
  final double cardImageHeight;

  const BargainPickCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.priceInfo,
    required this.cardImageWidth,
    required this.cardImageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    return SizedBox(
      width: cardImageWidth,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image with shadow
            Container(
              width: cardImageWidth,
              height: cardImageHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                image: imageUrl.isEmpty
                    ? null
                    : DecorationImage(
                  image: isNetworkImage
                      ? NetworkImage(imageUrl)
                      : AssetImage(imageUrl) as ImageProvider,
                  fit: BoxFit.cover,
                ),
                color: imageUrl.isEmpty ? Colors.grey[200] : null,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: imageUrl.isEmpty
                  ? Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey[400],
                  size: 50,
                ),
              )
                  : null,
            ),
            const SizedBox(height: 8),

            /// Title
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF787676),
                fontSize: 10,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            /// Static "Zatch from" text
            const Text(
              'Zatch from',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2), // Added for spacing

            /// Price info
            Text(
              priceInfo,
              style: const TextStyle(
                color: Color(0xFF94C800),
                fontSize: 12,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
