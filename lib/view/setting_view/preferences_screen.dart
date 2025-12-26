import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zatch/model/categories_response.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/home_page.dart';
import 'package:zatch/utils/snackbar_utils.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  List<Category> _categories = [];

  final Set<String> _selectedCategoryIds = {};
  final Set<String> _initialSelectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getCategories(),
        _apiService.getUserPreferences(),
      ]);

      final allCategories = results[0] as List<Category>;
      final userPrefs = results[1] as Map<String, dynamic>;

      final displayCategories = allCategories
          .where((cat) => cat.name.toLowerCase() != 'explore all')
          .toList();

      final List<dynamic> savedSlugs = userPrefs['categories'] ?? [];
      final Set<String> savedSlugSet = savedSlugs.map((e) => e.toString()).toSet();

      final Set<String> preSelectedIds = {};
      for (var cat in displayCategories) {
        if (cat.slug != null && savedSlugSet.contains(cat.slug)) {
          preSelectedIds.add(cat.id);
        }
      }

      if (mounted) {
        setState(() {
          _categories = displayCategories;
          _selectedCategoryIds.addAll(preSelectedIds);
          _initialSelectedCategoryIds.addAll(preSelectedIds);
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

  bool _hasChanges() {
    if (_selectedCategoryIds.length != _initialSelectedCategoryIds.length) {
      return true;
    }
    return !_selectedCategoryIds.containsAll(_initialSelectedCategoryIds);
  }

  void _onBackTap() {
    if (homePageKey.currentState != null) {
      homePageKey.currentState!.closeSubScreen();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _onUpdatePressed() async {
    if (_selectedCategoryIds.isEmpty) {
      SnackBarUtils.showTopSnackBar(context, "Please select at least one category", isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final selectedSlugs = _categories
          .where((c) => _selectedCategoryIds.contains(c.id))
          .map((c) => c.slug ?? c.name)
          .toList();

      await _apiService.saveUserPreferences(selectedSlugs);

      if (!mounted) return;

      final selectedCategoryObjects = _categories
          .where((c) => _selectedCategoryIds.contains(c.id))
          .toList();

      if (homePageKey.currentState != null) {
        homePageKey.currentState!.updateSelectedCategories(selectedCategoryObjects);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(selectedCategories: selectedCategoryObjects),
          ),
          (route) => false,
        );
      }

    } catch (e) {
      if (mounted) {
        SnackBarUtils.showTopSnackBar(context, "Failed to update: $e", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackgroundDecorations(screenWidth, screenHeight),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildCustomHeader(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
          _buildCustomBackButton(context),
          _buildUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations(double screenWidth, double screenHeight) {
    const figmaWidth = 390.0;
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
                side: const BorderSide(width: 2, color: Color(0xFFF1F4FF)),
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
                side: const BorderSide(width: 2, color: Color(0xFFF1F4FF)),
                borderRadius: BorderRadius.circular(circleDiameter / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomBackButton(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      left: 27,
      top: topPadding + 10,
      child: GestureDetector(
        onTap: _onBackTap,
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
              ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(child: Text('No preferences available.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
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

  Widget _buildUpdateButton() {
    bool isEnabled = _selectedCategoryIds.isNotEmpty && _hasChanges();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        child: ElevatedButton(
          onPressed: (_isSaving || !isEnabled) ? null : _onUpdatePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? const Color(0xFFCCF656) : const Color(0xFFBDBDBD),
            disabledBackgroundColor: const Color(0xFFBDBDBD),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
            padding: const EdgeInsets.symmetric(vertical: 15),
            minimumSize: const Size(double.infinity, 50),
            elevation: 2,
          ),
          child: _isSaving
              ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
          )
              : const Text(
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
