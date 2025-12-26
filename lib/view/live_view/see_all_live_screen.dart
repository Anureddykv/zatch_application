import 'package:flutter/material.dart';
import 'package:zatch/model/live_session_res.dart';

import 'live_session_card.dart';

class SeeAllLiveScreen extends StatelessWidget {
  final List<Session> liveSessions;

  const SeeAllLiveScreen({
    super.key,
    required this.liveSessions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live From Followers',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Makes back button black
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        // This creates a 2-column grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // The number of columns
          crossAxisSpacing: 4.0, // Horizontal space between cards
          mainAxisSpacing: 4.0, // Vertical space between cards
          childAspectRatio: 0.5, // Adjust to change the card's height-to-width ratio
        ),
        itemCount: liveSessions.length,
        itemBuilder: (context, index) {
          final session = liveSessions[index];
          // Use the reusable card widget
          return LiveSessionCard(liveSession: session);
        },
      ),
    );
  }
}
