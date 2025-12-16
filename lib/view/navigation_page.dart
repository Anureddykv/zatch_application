import 'package:flutter/material.dart';
import 'package:zatch_app/model/user_profile_response.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final UserProfileResponse? userProfile;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_filled,
            index: 0,
            isSelected: selectedIndex == 0,
          ),
          _buildNavItem(
            imagePath: "assets/images/search.png",
            index: 1,
            isSelected: selectedIndex == 1,
          ),
          const SizedBox(width: 40),
          _buildNavItem(
            imagePath: "assets/images/holding.png",
            index: 2,
            isSelected: selectedIndex == 2,
          ),
          _buildProfileItem(
            3,
            selectedIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    IconData? icon,
    String? imagePath,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: icon != null
          ? Icon(
              icon,
              color: isSelected ? const Color(0xFFA3DD00) : Colors.grey,
              size: 33,
            )
          : Image.asset(
              imagePath!,
              height: 28,
              color: isSelected ? const Color(0xFFA3DD00) : Colors.grey,
            ),
    );
  }

  Widget _buildProfileItem(int index, bool isSelected) {
    final String? imageUrl = userProfile?.user.profilePic.url;
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: CircleAvatar(
        radius: 16,
        backgroundColor:
            isSelected ? Colors.green.withOpacity(0.2) : Colors.transparent,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(shape: BoxShape.circle,),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Falls back to icon on error (e.g. 403 Forbidden)
                    return const Icon(Icons.person,
                        size: 20, color: Colors.grey);
                  },
                )
              : const Icon(Icons.person, size: 20, color: Colors.grey),
        ),
      ),
    );
  }
}

class FloatingZButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingZButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72, // bigger button
      height: 72,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: const Color(0xFFD0FB52),
        elevation: 8,
        shape: const CircleBorder(),
        child: Image.asset(
          'assets/images/logo.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
