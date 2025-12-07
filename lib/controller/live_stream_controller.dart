import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zatch_app/model/LiveSessionResponse.dart';
import 'package:zatch_app/services/api_service.dart';
import '../model/live_session_res.dart';
import '../model/product_response.dart';
import '../view/cart_screen.dart';
import '../view/profile/profile_screen.dart';

class LiveStreamController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Session? session;

  SessionDetails? sessionDetails;
  List<Product> products = [];

  LiveStreamController({this.session, this.sessionDetails});

  bool isLiked = false;
  bool isSaved = false;

  Product? displayedProduct;
  void setProducts(List<Product> newProducts) {
    products = newProducts;
    notifyListeners();
  }

  void toggleLike(BuildContext context) {
    isLiked = !isLiked;
    notifyListeners();
  }

  Future<void> toggleSave(BuildContext context) async {
    if (session == null) return;
    try {
      final response = await _apiService.toggleSaveBit(session!.id);
      isSaved = response.isSaved;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> share(BuildContext context) async {
    if (session == null || session!.id.isEmpty) {
      Share.share("Check out this live stream on Zatch!");
      return;
    }

    try {
      final String shareLink = await _apiService.shareBit(session!.id);
      final hostUsername = session?.host?.username ?? "a user";
      Share.share("Watch $hostUsername's live stream on Zatch: $shareLink");
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not generate share link. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void addToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void buyNow(BuildContext context, Product? product) {
    if (product == null) return;
  }

  void zatchNow(BuildContext context, Product? product) {
    if (product == null) return;
  }

  void openProfile(BuildContext context) {
    if (session?.host?.id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen(userId: session!.host!.id)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }

  }
}
