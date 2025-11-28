import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zatch_app/model/categories_response.dart';
import 'package:zatch_app/model/login_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/home_page.dart';

class CategoryScreen extends StatefulWidget {
  final LoginResponse? loginResponse;
  final String? title;

  const CategoryScreen({
    super.key,
    this.loginResponse,
    this.title,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService _apiService = ApiService();
  List<Category> categories = [];
  bool isLoading = true;
  String? errorMessage;
  Set<int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      if (!mounted) return;
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final fetchedCategories = await _apiService.getCategories();
      final displayCategories = fetchedCategories
          .where((cat) => cat.name.toLowerCase() != 'explore all')
          .toList();
      if (!mounted) return;
      setState(() {
        categories = displayCategories;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Failed to load categories. Please check your connection.";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  Future<void> _saveCategoriesAndContinue() async {
    final selectedItems = selectedIndexes.map((i) => categories[i]).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "userCategories",
      selectedItems.map((c) => c.name).toList(),
    );

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          loginResponse: widget.loginResponse,
          selectedCategories: selectedItems,
        ),
      ),
          (Route<dynamic> route) => false, // This predicate removes all previous routes
    );

  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildResponsiveBackground(screenSize),
          SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(context, screenSize),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildContent(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                  child: _buildBottomButtons(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCustomAppBar(BuildContext context, Size screenSize) {
    return Container(
      height: screenSize.height * 0.13,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Positioned(
            left: 27,
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFDFDEDE)),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.arrow_back_ios_new, size: 18),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 60,
            right: 60,
            child: Text(
              widget.title ?? 'Let’s find you\nSomething to shop for.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF494949),
                fontSize: 24,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFA2DC00)));
    }
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCCFF55),
                foregroundColor: Colors.black,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero, // Padding is handled by the parent
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final item = categories[index];
        final isSelected = selectedIndexes.contains(index);
        final imageUrl = item.iconUrl?.isNotEmpty == true
            ? item.iconUrl!
            : (item.image?.url ?? '');

        return InkWell(
          onTap: () => toggleSelection(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0x99EAFFAF) : const Color(0xFFF2F4F5),
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: const Color(0xFFA2DC00), width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF494949),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (imageUrl.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA2DC00))));
                        },
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 55),
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color(0xFF249B3E), width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
            ),
            child: const Text(
              'Back',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: selectedIndexes.isNotEmpty ? _saveCategoriesAndContinue : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 55),
              backgroundColor: const Color(0xFFCCF656),
              disabledBackgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveBackground(Size screenSize) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bottom-left rotated decoration
        Positioned(
          left: screenSize.width * -0.5,
          top: screenSize.height * 0.65,
          child: Transform(
            transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.47),
            child: Container(
              width: screenSize.width,
              height: screenSize.width,
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 2, color: Color(0xFFF1F4FF)),
                ),
              ),
            ),
          ),
        ),
        // Bottom-left decoration
        Positioned(
          left: screenSize.width * -0.8,
          top: screenSize.height * 0.72,
          child: Container(
            width: screenSize.width,
            height: screenSize.width,
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: Color(0xFFF1F4FF)),
              ),
            ),
          ),
        ),
        // Top-left large oval
        Positioned(
          left: screenSize.width * -0.6,
          top: screenSize.height * -0.3,
          child: Container(
            width: screenSize.width * 1.2,
            height: screenSize.width * 1.2,
            decoration: const ShapeDecoration(
              shape: OvalBorder(
                side: BorderSide(width: 3, color: Color(0x99CCF656)),
              ),
            ),
          ),
        ),
        // Top-left smaller oval
        Positioned(
          left: screenSize.width * -0.4,
          top: screenSize.height * -0.2,
          child: Container(
            width: screenSize.width * 0.8,
            height: screenSize.width * 0.8,
            decoration: const ShapeDecoration(
              color: Color(0x4CCCF656),
              shape: OvalBorder(
                side: BorderSide(width: 1, color: Color(0x99CCF656)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
