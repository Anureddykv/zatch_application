// lib/view/profile/profile_image_viewer.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class ProfileImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ProfileImageViewer({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Necessary for the blur effect
      body: GestureDetector(
        // Allow tapping anywhere on the screen to close the viewer
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            // 1. Blurred Background Layer
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                // This container is what gets blurred
                color: Colors.black.withOpacity(0.5),
              ),
            ),

            // 2. Focused Image Layer (sits on top of the blur)
            Center(
              child: Hero(
                tag: heroTag,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.width * 0.85, // Enforce a square
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Use shape for a perfect circle
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        debugPrint('Failed to load profile image: $exception');
                      },
                    ),
                  ),
                  child: imageUrl.contains("placeholder.com")
                      ? const Icon(Icons.person, size: 150, color: Colors.white70)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
