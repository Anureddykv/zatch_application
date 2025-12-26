import 'package:flutter/material.dart';
import 'package:zatch/model/product_response.dart';
import 'package:zatch/model/user_profile_model.dart';

class ProfileController extends ChangeNotifier {
  bool isFollowing = false;
  int selectedTab = 0;

  /// Buy Bits dummy images
  final List<String> buyBitsImages = [

  ];

  /// Shop products
  final List<Product> shopProducts = [

  ];

  /// Upcoming Lives
  final List<UpcomingLive> upcomingLives = [

  ];

  void toggleFollow() {
    isFollowing = !isFollowing;
    notifyListeners();
  }

  void selectTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  void toggleWishlist(Product product) {
   // product.isWishlisted = !product.isWishlisted;
    notifyListeners();
  }

  void shareProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile link copied")),
    );
  }
}
