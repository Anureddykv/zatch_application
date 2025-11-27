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

    // Sort API categories by sortOrder then name
    allCategories.sort((a, b) {
      final orderA = a.sortOrder ?? 9999;
      final orderB = b.sortOrder ?? 9999;
      if (orderA != orderB) return orderA.compareTo(orderB);
      return a.name.compareTo(b.name);
    });

    if (widget.selectedCategories != null && widget.selectedCategories!.isNotEmpty) {
      final selectedNames = widget.selectedCategories!.map((c) => c.name.toLowerCase()).toList();

      final exploreAll = allCategories.firstWhere(
            (c) => c.name.toLowerCase() == "explore all",
        orElse: () => Category(name: "Explore All", id: "", easyname: "", subCategories: []),
      );

      // Remaining categories (excluding selected and Explore All)
      final remaining = allCategories.where((c) {
        final nameLower = c.name.toLowerCase();
        return !selectedNames.contains(nameLower) && nameLower != "explore all";
      }).toList();

      final isExploreSelected = selectedNames.contains("explore all");

      if (widget.selectedCategories!.length == 1) {
        // Single selection
        final singleSelected = widget.selectedCategories!.first;
        if (singleSelected.name.toLowerCase() == "explore all") {
          _orderedCategories = [singleSelected, ...remaining];
        } else {
          _orderedCategories = [singleSelected];
          if (!isExploreSelected) _orderedCategories.add(exploreAll);
          _orderedCategories.addAll(remaining);
        }
        _selectedCategoryName = singleSelected.name;
      } else {
        // Multiple selections
        _orderedCategories = [];

        // Always put Explore All first if selected, else not
        if (isExploreSelected) {
          _orderedCategories.add(exploreAll);
          _selectedCategoryName = exploreAll.name; // mark Explore All selected
        }

        // Add other selected categories (excluding Explore All)
        _orderedCategories.addAll(
          widget.selectedCategories!.where((c) => c.name.toLowerCase() != "explore all"),
        );

        // Add remaining categories
        _orderedCategories.addAll(remaining);
      }
    } else {
      // Direct Home entry → show API sorted categories, no pre-selection
      _orderedCategories = allCategories;
      _selectedCategoryName = null;
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text("Error: $_errorMessage"));
    if (_orderedCategories.isEmpty) return const Center(child: Text("No categories available"));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _orderedCategories.map((category) {
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
                  await prefs.setStringList("userCategories", [category.name]);

                  widget.onCategorySelected?.call(category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
