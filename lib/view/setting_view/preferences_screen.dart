import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zatch_app/model/categories_response.dart';
import 'package:zatch_app/services/api_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Category> _categories = [];
  final Set<String> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedCategories = await _apiService.getCategories();
      final displayCategories = fetchedCategories
          .where((cat) => cat.name.toLowerCase() != 'explore all')
          .toList();

      if (mounted) {
        setState(() {
          _categories = displayCategories;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load preferences: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSelection(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _onUpdatePressed() {
    if (_selectedCategoryIds.isNotEmpty) {
      print("Selected Category IDs to be saved: $_selectedCategoryIds");
      Navigator.of(context).pop(_selectedCategoryIds.toList());
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery to get screen size for responsive calculations
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Responsive background decorations
          _buildBackgroundDecorations(screenWidth, screenHeight),

          // 2. Main content area (Header, Grid)
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildCustomHeader(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),

          // 3. Responsive custom back button
          _buildCustomBackButton(context),

          // 4. Responsive update button positioned at the bottom
          _buildUpdateButton(),
        ],
      ),
    );
  }

  // Uses screen dimensions to position and size decorations proportionally
  Widget _buildBackgroundDecorations(double screenWidth, double screenHeight) {
    // Base dimensions from Figma to calculate ratios
    const figmaWidth = 390.0;

    // Calculate size and position based on screen width
    final circleDiameter = 372 / figmaWidth * screenWidth;
    final leftOffset1 = -195 / figmaWidth * screenWidth;
    final topOffset1 = 535 / 860 * screenHeight;
    final leftOffset2 = -306 / figmaWidth * screenWidth;
    final topOffset2 = 594 / 860 * screenHeight;

    return Stack(
      children: [
        Positioned(
          left: leftOffset1,
          top: topOffset1,
          child: Container(
            width: circleDiameter,
            height: circleDiameter,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: const Color(0xFFF1F4FF)),
                borderRadius: BorderRadius.circular(circleDiameter / 2),
              ),
            ),
          ),
        ),
        Positioned(
          left: leftOffset2,
          top: topOffset2,
          child: Container(
            width: circleDiameter,
            height: circleDiameter,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: const Color(0xFFF1F4FF)),
                borderRadius: BorderRadius.circular(circleDiameter / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Uses safe area padding for robust positioning
  Widget _buildCustomBackButton(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      left: 27,
      top: topPadding + 10, // 10px below the status bar
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFFDFDEDE)),
                borderRadius: BorderRadius.circular(32),
              ),
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ]
          ),
          child: const Center(
            child: Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 18),
          ),
        ),
      ),
    );
  }

  // Header uses responsive padding
  Widget _buildCustomHeader() {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: topPadding + 35, bottom: 20),
      child: const Text(
        'Your Preferences',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF494949),
          fontSize: 24,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFA3DD00)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _fetchCategories, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(child: Text('No preferences available.'));
    }

    // GridView is already responsive, but padding is adjusted
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120), // Increased bottom padding for the button
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1, // Keep items square
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategoryIds.contains(category.id);
        return PreferenceGridItem(
          category: category,
          isSelected: isSelected,
          onTap: () => _toggleSelection(category.id),
        );
      },
    );
  }

  // Button uses Align and horizontal padding for responsiveness
  Widget _buildUpdateButton() {
    bool isEnabled = _selectedCategoryIds.isNotEmpty;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        child: ElevatedButton(
          onPressed: _onUpdatePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? const Color(0xFFCCF656) : const Color(0xFFBDBDBD),
            disabledBackgroundColor: const Color(0xFFBDBDBD),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
            padding: const EdgeInsets.symmetric(vertical: 15),
            minimumSize: const Size(double.infinity, 50),
            elevation: 2,
          ),
          child: const Text(
            'Update',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class PreferenceGridItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const PreferenceGridItem({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x99EAFFAF) : const Color(0xFFF2F4F5),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(width: 2, color: const Color(0xFFA2DC00)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF494949),
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: CachedNetworkImage(
                  imageUrl: category.image?.url ?? '',
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey[300])),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
