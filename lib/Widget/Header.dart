import 'package:flutter/material.dart';
import 'package:zatch/model/user_profile_response.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/home_page.dart'; // Added home_page import for homePageKey
import 'package:zatch/view/notification/notification_screen.dart' show NotificationPage;
import 'package:zatch/view/cart_screen.dart';
import '../view/setting_view/profile_screen.dart';

class HeaderWidget extends StatefulWidget {
  final UserProfileResponse? userProfile;
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;
  final bool isSearchable;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final Function(String)? onSearchChanged;
  final Function(String)? onSearchSubmitted;

  const HeaderWidget({
    super.key,
    this.userProfile,
    this.onSearchTap,
    this.onCartTap,
    this.isSearchable = false,
    this.searchController,
    this.searchFocusNode,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });
  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  int cartItemCount = 0;
  int unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartCount();
    _fetchNotificationCount();
  }

  Future<void> _fetchCartCount() async {
    try {
      final cart = await ApiService().getCart(); // call your API
      if (mounted) {
        setState(() {
          cartItemCount = cart?.totalItems ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching cart count: $e");
    }
  }

  Future<void> _fetchNotificationCount() async {
    try {
      final response = await ApiService().getNotifications(limit: 1);
      if (mounted) {
        setState(() {
          unreadNotificationCount = response.unreadCount;
        });
      }
    } catch (e) {
      debugPrint("Error fetching notification count: $e");
    }
  }

  void _handleNavigation(Widget screen) {
    // Unfocus any active text fields before navigating
    FocusScope.of(context).unfocus();
    
    if (homePageKey.currentState != null) {
      homePageKey.currentState!.navigateToSubScreen(screen);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFFD0FB52),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting + username
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hello, Zatcher 👋', style: TextStyle(fontSize: 14, color: Colors.black)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      _handleNavigation(ProfileScreen(userProfile: widget.userProfile));
                    },
                    child: Text(
                      widget.userProfile?.user.username ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ],
              ),

              // Icons
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, color: Colors.black),
                    onPressed: () {
                      _handleNavigation(ProfileScreen(userProfile: widget.userProfile));
                    },
                  ),
                  // Notification icon with badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.black),
                        onPressed: () {
                          _handleNavigation(const NotificationPage());
                        },
                      ),
                      if (unreadNotificationCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadNotificationCount > 9 ? '9+' : '$unreadNotificationCount',
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Cart icon with badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                        onPressed: () {
                          // Unfocus before triggering callback
                          FocusScope.of(context).unfocus();
                          if (widget.onCartTap != null) {
                            widget.onCartTap!();
                          } else {
                            _handleNavigation(CartScreen(
                              onNavigate: (screen) => _handleNavigation(screen),
                            ));
                          }
                        },
                      ),
                      if (cartItemCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$cartItemCount',
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          widget.isSearchable
              ? _buildEditableSearch()
              : _buildReadOnlySearch(),
        ],
      ),
    );
  }
  Widget _buildEditableSearch() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
      child: TextField(
        controller: widget.searchController,
        focusNode: widget.searchFocusNode,
        onChanged: widget.onSearchChanged,
        onSubmitted: widget.onSearchSubmitted,
        decoration: InputDecoration(
          hintText: 'Search Products or People...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          suffixIcon: widget.searchController?.text.isNotEmpty == true
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              widget.searchController?.clear();
              if (widget.onSearchChanged != null) {
                widget.onSearchChanged!('');
              }
            },
          )
              : null,
        ),
      ),
    );
  }

  // Use this for Home Screen
  Widget _buildReadOnlySearch() {
    return GestureDetector(
      onTap: widget.onSearchTap,
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
          child: const TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Search Products or People...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
