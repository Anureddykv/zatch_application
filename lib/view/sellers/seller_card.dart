import 'package:flutter/material.dart';
import 'package:zatch/model/follower_model.dart';
import 'package:zatch/model/user_model.dart';

/// A reusable card to display a single seller, designed for a grid layout.
class SellerCard extends StatelessWidget {
  final UserModel user;

  const SellerCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // This logic is the same as in your original ListView item
    final String imageUrl = (user.profilePic.url?.isNotEmpty ?? false)
        ? user.profilePic.url!
        : (user.profileImageUrl?.isNotEmpty ?? false)
        ? user.profileImageUrl!
        : 'https://placehold.co/150x150/E0E0E0/B0B0B0?text=${user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : "S"}';

    return InkWell(
      onTap: () {
        // Optional: Implement navigation to the seller's profile page
        debugPrint("Tapped on seller card: ${user.displayName}");
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Image
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(Icons.person, size: 40, color: Colors.grey[500]),
                  ),
                ),
              ),
              const Spacer(), // Used to push content apart vertically

              // Seller Name
              Text(
                user.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Follow Button
              ElevatedButton(
                onPressed: () {
                  // NOTE: To make this button functional, you would need
                  // to use a more advanced state management solution (like Provider
                  // or Riverpod) or pass the _handleToggleFollow function
                  // down to this card.
                  debugPrint("Follow button tapped on grid card for ${user.displayName}");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isFollowing ? Colors.white : const Color(0xFFB7DF4B),
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: Color(0xFFB7DF4B), width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  minimumSize: const Size(100, 36),
                  elevation: 0,
                ),
                child: Text(
                  user.isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
