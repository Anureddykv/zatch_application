import 'package:flutter/material.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/help_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchCartCount();
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
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ProfileScreen(widget.userProfile),
                      ));
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen(widget.userProfile))
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpScreen(),
                        ),
                      );
                    },
                  ),
                  // Cart icon with badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                        onPressed: widget.onCartTap,
                      ),
                      if (cartItemCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text(
                              '$cartItemCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
