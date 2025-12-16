import 'package:flutter/material.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? label;
  final VoidCallback onTap;

  const SidebarItem({
    required this.icon,
    this.iconColor = Colors.white,
    this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If there is a label, use the rounded rectangle container (Like, Comment, etc.)
    if (label != null && label!.isNotEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 59,
              height: 80, // Fixed height from the design reference
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.30),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 28),
                  const SizedBox(height: 5),
                  Text(
                    label!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // If there is NO label, it's a simple circular icon (Share, Bookmark, Cart)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.30),
          ),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}
