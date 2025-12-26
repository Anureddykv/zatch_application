import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/category_controller.dart';
import '../model/categories_response.dart';

class CategoryTabsWidget extends StatefulWidget {
  final Function(Category)? onCategorySelected;
  final List<Category>? selectedCategories;

  const CategoryTabsWidget({
    super.key,
    this.onCategorySelected,
    this.selectedCategories,
  });

  @override
  State<CategoryTabsWidget> createState() => _CategoryTabsWidgetState();
}

class _CategoryTabsWidgetState extends State<CategoryTabsWidget> {
  final CategoryController _controller = CategoryController();
  List<Category> _orderedCategories = [];
  String? _selectedCategoryName;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      await _controller.fetchCategories();
      _orderCategories();
      if (_orderedCategories.isNotEmpty && _selectedCategoryName == null) {
        _selectedCategoryName = _orderedCategories.first.name;
        final initialCategory = _orderedCategories.first;
        widget.onCategorySelected?.call(initialCategory);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _orderCategories() {
    final allCategories = _controller.categories ?? [];
    if (allCategories.isEmpty) return;

    // 1. Sort all fetched categories by their sortOrder, then by name for consistency.
    allCategories.sort((a, b) {
      final orderA = a.sortOrder ?? 9999;
      final orderB = b.sortOrder ?? 9999;
      if (orderA != orderB) return orderA.compareTo(orderB);
      return a.name.compareTo(b.name);
    });

    // Extract the "Explore All" category for special handling.
    final exploreAllCategory = allCategories.firstWhere(
      (c) => c.name.toLowerCase() == "explore all",
      orElse:
          () => Category(
            name: "Explore All",
            id: "explore",
            easyname: "explore",
            subCategories: [],
          ),
    );

    // If no categories were passed from the login flow, just show the default sorted list.
    if (widget.selectedCategories == null ||
        widget.selectedCategories!.isEmpty) {
      _orderedCategories = allCategories;
      // Default to selecting the first item in the list, which should be 'Explore All' after sorting.
      _selectedCategoryName =
          _orderedCategories.isNotEmpty ? _orderedCategories.first.name : null;
      if (_orderedCategories.isNotEmpty) {
        widget.onCategorySelected?.call(_orderedCategories.first);
      }
      return;
    }

    // --- Logic for when categories ARE passed from the CategoryScreen ---

    final userSelectedCategories = widget.selectedCategories!;
    final userSelectedNames =
        userSelectedCategories.map((c) => c.name.toLowerCase()).toSet();

    // Get all categories that were NOT selected by the user, excluding 'Explore All'.
    final remainingCategories =
        allCategories.where((c) {
          final nameLower = c.name.toLowerCase();
          return !userSelectedNames.contains(nameLower) &&
              nameLower != "explore all";
        }).toList();

    // Reset the ordered list.
    _orderedCategories = [];

    if (userSelectedCategories.length == 1) {
      // --- SCENARIO 1: USER SELECTED A SINGLE CATEGORY ---
      final singleSelected = userSelectedCategories.first;

      // The single selected category is always first.
      _orderedCategories.add(singleSelected);
      _selectedCategoryName = singleSelected.name; // Highlight this category.

      // Add 'Explore All' right after it.
      _orderedCategories.add(exploreAllCategory);

      // Add all other remaining categories.
      _orderedCategories.addAll(remainingCategories);
    } else {
      // --- SCENARIO 2: USER SELECTED MULTIPLE CATEGORIES ---

      // Add all user-selected categories to the front of the list.
      _orderedCategories.add(exploreAllCategory);
      // Highlight the first category from the user's selection.
      _selectedCategoryName = exploreAllCategory.name; // Highlight "Explore All".
      // Add 'Explore All' after the user's selections.
      _orderedCategories.addAll(
        userSelectedCategories.where(
                (c) => c.name.toLowerCase() != "explore all"),
      );
      // Add all other remaining categories.
      _orderedCategories.addAll(remainingCategories);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null)
      return Center(child: Text("Error: $_errorMessage"));
    if (_orderedCategories.isEmpty)
      return const Center(child: Text("No categories available"));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _orderedCategories.map((category) {
                final isSelected = category.name == _selectedCategoryName;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        _selectedCategoryName = category.name;
                      });

                      // Save new selection
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setStringList("userCategories", [
                        category.name,
                      ]);

                      widget.onCategorySelected?.call(category);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
