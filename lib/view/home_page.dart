import 'package:flutter/material.dart';
import 'package:zatch_app/Widget/category_tabs_widget.dart';
import 'package:zatch_app/model/categories_response.dart';
import 'package:zatch_app/model/login_response.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/sellersscreens/SellHomeScreen.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/search_view/search_screen.dart';
import 'package:zatch_app/view/setting_view/account_setting_screen.dart';
import 'package:zatch_app/view/zatch_ai_screen.dart';
import '../Widget/Header.dart';
import '../Widget/bargain_picks_widget.dart';
import '../Widget/followers_widget.dart';
import '../Widget/live_followers_widget.dart';
import '../Widget/top_picks_this_week_widget.dart';
import '../Widget/trending.dart';
import 'cart_screen.dart';
import 'navigation_page.dart';

class HomePage extends StatefulWidget {
  final LoginResponse? loginResponse;
  final List<Category>? selectedCategories;
  final int initialIndex;

  const HomePage({super.key, this.loginResponse, this.selectedCategories, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  UserProfileResponse? userProfile;
  List<Category> _allCategories = [];
  bool isLoading = true;
  String? error;
  Category? _selectedCategory;
  bool get _isSingleCategoryInitiallySelected => widget.selectedCategories?.length == 1 && widget.selectedCategories!.first.name.toLowerCase() != 'explore all';
  bool _shouldShowKeyboardOnSearch = false;
  Widget? _currentSubScreen;
  void _navigateToSubScreen(Widget screen) {
    setState(() {
      _currentSubScreen = screen;
    });
  }
  void _closeSubScreen() {
    setState(() {
      _currentSubScreen = null;
    });
  }
  void _onItemTapped(int index,{bool fromHeader = false}) {
    setState(() {
      _selectedIndex = index;
      if (index == 1 && fromHeader) {
        _shouldShowKeyboardOnSearch = true;
      } else {
        _shouldShowKeyboardOnSearch = false;
      }
    });
  }
  void _openZatchAi() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to be taller than half the screen
      backgroundColor: Colors.transparent, // Makes container's rounded corners visible
      builder: (context) => const ZatchAiScreen(),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    if (mounted) {
      _apiService.init().then((_) {
        fetchUserProfile();
       // _fetchAllCategories();
      });
    }
  }

  Future<void> fetchUserProfile() async {
    if (!mounted) return;

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

  Widget _buildContentForCategory() {
    return Column(
      children: [
        LiveFollowersWidget(category: _selectedCategory),
        BargainPicksWidget(category: _selectedCategory),
        FollowersWidget(category: _selectedCategory),
        TopPicksThisWeekWidget(category: _selectedCategory),
        TrendingSection(category: _selectedCategory),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHomeTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFA3DD00)));
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error ?? "Something went wrong"),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: fetchUserProfile, child: const Text("Retry")),
          ],
        ),
      );
    }
    return Column(
      children: [
        SafeArea(
          child: HeaderWidget(userProfile: userProfile, onSearchTap: () => _onItemTapped(1,fromHeader: true),  onCartTap: () {
            _navigateToSubScreen(
                CartScreen(
                  // Pass the navigation callback so Cart can open details inside Home
                  onNavigate: (Widget nextScreen) => _navigateToSubScreen(nextScreen),
                )
            );
          },),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                CategoryTabsWidget(
                  selectedCategories: widget.selectedCategories,
                  onCategorySelected: (category) {
                    if (_selectedCategory?.id != category.id) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      debugPrint("Selected Category: ${category.name}");
                    }
                  },
                ),
                _buildContentForCategory(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeTab(),
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : SearchScreen(key: UniqueKey(), userProfile: userProfile,autoFocus:_shouldShowKeyboardOnSearch ,),
      SellHomeScreen(),
      AccountSettingsScreen(),
    ];

    return  WillPopScope(
      onWillPop: () async {
        if (_currentSubScreen != null) {
          _closeSubScreen();
          return false;
        }
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _currentSubScreen ?? IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) {
            if (_currentSubScreen != null) _closeSubScreen();
            _onItemTapped(index);
          },
          userProfile: userProfile,
        ),
        floatingActionButton: FloatingZButton(
            onPressed: _openZatchAi,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
