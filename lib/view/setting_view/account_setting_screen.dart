import 'package:flutter/material.dart';
import 'package:zatch/model/user_profile_response.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/services/preference_service.dart';
import 'package:zatch/view/cart_screen.dart';
import 'package:zatch/view/help_screen.dart';
import 'package:zatch/view/home_page.dart';
import 'package:zatch/view/order_view/order_screen.dart';
import 'package:zatch/view/setting_view/payments_shipping_screen.dart';
import 'package:zatch/view/setting_view/preferences_screen.dart';
import 'package:zatch/view/setting_view/profile_screen.dart';
import 'package:zatch/view/zatching_details_screen.dart';
import 'account_details_screen.dart';
import 'package:zatch/view/policy_screen.dart';
import 'dart:convert';

class AccountSettingsScreen extends StatefulWidget {
  final VoidCallback? onOpenAccountDetails;

  const AccountSettingsScreen({super.key, this.onOpenAccountDetails});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final ApiService _apiService = ApiService();
  UserProfileResponse? userProfile;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserProfile();
    });
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final profileModel = await _apiService.getUserProfile();
      if (mounted) {
        setState(() {
          userProfile = profileModel;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _handleNavigation(Widget screen) {
    if (homePageKey.currentState != null) {
      homePageKey.currentState!.navigateToSubScreen(screen);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    setState(() => isLoading = true);
    final prefs = PreferenceService();

    try {
      await _apiService.logoutUser();
      await prefs.logoutAll();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logout failed: $e")),
        );
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: _appBar("Account Settings"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Error: $error"))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () => _handleNavigation(ProfileScreen(userProfile: userProfile,initialTabIndex: 0,)),
            child: _profileCard(userProfile),
          ),
          const SizedBox(height: 16),
          _settingsContainer(),
        ],
      ),
    );
  }

  Widget _settingsContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _settingsTile(Icons.account_circle, "Account Details", () {
             _handleNavigation(AccountDetailsScreen(userProfile: userProfile));
          }),
          _settingsTile(Icons.shopping_cart, "Zatches", () {
            _handleNavigation(const CartScreen(initialIndex: 1,));
          }),
          _settingsTile(Icons.shopping_cart, "Your Orders", () {
            _handleNavigation(OrdersScreen());
          }),
          _settingsTile(
            Icons.local_shipping,
            "Payments and Shipping",
                () => _handleNavigation(CheckoutOrPaymentsScreen(isCheckout: false)),
          ),
          _settingsTile(Icons.dark_mode, "Dark Mode", () {}),
          _settingsTile(Icons.tune, "Change Preferences in shopping", () {
            _handleNavigation(const PreferencesScreen());
          }),
          _settingsTile(Icons.help_outline, "Help", () {
            _handleNavigation(const HelpScreen());
          }),
          _settingsTile(Icons.info_outline, "Understand Zatch", () {}),
          _settingsTile(Icons.privacy_tip, "Privacy Policy", () {
            _handleNavigation(const PolicyScreen(title: "Privacy Policy"));
          }),
          _settingsTile(Icons.description, "Terms & Conditions", () {
            _handleNavigation(const PolicyScreen(title: "Terms & Conditions"));
          }),
          _settingsTile(
            Icons.logout,
            "Log out",
            _showLogoutConfirmationDialog,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar(String title) {
    return AppBar(
      backgroundColor: const Color(0xFFF2F2F2),
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _profileCard(UserProfileResponse? userProfile) {
    final name = userProfile?.user.username ?? "Unknown User";
    final followers = userProfile?.user.followerCount ?? 0;
    final following = userProfile?.user.following.length ?? 0;
    final profilePicUrl =
    (userProfile?.user.profilePic.url.isNotEmpty ?? false)
        ? userProfile!.user.profilePic.url
        : "";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
            profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
            child: profilePicUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "$following Following",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
