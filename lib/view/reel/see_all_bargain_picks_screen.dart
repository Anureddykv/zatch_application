import 'package:flutter/material.dart';
import 'package:zatch_app/Widget/bargain_picks_widget.dart';
import 'package:zatch_app/view/reel_player_screen.dart'; // Correct import for ReelPlayer
import 'package:zatch_app/model/ExploreApiRes.dart';

class SeeAllBargainPicksScreen extends StatelessWidget {
  final List<Bits> picks;

  const SeeAllBargainPicksScreen({
    super.key,
    required this.picks,
  });

  @override
  Widget build(BuildContext context) {
    // Card dimensions can be calculated or fixed
    const double cardImageWidth = 160.0;
    const double cardImageHeight = 220.0;

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
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two cards per row
          crossAxisSpacing: 12.0, // Horizontal space between cards
          mainAxisSpacing: 12.0, // Vertical space between cards
          childAspectRatio: 0.65, // Adjust this ratio to fit your design
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
            borderRadius: BorderRadius.circular(12),
            child: BargainPickCard(
              imageUrl: pick.thumbnail.publicId ?? '',
              title: pick.title,
              priceInfo: "Zatch now!",
              cardImageWidth: cardImageWidth,
              cardImageHeight: cardImageHeight,
            ),
          );
        },
      ),
    );
  }
}

