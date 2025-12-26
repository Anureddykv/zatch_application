import 'package:flutter/material.dart';
import 'package:zatch/Widget/category_tabs_widget.dart';
import 'package:zatch/model/categories_response.dart';
import 'package:zatch/model/login_response.dart';
import 'package:zatch/model/user_profile_response.dart';
import 'package:zatch/sellersscreens/SellHomeScreen.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/search_view/search_screen.dart';
import 'package:zatch/view/setting_view/account_setting_screen.dart';
import 'package:zatch/view/zatch_ai_screen.dart';
import 'package:zatch/view/product_view/product_detail_screen.dart';
import 'package:zatch/view/product_view/see_all_top_picks_screen.dart';
import 'package:zatch/view/LiveDetailsScreen.dart';
import 'package:zatch/view/ReelDetailsScreen.dart';
import '../Widget/Header.dart';
import '../Widget/bargain_picks_widget.dart';
import '../Widget/followers_widget.dart';
import '../Widget/live_followers_widget.dart';
import '../Widget/top_picks_this_week_widget.dart';
import '../Widget/trending.dart';
import 'cart_screen.dart';
import 'navigation_page.dart';

// Update the key type to the now-public HomePageState
final GlobalKey<HomePageState> homePageKey = GlobalKey<HomePageState>();

class HomePage extends StatefulWidget {
  final LoginResponse? loginResponse;
  final List<Category>? selectedCategories;
  final int initialIndex;

  HomePage({
    Key? key,
    this.loginResponse,
    this.selectedCategories,
    this.initialIndex = 0,
  }) : super(key: key ?? homePageKey);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  UserProfileResponse? userProfile;
  bool isLoading = true;
  String? error;
  Category? _selectedCategory;
  
  // Tracking data availability across sections
  final Map<String, bool> _sectionHasData = {
    'live': true,
    'bargain': true,
    'followers': true,
    'topPicks': true,
    'trending': true,
  };

  // Track selected categories in state
  List<Category>? _currentSelectedCategories;

  bool _shouldShowKeyboardOnSearch = false;
  final List<Widget> _subScreenStack = [];

  void navigateToSubScreen(Widget screen) {
    if (!mounted) return;
    setState(() {
      _subScreenStack.add(screen);
    });
  }

  void replaceSubScreen(Widget screen) {
    if (!mounted) return;
    setState(() {
      if (_subScreenStack.isNotEmpty) {
        _subScreenStack.removeLast();
      }
      _subScreenStack.add(screen);
    });
  }

  void closeSubScreen() {
    if (!mounted) return;
    setState(() {
      if (_subScreenStack.isNotEmpty) {
        _subScreenStack.removeLast();
      }
    });
    // Refresh profile when returning from a sub-screen (like Edit Profile)
    fetchUserProfile(showLoading: false);
  }

  void updateSelectedCategories(List<Category> categories) {
    if (!mounted) return;
    setState(() {
      _currentSelectedCategories = categories;
      _subScreenStack.clear();
      _selectedIndex = 0;
      _selectedCategory = null;
    });
  }

  bool get hasSubScreen => _subScreenStack.isNotEmpty;

  bool _shouldShowNavBar() {
    if (!hasSubScreen) return true;
    final topScreen = _subScreenStack.last;
    if (topScreen is ProductDetailScreen || 
        topScreen is LiveStreamScreen || 
        topScreen is ReelDetailsScreen ||
        topScreen is SeeAllTopPicksScreen) {
      return false;
    }
    return true;
  }

  // ✅ Made public to allow navigation from ProductDetailScreen
  void onItemTapped(int index, {bool fromHeader = false}) {
    if (hasSubScreen) {
      setState(() {
        _subScreenStack.clear();
      });
    }
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _shouldShowKeyboardOnSearch = fromHeader;
      } else {
        _shouldShowKeyboardOnSearch = false;
      }
    });

    // Refresh profile when switching to profile tab or back home
    if (index == 3 || index == 0) {
      fetchUserProfile(showLoading: false);
    }
  }

  void _openZatchAi() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ZatchAiScreen(),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _currentSelectedCategories = widget.selectedCategories;
    if (mounted) {
      _apiService.init().then((_) {
        fetchUserProfile();
      });
    }
  }

  Future<void> fetchUserProfile({bool showLoading = true}) async {
    if (!mounted) return;
    if (showLoading) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }
    try {
      final profileModel = await _apiService.getUserProfile();
      if (mounted) {
        setState(() {
          userProfile = profileModel;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && showLoading) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _updateSectionDataState(String section, bool hasData) {
    if (_sectionHasData[section] != hasData) {
      setState(() {
        _sectionHasData[section] = hasData;
      });
    }
  }

  Widget _buildHomeTab() {
    if (isLoading && userProfile == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFA3DD00)));
    }
    if (error != null && userProfile == null) {
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

    // Check if ALL sections are empty
    bool allEmpty = !_sectionHasData.values.contains(true);
    final bool isExploreAll = _selectedCategory == null || 
                             _selectedCategory!.easyname?.toLowerCase() == 'explore_all' ||
                             _selectedCategory!.name.toLowerCase() == 'explore all';

    return Column(
      children: [
        SafeArea(
          child: HeaderWidget(
            userProfile: userProfile,
            onSearchTap: () => onItemTapped(1, fromHeader: true),
            onCartTap: () {
              navigateToSubScreen(
                CartScreen(
                  onNavigate: (Widget nextScreen) => navigateToSubScreen(nextScreen),initialIndex: 0,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                CategoryTabsWidget(
                  selectedCategories: _currentSelectedCategories,
                  onCategorySelected: (category) {
                    if (_selectedCategory?.id != category.id) {
                      setState(() {
                        _selectedCategory = category;
                        // Reset visibility flags when category changes to allow re-evaluation
                        _sectionHasData.updateAll((key, value) => true);
                      });
                    }
                  },
                ),
                
                if (!isExploreAll && allEmpty) 
                  _buildNoContentFound()
                else ...[
                  LiveFollowersWidget(
                    category: _selectedCategory, 
                    onLoaded: (hasData) => _updateSectionDataState('live', hasData)
                  ),
                  BargainPicksWidget(
                    category: _selectedCategory, 
                    onLoaded: (hasData) => _updateSectionDataState('bargain', hasData)
                  ),
                  FollowersWidget(
                    category: _selectedCategory, 
                    onLoaded: (hasData) => _updateSectionDataState('followers', hasData)
                  ),
                  TopPicksThisWeekWidget(
                    category: _selectedCategory,
                    onLoaded: (hasData) => _updateSectionDataState('topPicks', hasData)
                  ),
                  TrendingSection(
                    category: _selectedCategory,
                    onLoaded: (hasData) => _updateSectionDataState('trending', hasData)
                  ),
                ],
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoContentFound() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No content found for \"${_selectedCategory?.name ?? 'this category'}\"",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontFamily: 'Encode Sans'
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try exploring other categories or check back later.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
              fontFamily: 'Encode Sans'
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeTab(),
      isLoading && userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : SearchScreen(
              userProfile: userProfile,
              autoFocus: _shouldShowKeyboardOnSearch,
              onTabChange: (index) {
                setState(() => _selectedIndex = index);
              },
              onCartTap: () {
                navigateToSubScreen(
                  CartScreen(
                    onNavigate: (Widget nextScreen) => navigateToSubScreen(nextScreen),
                  ),
                );
              },
              onNavigate: (Widget screen) => navigateToSubScreen(screen),
            ),
      SellHomeScreen(),
      AccountSettingsScreen(),
    ];

    final bool showNavBar = _shouldShowNavBar();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (hasSubScreen) {
          closeSubScreen();
        } else if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        } else {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: hasSubScreen ? _subScreenStack.last : IndexedStack(index: _selectedIndex, children: pages),
        bottomNavigationBar: showNavBar ? CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) {
            onItemTapped(index);
          },
          userProfile: userProfile,
        ) : null,
        floatingActionButton: showNavBar ? AbsorbPointer(
          absorbing: true, // ✅ Enabled FAB
          child: FloatingZButton(onPressed: _openZatchAi),
        ) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
