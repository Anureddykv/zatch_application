import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zatch_app/Widget/Header.dart';
import 'package:zatch_app/controller/live_stream_controller.dart';
import 'package:zatch_app/model/user_model.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/model/ExploreApiRes.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/ReelDetailsScreen.dart';
import 'package:zatch_app/view/cart_screen.dart';
import 'package:zatch_app/view/product_view/product_detail_screen.dart';
import 'package:zatch_app/view/profile/profile_screen.dart';

// Main Search Screen Widget
class SearchScreen extends StatefulWidget {
  final UserProfileResponse? userProfile;
  final bool autoFocus;

  const SearchScreen({super.key, this.userProfile,this.autoFocus = false,});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  bool _hasSubmittedSearch = false;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  final FocusNode _searchFocusNode = FocusNode();

  List<String> searchHistory = [];
  List<String> popularSearches = [];
  List<Bits> exploreBits = [];

  bool isLoading = true;

  List<UserModel> _allPeople = [];
  List<Product> _allProducts = [];

  List<UserModel> _searchResultsPeople = [];
  List<Product> _searchResultsProducts = [];
  // MODIFIED: Added a list for filtered bits
  List<Bits> _searchResultsBits = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSearchHistory();
    _fetchInitialData();

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        }
      });
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() => isLoading = true);
    try {
      final api = ApiService();
      final searchHistoryResponse = await api.getUserSearchHistory();
      popularSearches =
          searchHistoryResponse.searchHistory.map((e) => e.query).toList();
      final exploreRes = await api.getExploreBits();
      exploreBits = exploreRes;
      _searchResultsBits = exploreRes;
      final peopleRes = await api.getAllUsers();
      _allPeople = peopleRes.users;
      final productsRes = await api.getProducts();
      _allProducts = productsRes;
    } catch (e, st) {
      debugPrint("Error fetching initial API data: $e\n$st");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _performSearch(String query) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      setState(() {
        _hasSubmittedSearch = false;
        _searchResultsPeople.clear();
        _searchResultsProducts.clear();
        _searchResultsBits = exploreBits;
      });
      return;
    }
   /* _addSearch(query);*/
    setState(() {
      _searchResultsPeople = _allPeople
          .where((u) => u.displayName.toLowerCase().contains(trimmedQuery))
          .toList();

      _searchResultsProducts = _allProducts
          .where((p) => p.name.toLowerCase().contains(trimmedQuery) ||
          p.description.toLowerCase().contains(trimmedQuery))
          .toList();

      _searchResultsBits = exploreBits
          .where((bit) => bit.title.toLowerCase().contains(trimmedQuery))
          .toList();
    });
  }

  void _onSearchSubmitted(String query) {
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter at least 3 characters to search"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _hasSubmittedSearch = true;
    });
    _addSearch(trimmed);
    _performSearch(trimmed);
  }


  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        searchHistory = prefs.getStringList("searchHistory") ?? [];
      });
    }
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("searchHistory", searchHistory);
  }

  void _addSearch(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty || searchHistory.contains(trimmedQuery)) return;
    setState(() {
      searchHistory.insert(0, trimmedQuery);
      if (searchHistory.length > 10) {
        searchHistory = searchHistory.sublist(0, 10);
      }
    });
    _saveSearchHistory();
  }

  void _clearSearch() {
    setState(() => searchHistory.clear());
    _saveSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _hasSubmittedSearch && _searchController.text.isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        if (isSearching) {
          _searchController.clear();
          _performSearch('');
          FocusScope.of(context).unfocus();
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
               HeaderWidget(
                userProfile: widget.userProfile,
                onCartTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                ),
                isSearchable: true,
                searchController: _searchController,
                searchFocusNode: _searchFocusNode,
                onSearchSubmitted: _onSearchSubmitted,
                onSearchChanged: (val) {
                  if (val.isEmpty) {
                    _performSearch('');
                  } else {
                    setState(() {});
                  }
                },

                onSearchTap: () {
                  FocusScope.of(context).requestFocus(_searchFocusNode);
                },
              ),

              Expanded(
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xffd5ff4d)),
                )
                    : isSearching
                    ? _buildSearchResults()
                    : _buildInitialBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Sections ---
  Widget _buildInitialBody() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (searchHistory.isNotEmpty) _buildLastSearch(),
        if (popularSearches.isNotEmpty) _buildPopularSearch(),
        if (_allProducts.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSection(
            "Products",
            _allProducts.take(4).toList(),
            onSeeAll: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductListScreen(products: _allProducts),
              ),
            ),
          ),
        ],
        if (_allPeople.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSection(
            "People",
            _allPeople.take(6).toList(),
            onSeeAll: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PeopleListScreen(people: _allPeople),
              ),
            ),
          ),
        ],
        if (exploreBits.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSection(
            "Explore",
            exploreBits,
            onSeeAll: () {
              _searchController.text = " ";
              _performSearch(" ");
              _tabController.index = 3;
            },
          ),
        ],
      ],
    ),
  );

  Widget _buildLastSearch() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Last Search",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          TextButton(
            onPressed: _clearSearch,
            child: const Text(
              "Clear All",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      Wrap(
        spacing: 8,
        children: searchHistory
            .map(
              (search) => InputChip(
            label: Text(search,style: TextStyle(color: Color(0xFF696969)),),
            onPressed: () {
              _searchController.text = search;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchController.text.length),
              );
              _performSearch(search);
            },
            deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF696969),),
            onDeleted: () {
              setState(() => searchHistory.remove(search));
              _saveSearchHistory();
            },
                shape: const StadiumBorder(
                   side: BorderSide(color: Color(0xFF8B8E97)),
                ),
          ),
        )
            .toList(),
      ),
    ],
  );

  Widget _buildPopularSearch() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Popular Search",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 12),
      ...popularSearches.map(
            (search) => ListTile(
          leading: const CircleAvatar(
            backgroundImage: NetworkImage("https://placehold.co/95x118"),
          ),
          title: Text(search),
          subtitle: const Text("Trending product"),
          trailing: const Text("212.99 ₹"),
          onTap: () {
            _searchController.text = search;
            _performSearch(search);
          },
        ),
      ),
      const SizedBox(height: 20),
    ],
  );

  Widget _buildExploreGrid(List<Bits> bits) {
    if (bits.isEmpty) {
      return const Center(heightFactor: 5, child: Text("No bits found."));
    }
    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(bits.length, (index) {
        final bit = bits[index];
        final isTall = index % 3 == 0;

        return StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: isTall ? 1.5 : 1,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReelDetailsScreen(
                  bitId: bit.id,
                  controller: LiveStreamController(),
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    // Use the bit's thumbnail URL if it exists, otherwise a placeholder
                    bit.thumbnail.url ?? "https://placehold.co/300x500",
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        bit.type == 'video'
                            ? Icons.videocam_off_outlined
                            : Icons.image_not_supported_outlined,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                  // Overlay with a subtle gradient for text readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),

                  // Display the bit type icon (video or image)
                  if (bit.type == 'video')
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white70,
                        size: 40,
                      ),
                    ),

                  // Display the title at the bottom
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      bit.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        shadows: [
                          Shadow(blurRadius: 2, color: Colors.black54)
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSection(
      String title,
      List items, {
        required VoidCallback onSeeAll,
      }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              TextButton(
                onPressed: onSeeAll,
                child: const Text("See All"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (title == "Products" && items.isNotEmpty)
            _searchProductsTab(items.cast<Product>(), simple: true),
          if (title == "People" && items.isNotEmpty)
            _searchPeopleTab(items.cast<UserModel>(), simple: true),
          // MODIFIED: Pass the correct list to the grid
          if (title == "Explore" && items.isNotEmpty)
            _buildExploreGrid(items.cast<Bits>())
        ],
      );

  // --- Search Results UI ---
  Widget _buildSearchResults() {
    return Column(
      children: [
        TabBar(
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade600,
          indicator: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          controller: _tabController,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "People"),
            Tab(text: "Products"),
            Tab(text: "Buy Bits"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _searchAllTab(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _searchPeopleTab(_searchResultsPeople),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _searchProductsTab(_searchResultsProducts),
              ),
              SingleChildScrollView(child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildExploreGrid(_searchResultsBits),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchAllTab() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      if (_searchResultsProducts.isNotEmpty) ...[
        const Text(
          "Products",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        _searchProductsTab(_searchResultsProducts, simple: true),
        const SizedBox(height: 20),
      ],
      if (_searchResultsPeople.isNotEmpty) ...[
        const Text(
          "People",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        _searchPeopleTab(_searchResultsPeople, simple: true),
        const SizedBox(height: 20),
      ],
      if (_searchResultsBits.isNotEmpty) ...[
        const Text(
          "Buy Bits",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        _buildExploreGrid(_searchResultsBits),
      ],
    ],
  );

  Widget _searchProductsTab(List<Product> products, {bool simple = false}) {
    if (products.isEmpty) {
      return const Center(heightFactor: 5, child: Text("No products found"));
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: simple,
      physics: simple ? const NeverScrollableScrollPhysics() : null,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreen(productId: product.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric( vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Product Image
                Container(
                  width: 57,
                  height: 57,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Image.network(
                    product.images.isNotEmpty
                        ? product.images.first.url
                        : "https://placehold.co/95x118",
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // 2. Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Color(0xFF121111),
                          fontSize: 14,
                          fontFamily: 'Encode Sans',
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category ?? "Product",
                        style: const TextStyle(
                          color: Color(0xFF787676),
                          fontSize: 10,
                          fontFamily: 'Encode Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${product.price} ₹',
                        style: const TextStyle(
                          color: Color(0xFF292526),
                          fontSize: 12,
                          fontFamily: 'Encode Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (product.isTopPick == true)
                  Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFBBF711),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(48),
                      ),
                    ),
                    child: const Text(
                      'Trending',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  String _formatFollowerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
  Widget _searchPeopleTab(List<UserModel> people, {bool simple = false}) {

    if (people.isEmpty) {
      return const Center(heightFactor: 5, child: Text("No people found"));
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: simple,
      physics: simple ? const NeverScrollableScrollPhysics() : null,
      itemCount: people.length,
      itemBuilder: (context, index) {
        final user = people[index];
        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: user.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28.5,
                  backgroundImage: (user.profilePic?.url?.isNotEmpty ?? false)
                      ? NetworkImage(user.profilePic!.url!)
                      : null,
                  child: (user.profilePic?.url == null || user.profilePic!.url!.isEmpty)
                      ? const Icon(Icons.person, size: 30, color: Colors.grey)
                      : null,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 15),
                // 2. User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          color: Color(0xFF121111),
                          fontSize: 17,
                          fontFamily: 'Encode Sans',
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _formatFollowerCount(user.followerCount ?? 0),
                              style: const TextStyle(
                                color: Color(0xFF6B6B6B),
                                fontSize: 12,
                                fontFamily: 'Encode Sans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(
                              text: ' Followers',
                              style: TextStyle(
                                color: Color(0xFF787676),
                                fontSize: 10,
                                fontFamily: 'Encode Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class ProductListScreen extends StatefulWidget {
  final List<Product> products;
  const ProductListScreen({super.key, required this.products});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final TextEditingController _searchController;
  late List<Product> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredProducts = widget.products;
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text;
    setState(() {
      _filteredProducts = widget.products
          .where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'All Products',
          style: TextStyle(
            color: Color(0xFF121111),
            fontSize: 16,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: ShapeDecoration(
                color: const Color(0xFFEFF3EE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF626262), size: 20),
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: Color(0xFF626262),
                    fontSize: 14,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w300,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: Color(0xFF272727),
                  fontSize: 14,
                  fontFamily: 'Encode Sans',
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text("No products found."))
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(35, 10, 35, 20),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.7,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(productId: product.id),
                    ),
                  ),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF4F4F4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                  child: Image.network(
                                    product.images.isNotEmpty
                                        ? product.images.first.url
                                        : "https://placehold.co/168x139",
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                    const Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.favorite_border,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      // TODO: Implement favorite
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(14, 8, 14, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  color: Color(0xFF272727),
                                  fontSize: 12,
                                  fontFamily: 'Encode Sans',
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹ ${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF272727),
                                  fontSize: 12,
                                  fontFamily: 'Encode Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PeopleListScreen extends StatelessWidget {
  final List<UserModel> people;
  const PeopleListScreen({super.key, required this.people});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All People"),
        backgroundColor: const Color(0xffd5ff4d),
        foregroundColor: Colors.black,
      ),
      body: people.isEmpty
          ? const Center(child: Text("No users to display."))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: people.length,
        itemBuilder: (context, index) {
          final user = people[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(userId: user.id),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: CircleAvatar(
                    radius: double.infinity,
                    backgroundImage:
                    (user.profilePic?.url?.isNotEmpty ?? false)
                        ? NetworkImage(user.profilePic!.url!)
                        : null,
                    child: (user.profilePic?.url?.isEmpty ?? true)
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.displayName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
