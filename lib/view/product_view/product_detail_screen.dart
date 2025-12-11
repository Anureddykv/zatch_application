import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zatch_app/Widget/bargain_picks_widget.dart';import 'package:zatch_app/Widget/top_picks_this_week_widget.dart';
import 'package:zatch_app/model/CartApiResponse.dart' as cart_model;
import 'package:zatch_app/model/ExploreApiRes.dart';
import 'package:zatch_app/model/carts_model.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/cart_screen.dart';
import 'package:zatch_app/view/setting_view/payments_shipping_screen.dart';
import 'package:zatch_app/view/zatching_details_screen.dart';
import 'package:intl/intl.dart';

import '../setting_view/profile_screen.dart';

class AllReviewsScreen extends StatelessWidget {
  final List<Review> reviews;
  const AllReviewsScreen({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Reviews")),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          final imageUrl = review.reviewerId.profilePic.url;
          final hasImage = imageUrl.isNotEmpty;

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
                  child: !hasImage ? const Icon(Icons.person, size: 20) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerId.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                              (starIndex) => Icon(
                            starIndex < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.comment,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AllCommentsScreen extends StatelessWidget {
  final List<Comment> comments;
  const AllCommentsScreen({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Comments")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: comments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return CommentWidget(comment: comments[index]);
        },
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  UserProfileResponse? userProfile;

  final _pageController = PageController();
  late final TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  int _selectedVariantIndex = -1;
  final ApiService _apiService = ApiService();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _infoTabsKey = GlobalKey();

  bool loading = true;
  String? errorMessage;
  late Product product;
  List<Product> similarProducts = [];
  bool _showAllCommunity = false;
  bool _showAllReviews = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProductDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  Future<void> _refreshUserProfile() async {
    try {
      final profile = await _apiService.getUserProfile();
      if (mounted) {
        setState(() {
          userProfile = profile;
        });
      }
    } catch (e) {
      print("Error refreshing profile: $e");
    }
  }

  Future<void> _loadProductDetails() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final results = await Future.wait([
        _apiService.getProductById(widget.productId),
        _apiService.getTopPicks(),
        _apiService.getUserProfile(),
      ]);

      if (mounted) {
        setState(() {
          product = results[0] as Product;
          similarProducts = results[1] as List<Product>;
          userProfile = results[2] as UserProfileResponse;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Failed to load product: $e";
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null) {
      return Scaffold(body: Center(child: Text(errorMessage!)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildTitlePriceAndRating(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildDescription(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSizeSelector(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildColorSelector(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    key: _infoTabsKey,
                    child: _buildInfoTabs(),
                  ),
                ),
                TopPicksThisWeekWidget(
                  title: "Similar products",
                  showSeeAll: false,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildPolicySection(),
                ),
                TopPicksThisWeekWidget(
                  title: "Products from this seller",
                  showSeeAll: false,
                ),
                const SizedBox(height: 32),
                const BargainPicksWidget(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildCircleIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFDFDEDE), width: 1),
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 450.0,pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Center(
          child: _buildCircleIcon(
            Icons.arrow_back_ios_new,
                () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            ),
          )
        else

          _buildCircleIcon(
              (userProfile != null && _isProductSaved(userProfile!, widget.productId))
                  ? Icons.bookmark
                  : Icons.bookmark_border,

                  () async {
                if (_isSaving) return;
                setState(() {
                  _isSaving = true;
                });

                try {
                  await _apiService.toggleSaveProduct(widget.productId);

                  await _refreshUserProfile();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Wishlist updated!")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSaving = false;
                    });
                  }
                }
              }
          ),
        const SizedBox(width: 8),
        _buildCircleIcon(Icons.add_shopping_cart_outlined, () async {
          if (product.variants.isNotEmpty && _selectedVariantIndex == -1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please select a color/size first"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Adding to cart..."),
              duration: Duration(seconds: 1),
            ),
          );

          try {
            String? finalColor;
            String? finalSize;

            if (_selectedVariantIndex != -1) {
              finalColor = product.variants[_selectedVariantIndex].shade ?? product.variants[_selectedVariantIndex].color;
              finalSize = product.variants[_selectedVariantIndex].sku;
            }
            print("🚀 SENDING ADD TO CART REQUEST:");
            print("Product ID: ${widget.productId}");
            print("Quantity: 1");
            print("Color: $finalColor");
            await _apiService.updateCartItem(
              productId: widget.productId,
              quantity: 1,
              color: finalColor,

            );
            try {
              final updatedProfile = await _apiService.getUserProfile();
              if (mounted) {
                setState(() {
                  userProfile = updatedProfile;
                });
              }
            } catch (e) {
              print("Failed to refresh profile: $e");
              // We don't stop execution here because the cart item was added successfully
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Successfully added to Cart!"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // 1. The Carousel PageView
            product.images.isNotEmpty
                ? PageView.builder(
              controller: _pageController,
              itemCount: product.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageViewer(
                          imageUrl: product.images[index].url,
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    product.images[index].url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.error)),
                  ),
                );
              },
            )
                : Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.image_not_supported)),
            ),

            // 2. The Dots Indicator (Only show if more than 1 image)
            if (product.images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: product.images.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitlePriceAndRating() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF121111),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      _tabController.animateTo(2); // Switch to Reviews tab
                      if (_infoTabsKey.currentContext != null) {
                        Scrollable.ensureVisible(
                          _infoTabsKey.currentContext!,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${product.averageRating?.toStringAsFixed(1) ?? '0.0'} ',
                            style: const TextStyle(
                              color: Color(0xFF787676),
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: '(${product.reviews.length} reviews)',
                            style: const TextStyle(
                              color: Color(0xFF347EFB),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            '${product.price} ₹',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF292526),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildDescription() {
    return Text(
      product.description,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF787676),
        height: 1.5,
      ),
    );
  }

  // === UPDATED TO USE CLASS VARIABLES ===
  Widget _buildSizeSelector() {
    final variantsWithSizes = product.variants
        .where((v) => v.sku != null && v.sku!.isNotEmpty)
        .toList();

    if (variantsWithSizes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Size',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(variantsWithSizes.length, (index) {
            final variant = variantsWithSizes[index];
            final originalIndex = product.variants.indexOf(variant);
            final isSelected = _selectedVariantIndex == originalIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVariantIndex = originalIndex;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF292526) : Colors.transparent,
                  border: Border.all(color: const Color(0xFFDFDEDE)),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  variant.sku ?? "",
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF292526),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }),
        ),

      ],
    );
  }

  Widget _buildColorSelector() {
    // Filter only variants that actually have color or shade
    final variants = product.variants
        .where((v) => (v.shade?.isNotEmpty == true) || (v.color?.isNotEmpty == true))
        .toList();

    if (variants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Color',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(variants.length, (index) {
            final variant = variants[index];
            final label = variant.shade?.isNotEmpty == true
                ? variant.shade!
                : variant.color ?? "";
            final originalIndex = product.variants.indexOf(variant);
            final isSelected = _selectedVariantIndex == originalIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVariantIndex = originalIndex;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.black : const Color(0xFFDFDEDE),
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                  ),
                ),
              ),
            );
          }),
        ),

      ],
    );
  }

  Widget _buildInfoTabs() {
    return Column(
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2EE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            dividerColor: Colors.transparent,
            indicatorPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 4,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              const Tab(text: 'Basic Info'),
              Tab(text: 'Comments (${product.comments?.length ?? 0})'),
              Tab(text: 'Reviews (${product.reviews.length})'),
            ],
          ),
        ),
        SizedBox(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(),
                _buildCommunityTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Description",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(product.description.toString()),
          const SizedBox(height: 16),
          const Text(
            "Additional Information",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(product.description.toString()),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    final comments = product.comments ?? [];
    if (comments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No comments yet."),
        ),
      );
    }
    final bool canExpand = comments.length <= 10;
    final displayCount = _showAllCommunity
        ? comments.length
        : (comments.length > 2 ? 2 : comments.length);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayCount,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return CommentWidget(comment: comments[index]);
            },
          ),
          if (comments.length > 2 && !_showAllCommunity)
            GestureDetector(
              onTap: () {
                if (canExpand) {
                  setState(() => _showAllCommunity = true);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllCommentsScreen(comments: comments),
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: Text(
                    "View all",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SizedBox(
              height: 52,
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add Comments',
                  hintStyle: const TextStyle(
                    color: Color(0xFF899092),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.23,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement API call to post a comment
                        print("Comment submitted: ${_commentController.text}");
                        _commentController.clear();
                        FocusScope.of(context).unfocus();
                      },
                      child: const CircleAvatar(
                        radius: 19,
                        backgroundColor: Color(0xFFA2DC00),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildReviewsTab() {
    final reviews = product.reviews;
    final bool canExpand = reviews.length <= 10;
    final displayCount = _showAllReviews
        ? reviews.length
        : (reviews.length > 2 ? 2 : reviews.length);

    if (reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No reviews yet."),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayCount,
            itemBuilder: (context, index) {
              final review = reviews[index];
              final imageUrl = review.reviewerId.profilePic.url;
              final hasImage = imageUrl.isNotEmpty;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
                      child:
                      !hasImage ? const Icon(Icons.person, size: 20) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.reviewerId.username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                              5,
                                  (starIndex) => Icon(
                                starIndex < review.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review.comment,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (reviews.length > 2 && !_showAllReviews)
            GestureDetector(
              onTap: () {
                if (canExpand) {
                  setState(() => _showAllReviews = true);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllReviewsScreen(reviews: reviews),
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text("View all", style: TextStyle(color: Colors.blue)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                // showReviewDialog(context, product);
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF0F0F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.23, right: 20.23),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add a Review',
                          style: TextStyle(
                            color: Color(0xFF899092),
                            fontSize: 16,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.08,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 24,
                          color: Color(0xFF899092),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Policies",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.local_shipping_outlined,
              color: Colors.black,
            ),
            title: const Text(
              "Free Flat Rate Shipping",
              style: TextStyle(fontSize: 14),
            ),
            subtitle: const Text(
              "Estimated to be delivered on 09/11/2021 - 12/11/2021.",
              style: TextStyle(fontSize: 12, color: Color(0xFF555555)),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Details about free flat rate shipping."),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0x33555555)),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: const ExpansionTile(
            tilePadding: EdgeInsets.zero,
            leading: Icon(Icons.money_off_csred_outlined, color: Colors.black),
            title: Text("COD Policy", style: TextStyle(fontSize: 14)),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Details about our Cash On Delivery policy."),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0x33555555)),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: const ExpansionTile(
            tilePadding: EdgeInsets.zero,
            leading: Icon(
              Icons.assignment_return_outlined,
              color: Colors.black,
            ),
            title: Text("Return Policy", style: TextStyle(fontSize: 14)),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Details about our return policy."),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ZatchingDetailsScreen(
                      zatch: Zatch(
                        id: "temp1",
                        name: product.name,
                        description: product?.description ?? "",
                        seller: "Seller Name", // TODO: Update with real data
                        imageUrl: product.images.isNotEmpty
                            ? product.images.first.url
                            : '',
                        active: true,
                        status: "My Offer",
                        quotePrice: "${product.price.toStringAsFixed(0)} ₹",
                        sellerPrice: "${product.price.toStringAsFixed(0)} ₹",
                        quantity: 1,
                        subTotal: "${(product.price * 1).toStringAsFixed(0)} ₹",
                        date: DateTime.now().toString(),
                      ),
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF249B3E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Zatch',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (product.variants.isNotEmpty &&
                    _selectedVariantIndex == -1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a color/size")),
                  );
                  return;
                }

                String? selectedShade;
                String? selectedSize;

                if (_selectedVariantIndex != -1) {
                  selectedShade = product.variants[_selectedVariantIndex].shade ?? product.variants[_selectedVariantIndex].color;
                  selectedSize =  product.variants[_selectedVariantIndex].sku;
                }
                final itemToPurchase = cart_model.CartItemModel(
                  id: "temp_${product.id}",
                  productId: product.id,
                  name: product.name,
                  description: product.description,
                  price: product.price.toDouble(),
                  discountedPrice: product.price.toDouble(),
                  image: product.images.isNotEmpty ? product.images.first.url : "",
                  images: product.images
                      .map((img) => cart_model.ImageModel(
                      id: img.id, publicId: img.publicId, url: img.url))
                      .toList(),
                  variant: cart_model.VariantModel(
                    color: selectedShade,
                    size: selectedSize,
                  ),
                  selectedVariant: {
                    "color": selectedShade,
                    "size": selectedSize,
                  },
                  quantity: 1,
                  category: product.category ?? "",
                  subCategory: product.subCategory ?? "",
                  lineTotal: product.price.toInt(),
                );

                final List<cart_model.CartItemModel> itemsForCheckout = [itemToPurchase];
                final double totalPrice = product.price;
                const double shippingFee = 10.0;
                final double subTotalPrice = totalPrice + shippingFee;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutOrPaymentsScreen(
                      isCheckout: true,
                      selectedItems: itemsForCheckout,
                      itemsTotalPrice: totalPrice,
                      shippingFee: shippingFee,
                      subTotalPrice: subTotalPrice,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF249B3E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isProductSaved(UserProfileResponse profile, String productId) {
    return false;
  }
}
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    body: Center(
      child: InteractiveViewer(
        panEnabled: false,
        minScale: 1.0,
        maxScale: 4.0,
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.white, size: 48);
          },
        ),
      ),
    ),
  );
  }
}

class CommentWidget extends StatefulWidget {
  final Comment comment;
  const CommentWidget({super.key, required this.comment});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _isReplying = false;
  final TextEditingController _replyController = TextEditingController();

  late int _likesCount;
  bool _isLiked = false;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.comment.likes;
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _handleLike() {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
      if (_isLiked) {
        _likesCount--;
        _isLiked = false;
      } else {
        _likesCount++;
        _isLiked = true;
      }
    });

    // TODO: Call your API to like/unlike the comment using widget.comment.id
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    });
  }

  Widget _buildReplyInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 54.0, top: 8.0),
      child: SizedBox(
        height: 52,
        child: TextField(
          controller: _replyController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Reply to ${widget.comment.user?.username ?? 'user'}...',
            hintStyle: const TextStyle(color: Color(0xFF899092), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF0F0F0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(7.0),
              child: GestureDetector(
                onTap: () {
                  if (_replyController.text.isNotEmpty) {
                    print(
                      "Replying to ${widget.comment.user?.username}: ${_replyController.text}",
                    );
                    _replyController.clear();
                    setState(() => _isReplying = false);
                    FocusScope.of(context).unfocus();
                  }
                },
                child: const CircleAvatar(
                  radius: 19,
                  backgroundColor: Color(0xFFA2DC00),
                  child: Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.comment.user;
    final userName = user?.username ?? 'Anonymous';
    final avatarUrl = user?.profilePic.url ?? '';
    final hasAvatar = avatarUrl.isNotEmpty;

    final timeAgo =
        '${DateTime.now().difference(widget.comment.createdAt).inHours}h';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                child: !hasAvatar ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$userName  ',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: widget.comment.text,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.80),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6.56),
                    Row(
                      children: [
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.30),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 18),
                        InkWell(
                          onTap: _handleLike,
                          child: Text(
                            '$_likesCount likes',
                            style: TextStyle(
                              color: _isLiked ? Colors.red : Colors.black.withOpacity(0.30),
                              fontSize: 12,
                              fontWeight: _isLiked ? FontWeight.bold : FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        InkWell(
                          onTap: () => setState(() => _isReplying = !_isReplying),
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.30),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (_isReplying) _buildReplyInput(),
        if (widget.comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left:40.0, top: 8.0), // Indent replies
            child: ListView.builder(
              shrinkWrap: true, // Important for nested lists
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the inner list
              itemCount: widget.comment.replies.length,
              itemBuilder: (context, index) {
                // Recursively use CommentWidget for each reply
                return CommentWidget(comment: widget.comment.replies[index]);
              },
            ),
          ),
      ],
    );
  }
}
class SmoothPageIndicator extends StatelessWidget {
  final PageController controller;
  final int count;

  const SmoothPageIndicator({
    super.key,
    required this.controller,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Calculate current page safely
        int currentPage = 0;
        if (controller.hasClients && controller.page != null) {
          currentPage = controller.page!.round();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            bool isSelected = index == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSelected ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.black.withOpacity(
                    0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
