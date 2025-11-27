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
import 'navigation_page.dart';

class HomePage extends StatefulWidget {
  final LoginResponse? loginResponse;
  final List<Category>? selectedCategories;

  const HomePage({super.key, this.loginResponse, this.selectedCategories});

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
    final categoryName = _selectedCategory?.name.toLowerCase() ?? 'explore all';
    if (_isSingleCategoryInitiallySelected && _selectedCategory?.id == widget.selectedCategories!.first.id) {
      return _buildSubCategoryGrid();
    }
    if (categoryName == 'explore all') {
      return Column(
        children: [
          const LiveFollowersWidget(),
          const BargainPicksWidget(),
          const FollowersWidget(),
          const TopPicksThisWeekWidget(),
          const TrendingSection(),
          const SizedBox(height: 40),
        ],
      );
    }
    return _buildSubCategoryGrid();
  }
  Widget _buildSubCategoryGrid() {
    final subCategories = _selectedCategory?.subCategories ?? [];

    if (subCategories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text("No sub-categories available.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        itemCount: subCategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Adjust number of columns as needed
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final sub = subCategories[index];
          final imageUrl = sub.image?.url ?? '';

          return InkWell(
              onTap: () {
                // TODO: Implement navigation to sub-category product list screen
                print("Tapped on Sub-category: ${sub.name}");
              },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty ? Icon(Icons.image_not_supported, color: Colors.grey[400]) : null,
                ),
                const SizedBox(height: 8),
                Text(
                  sub.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          );
        },
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
        const SizedBox(height: 25),
        HeaderWidget(userProfile, onSearchTap: () => _onItemTapped(1,fromHeader: true)),
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
        body: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
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

