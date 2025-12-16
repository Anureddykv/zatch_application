import 'package:flutter/material.dart';
import 'package:zatch_app/Widget/bargain_picks_widget.dart';
import 'package:zatch_app/view/reel_player_screen.dart';
import 'package:zatch_app/model/ExploreApiRes.dart';

class SeeAllBargainPicksScreen extends StatelessWidget {
  final List<Bits> picks;

  const SeeAllBargainPicksScreen({
    super.key,
    required this.picks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bargain Picks For You',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive Item Width
          // (Total Width - (Padding Left + Padding Right + Spacing)) / 2
          final double itemWidth = (constraints.maxWidth - (16 + 16 + 12)) / 2;

          // Calculate Aspect Ratio:
          // We want the height to be (Width * 1.5) roughly.
          // This ensures the card is taller than it is wide.
          final double itemHeight = itemWidth * 1.5;
          final double aspectRatio = itemWidth / itemHeight;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: aspectRatio, // Dynamic ratio prevents overflow
            ),
            itemCount: picks.length,
            itemBuilder: (context, index) {
              final pick = picks[index];

              return InkWell(
                onTap: () {
                  final List<String> allReelIds = picks.map((p) => p.id).toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReelPlayerScreen(
                        bitIds: allReelIds,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(9),
                child: BargainPickCard(
                  imageUrl: pick.thumbnail.url ?? '',
                  title: pick.title,
                  priceInfo: "Less than ${pick.revenue}",
                  // Pass null here to let the GridView control the size
                  cardImageWidth: null,
                  cardImageHeight: null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
