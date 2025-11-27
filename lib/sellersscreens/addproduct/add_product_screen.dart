/*
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zatch_app/model/categories_response.dart';
import 'package:zatch_app/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controller to manage which page (step) is visible
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // API Service instance
  final ApiService _apiService = ApiService();

  // --- FORM KEYS FOR VALIDATION ---
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  // --- STATE FOR API-DRIVEN DATA ---
  List<Category> _allCategories = [];
  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;

  // --- STATE MANAGEMENT FOR FORM DATA (STEP 1) ---
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  String _orderAcceptingType = "autoAccept";
  bool _isBargainEnabled = true;
  double _autoAcceptDiscount = 5.0;
  double _maxDiscount = 15.0;

  // --- STATE MANAGEMENT FOR FORM DATA (STEP 2, 3, etc.) ---
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _inventoryController = TextEditingController();
  String? _productId;

  @override
  void initState() {
    super.initState();
    // Listen to changes in the sale price to update the bargain card
    _salePriceController.addListener(_updateBargainCard);
    _fetchCategories(); // Fetch data when the screen loads
  }

  @override
  void dispose() {
    // Dispose all controllers
    _pageController.dispose();
    _productNameController.dispose();
    _descriptionController.dispose();
    _salePriceController.removeListener(_updateBargainCard); // Remove listener
    _salePriceController.dispose();
    _discountedPriceController.dispose();
    _stockQuantityController.dispose();
    _colorController.dispose();
    _inventoryController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  // A simple method to trigger a rebuild when the price changes
  void _updateBargainCard() {
    setState(() {});
  }

  /// Fetch categories from the API and update the state.
  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _allCategories = categories;
        });
      }
    } catch (e) {
      _showMessage("Failed to load categories: ${e.toString()}", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Shows a snackbar with a message.
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 16,
            right: 16),
      ),
    );
  }

  /// Central logic to validate, build payload, and call the API.
  Future<void> _handleNext() async {
    if (_isLoading) return; // Prevent multiple submissions

    bool isFormValid = false;
    switch (_currentStep) {
      case 0:
        isFormValid = _step1FormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isFormValid = _step2FormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isFormValid = _step3FormKey.currentState?.validate() ?? false;
        break;
      case 3:
        isFormValid = _step4FormKey.currentState?.validate() ?? false;
        break;
    }

    if (!isFormValid) {
      _showMessage("Please fill all required fields.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> payload = {};

      // Build the payload based on the current step
      switch (_currentStep) {
        case 0:
          payload = {
            "step": "1",
            "category": _selectedCategory?.slug ?? _selectedCategory?.name ?? '',
            "subCategory": (_selectedSubCategory?.id.startsWith('dummy-id') ?? false)
                ? '' // Send empty string for dummy sub-category
                : _selectedSubCategory?.slug ?? _selectedSubCategory?.name ?? '',
            "name": _productNameController.text,
            "description": _descriptionController.text,
            "price": int.tryParse(_salePriceController.text) ?? 0,
            "discountedPrice": int.tryParse(_discountedPriceController.text) ?? 0,
            "totalStock": int.tryParse(_stockQuantityController.text) ?? 0,
            "orderAcceptingType": _orderAcceptingType,
            "globalBargainSettings": {"enabled": _isBargainEnabled},
            "bargainSettings": {
              "autoAcceptDiscount": _autoAcceptDiscount,
              "maximumDiscount": _maxDiscount
            }
          };
          break;
        case 1:
          payload = {"step": "2", "productId": _productId, "color": _colorController.text};
          break;
        case 2:
          payload = {"step": "3", "productId": _productId, "size": _sizeController.text};
          break;
        case 3:
        // This is the final submission.
          _showSuccessDialog();
          setState(() => _isLoading = false);
          return;
      }

      // Call the API
      final response = await _apiService.submitProductStep(payload);

      // Store product ID from step 1 response
      if (_currentStep == 0 && response.containsKey('productId')) {
        _productId = response['productId'];
      }

      _showMessage(response['message'] ?? "Step completed successfully!");

      // If API call is successful, move to the next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Added'),
        content: const Text('Your new product has been successfully added.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Go back from AddProductScreen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Function to move to the previous page
  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(92.0),
        child: Container(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 40.0, bottom: 16),
          decoration: const ShapeDecoration(
            color: Color(0xFFCCF656),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (_currentStep == 0) {
                    Navigator.of(context).pop();
                  } else {
                    _previousPage();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFDFDEDE)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.black, size: 20),
                ),
              ),
              const Text(
                'Add Products',
                style: TextStyle(
                  color: Color(0xFF121111),
                  fontSize: 16,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 44), // Spacer for centering title
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 24.0),
                child: _FigmaProductStepper(currentStep: _currentStep),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() {
                      _currentStep = page;
                    });
                  },
                  children: [
                    _ProductDetailsStep(
                      formKey: _step1FormKey,
                      onContinue: _handleNext,
                      nameController: _productNameController,
                      descriptionController: _descriptionController,
                      salePriceController: _salePriceController,
                      discountedPriceController: _discountedPriceController,
                      stockQuantityController: _stockQuantityController,
                      onBargainChanged: (enabled, autoAccept, max) {
                        setState(() {
                          _isBargainEnabled = enabled;
                          _autoAcceptDiscount = autoAccept;
                          _maxDiscount = max;
                        });
                      },
                      onOrderTypeChanged: (type) {
                        setState(() => _orderAcceptingType = type);
                      },
                      orderAcceptingType: _orderAcceptingType,
                      allCategories: _allCategories,
                      selectedCategory: _selectedCategory,
                      selectedSubCategory: _selectedSubCategory,
                      onCategoryChanged: (category) {
                        setState(() {
                          _selectedCategory = category;
                          _selectedSubCategory = null; // Reset sub-category
                        });
                      },
                      onSubCategoryChanged: (subCategory) {
                        setState(() {
                          _selectedSubCategory = subCategory;
                        });
                      },
                    ),
                    _ColorVariantStep(
                      formKey: _step2FormKey,
                      onContinue: _handleNext,
                      onBack: _previousPage,
                      colorController: _colorController,
                    ),
                    _SizeVariantStep(
                      formKey: _step3FormKey,
                      onContinue: _handleStep3Next,
                      onBack: _previousPage,
                      colorController: _colorController,
                      sizeController: _sizeController,
                    ),
                    _InventoryStep(
                      formKey: _step4FormKey,
                      onAddProduct: _handleNext,
                      onBack: _previousPage,
                      // Pass the required controllers
                      colorController: _colorController,
                      sizeController: _sizeController,
                      inventoryController: _inventoryController,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
            ),
        ],
      ),
    );
  }


  Future<void> _handleStep3Next(Map<String, Map<String, dynamic>> variantData) async {
    print("Received Variant Data in Parent Screen: $variantData");

    setState(() => _isLoading = true);
    try {
      final formData = FormData.fromMap({'productId': _productId});

      for (var entry in variantData.entries) {
        final color = entry.key;
        final data = entry.value;
        final List<String> sizes = data['sizes'];
        final List<XFile> images = data['images'];
formData.fields.add(MapEntry('variants[$color][sizes]', sizes.join(',')));

        for (int i = 0; i < images.length; i++) {
          final imageFile = images[i];
          formData.files.add(MapEntry(
            'variants[$color][images][$i]',
            await MultipartFile.fromFile(imageFile.path, filename: imageFile.name),
          ));
        }
      }
     print("SUBMITTING FORM DATA (SIMULATED): ${formData.fields} and ${formData.files.length} files");
      await Future.delayed(const Duration(seconds: 1));
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );

    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

}

// ===================================================================
// ==== NEW STEPPER WIDGET (FROM FIGMA DESIGN) =======================
// ===================================================================
class _FigmaProductStepper extends StatelessWidget {
  final int currentStep;
  const _FigmaProductStepper({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final List<String> steps = [
      'Product\nDetails',
      'Colors',
      'Sizes',
      'Inventory'
    ];

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final bool isActive = currentStep >= index;
            final bool isCompleted = currentStep > index;

            // The line connecting the circles
            final Widget line = Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? const Color(0xFFA2DC00)
                    : const Color(0xFFDDDDDD),
              ),
            );

            // The circle itself
            final Widget circle = Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFA2DC00)
                    : const Color(0xFFDDDDDD),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFA2DC00)
                        : const Color(0xFFD9D9D9),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            );

            // If it's not the first circle, add a line before it
            if (index > 0) {
              return Expanded(
                child: Row(
                  children: [line, circle],
                ),
              );
            }
            return circle; // First circle has no preceding line
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(steps.length, (index) {
            return Expanded(
              child: Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF2C2C2C),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: currentStep == index
                      ? FontWeight.w600
                      : FontWeight.w400,
                  height: 1.36,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ===================================================================
// ==== STEP 1: PRODUCT DETAILS (UI REBUILT) =========================
// ===================================================================

class _ProductDetailsStep extends StatelessWidget {
  final VoidCallback onContinue;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController salePriceController;
  final TextEditingController discountedPriceController;
  final TextEditingController stockQuantityController;
  final Function(bool, double, double) onBargainChanged;
  final ValueChanged<String> onOrderTypeChanged;
  final String orderAcceptingType;
  final List<Category> allCategories;
  final Category? selectedCategory;
  final SubCategory? selectedSubCategory;
  final ValueChanged<Category?> onCategoryChanged;
  final ValueChanged<SubCategory?> onSubCategoryChanged;

  const _ProductDetailsStep({
    super.key,
    required this.onContinue,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.salePriceController,
    required this.discountedPriceController,
    required this.stockQuantityController,
    required this.onBargainChanged,
    required this.onOrderTypeChanged,
    required this.orderAcceptingType,
    required this.allCategories,
    required this.selectedCategory,
    required this.selectedSubCategory,
    required this.onCategoryChanged,
    required this.onSubCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final subCategories = selectedCategory?.subCategories ?? [];
    final bool hasRealSubCategories = subCategories.isNotEmpty &&
        !(subCategories.length == 1 &&
            subCategories.first.id.startsWith('dummy-id'));

    final double salePrice = double.tryParse(salePriceController.text) ?? 0.0;

    return _FormStepContainer(
      onContinue: onContinue,
      showBottomButtons: false, // HIDE the default buttons for Step 1
      child: Form(
        key: formKey,
        child: Column(
          children: [
            // --- PRODUCT DETAILS CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 17.50, vertical: 24),
              decoration: ShapeDecoration(
                color: const Color(0xFFF8FAFB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                shadows: [
                  const BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
                  const BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius: 0),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 20, color: Color(0xFF101727)),
                      const SizedBox(width: 7),
                      const Text('Product Details', style: TextStyle(color: Color(0xFF101727), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown<Category>(
                    label: 'Category *',
                    hint: 'Select Category',
                    value: selectedCategory,
                    items: allCategories,
                    onChanged: onCategoryChanged,
                    itemToString: (Category cat) => cat.name,
                    validator: (v) => v == null ? "Category is required" : null,
                  ),
                  const SizedBox(height: 16),
                  if (hasRealSubCategories)
                    _buildDropdown<SubCategory>(
                      label: 'Sub Category *',
                      hint: 'Select Sub Category',
                      value: selectedSubCategory,
                      items: subCategories,
                      onChanged: onSubCategoryChanged,
                      itemToString: (SubCategory sub) => sub.name,
                      validator: (v) => v == null ? "Sub Category is required" : null,
                    ),
                  if (hasRealSubCategories) const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Product Name *',
                    hint: 'Enter product name',
                    controller: nameController,
                    validator: (v) => (v == null || v.isEmpty) ? "Product Name is required" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Description *',
                    hint: 'Describe your product...',
                    controller: descriptionController,
                    maxLines: 4,
                    validator: (v) => (v == null || v.isEmpty) ? "Description is required" : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Sale price *',
                          hint: '0',
                          controller: salePriceController,
                          hasCurrencySymbol: true,
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 10.50),
                      Expanded(
                        child: _buildTextField(
                          label: 'Discounted price',
                          hint: '0',
                          controller: discountedPriceController,
                          hasCurrencySymbol: true,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Stock Quantity *',
                    hint: 'Enter Stock Quantity',
                    controller: stockQuantityController,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? "Stock is required" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildOrderAcceptingType(),
                ],
              ),
            ),
            const SizedBox(height: 21),

            // --- BARGAIN SETTINGS CARD ---
            _FigmaBargainSettingsCard(
              salePrice: salePrice,
              onChanged: onBargainChanged,
            ),

            // --- SCROLLABLE ACTION BUTTONS ---
            const SizedBox(height: 28),
            _buildActionButtons(context),
            const SizedBox(height: 28), // Add some padding at the very bottom
          ],
        ),
      ),
    );
  }

  // --- NEW WIDGET FOR THE SCROLLABLE ACTION BUTTONS ---
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
          onPressed: () {
            // Closes the AddProductScreen entirely
            Navigator.of(context).pop();
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(width: 1, color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Cancel',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 10.50),
        ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA2DC00),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Generic Text Field styled to match Figma
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool hasCurrencySymbol = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF354152),
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF717182),
              fontSize: 12.30,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: hasCurrencySymbol
                ? const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 14.0, 4.0, 14.0),
              child: Text('₹',
                  style:
                  TextStyle(color: Color(0xFF717182), fontSize: 16)),
            )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: EdgeInsets.fromLTRB(
                hasCurrencySymbol ? 0 : 16, 14, 16, 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines > 1 ? 16 : 46.75),
              borderSide: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines > 1 ? 16 : 46.75),
              borderSide: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines > 1 ? 16 : 46.75),
              borderSide:
              const BorderSide(width: 1, color: Color(0xFFA2DC00)),
            ),
          ),
        ),
      ],
    );
  }

  // Generic Dropdown styled to match Figma
  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemToString,
    required FormFieldValidator<T>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF354152),
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 7),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemToString(item), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0x80344054)), // Opacity 50% on color #344054
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF717182),
              fontSize: 12.30,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(46.75),
              borderSide: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(46.75),
              borderSide: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(46.75),
              borderSide:
              const BorderSide(width: 1, color: Color(0xFFA2DC00)),
            ),
          ),
        ),
      ],
    );
  }

  // Order accepting type radio buttons
  Widget _buildOrderAcceptingType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Accepting Type *',
          style: TextStyle(
            color: Color(0xFF354152),
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: _RadioListTile(
                title: 'Auto Accept',
                value: 'autoAccept',
                groupValue: orderAcceptingType,
                onChanged: (val) {
                  if (val != null) {
                    onOrderTypeChanged(val);
                  }
                },
              ),
            ),
            Expanded(
              child: _RadioListTile(
                title: 'Ask before accepting',
                value: 'manual',
                groupValue: orderAcceptingType,
                onChanged: (val) {
                  if (val != null) {
                    onOrderTypeChanged(val);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ===================================================================
// ==== HELPER WIDGETS (UNCHANGED) ===================================
// ===================================================================

class _RadioListTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioListTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: const Color(0xFFA2DC00),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaBargainSettingsCard extends StatefulWidget {
  final double salePrice;
  final Function(bool, double, double) onChanged;

  const _FigmaBargainSettingsCard({
    required this.salePrice,
    required this.onChanged,
  });

  @override
  __FigmaBargainSettingsCardState createState() =>
      __FigmaBargainSettingsCardState();
}

class __FigmaBargainSettingsCardState extends State<_FigmaBargainSettingsCard> {
  bool _isBargainEnabled = true;
  double _autoAcceptDiscount = 5.0;
  double _maxDiscount = 30.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_isBargainEnabled, _autoAcceptDiscount, _maxDiscount);
    });
  }

  void _handleSwitchChanged(bool value) {
    setState(() => _isBargainEnabled = value);
    widget.onChanged(value, _autoAcceptDiscount, _maxDiscount);
  }

  void _handleAutoAcceptChanged(double value) {
    setState(() => _autoAcceptDiscount = value);
    widget.onChanged(_isBargainEnabled, value, _maxDiscount);
  }

  void _handleMaxDiscountChanged(double value) {
    setState(() => _maxDiscount = value);
    widget.onChanged(_isBargainEnabled, _autoAcceptDiscount, value);
  }

  @override
  Widget build(BuildContext context) {
    final double priceFloor = widget.salePrice * (1 - _maxDiscount / 100);
    final double autoAcceptValue = widget.salePrice * (1 - _autoAcceptDiscount / 100);

    return Container(
      padding: const EdgeInsets.all(17.50),
      decoration: ShapeDecoration(
        color: const Color(0xFFF8FAFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: [
          const BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
          const BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius: 0),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.sell_outlined, size: 20, color: Color(0xFF101727)),
                  SizedBox(width: 7),
                  Text('Bargain Settings', style: TextStyle(color: Color(0xFF101727), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
                ],
              ),
              Switch(
                value: _isBargainEnabled,
                onChanged: _handleSwitchChanged,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF030213),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),
          if (_isBargainEnabled) ...[
            const SizedBox(height: 21),
            _buildSlider(
              label: 'Auto-Accept Discount',
              value: _autoAcceptDiscount,
              onChanged: _handleAutoAcceptChanged,
              displayColor: const Color(0xFF016630),
              backgroundColor: const Color(0xFFECECF0),
              displayValue: '${_autoAcceptDiscount.toInt()}% (₹${autoAcceptValue.toStringAsFixed(0)})',
              description: 'Orders at this discount or lower will be auto-accepted',
            ),
            const SizedBox(height: 21),
            _buildSlider(
              label: 'Maximum Discount',
              value: _maxDiscount,
              onChanged: _handleMaxDiscountChanged,
              displayColor: const Color(0xFF9F2D00),
              backgroundColor: const Color(0xFFFFECD4),
              displayValue: '${_maxDiscount.toInt()}%',
            ),
            const SizedBox(height: 21),
            _buildPriceFloorInfo(priceFloor),
          ]
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required Color displayColor,
    required Color backgroundColor,
    required String displayValue,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF354152), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.75),
              decoration: ShapeDecoration(
                color: backgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.75)),
              ),
              child: Text(
                displayValue,
                textAlign: TextAlign.center,
                style: TextStyle(color: displayColor, fontSize: 10.50, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 14.0,
            trackShape: const RoundedRectSliderTrackShape(),
            activeTrackColor: const Color(0xFF030213),
            inactiveTrackColor: const Color(0xFFECECF0),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0, elevation: 2.0),
            thumbColor: Colors.white,
            overlayColor: Colors.transparent,
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            onChanged: onChanged,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Color(0xFF697282), fontSize: 10.50, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400),
          ),
        ]
      ],
    );
  }

  Widget _buildPriceFloorInfo(double priceFloor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.50, vertical: 10.50),
      decoration: ShapeDecoration(
        color: const Color(0xFFECECF0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Price Floor:', style: TextStyle(color: Color(0xFF354152), fontSize: 12.30, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400)),
              Text('₹${priceFloor.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF101727), fontSize: 12, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 3.5),
          const Text('Buyer will bargain till this price at the most', style: TextStyle(color: Color(0xFF697282), fontSize: 10.50, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

// ======================================================================================
// ==== MODIFIED _FormStepContainer =====================================================
// ======================================================================================

class _FormStepContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback onContinue;
  final VoidCallback? onBack;
  final String continueText;
  final bool showBottomButtons;

  const _FormStepContainer({
    super.key,
    required this.child,
    required this.onContinue,
    this.onBack,
    this.continueText = 'Continue',
    this.showBottomButtons = true, // Default to true for other steps
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: child,
          ),
        ),
        if (showBottomButtons)
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA2DC00),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    continueText,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (onBack != null) ...[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ]
              ],
            ),
          )
      ],
    );
  }
}

// ===================================================================
// ==== OTHER STEP WIDGETS (UNCHANGED) ===============================
// ===================================================================

// ===================================================================
// ==== HELPER WIDGET FOR THE COLOR SELECTION DIALOG =================
// ===================================================================

class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelectedItems;

  const MultiSelectDialog({
    super.key,
    required this.items,
    required this.initialSelectedItems,
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  // A temporary list to hold selections within the dialog
  final List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    // Copy the initial selections into the local state of the dialog
    _selectedItems.addAll(widget.initialSelectedItems);
  }

  // Called when a checkbox is tapped.
  void _itemChange(String item, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(item);
      } else {
        _selectedItems.remove(item);
      }
    });
  }

  // Closes the dialog without saving changes.
  void _cancel() {
    Navigator.pop(context);
  }

  // Closes the dialog and returns the selected items to the previous screen.
  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Colours'),
      content: SingleChildScrollView(
        child: ListBody(
          // Create a CheckboxListTile for each available color.
          children: widget.items.map((item) {
            return CheckboxListTile(
              value: _selectedItems.contains(item),
              title: Text(item),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (isChecked) {
                if (isChecked != null) {
                  _itemChange(item, isChecked);
                }
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

// ===================================================================
// ==== STEP 2: COLOR VARIANT (REBUILT FROM FIGMA) ===================
// ===================================================================

class _ColorVariantStep extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final GlobalKey<FormState> formKey;
  final TextEditingController colorController;

  const _ColorVariantStep(
      {super.key,
        required this.onContinue,
        required this.onBack,
        required this.formKey,
        required this.colorController});

  @override
  _ColorVariantStepState createState() => _ColorVariantStepState();
}

class _ColorVariantStepState extends State<_ColorVariantStep> {
  // List of available colors to choose from.
  final List<String> _availableColors = [
    'Black', 'White', 'Red', 'Green', 'Blue', 'Yellow', 'Pink', 'Purple',
    'Orange', 'Brown', 'Grey', 'Silver', 'Gold'
  ];

  // This list will hold the colors the user has selected.
  final List<String> _selectedColors = [];

  // This function is called before moving to the next step.
  void _onContinuePressed() {
    // Convert the list of selected colors into a single comma-separated string.
    widget.colorController.text = _selectedColors.join(', ');

    // Trigger the validation and then proceed.
    if (widget.formKey.currentState!.validate()) {
      widget.onContinue();
    }
  }

  // --- THIS IS THE CORE OF THE NEW LOGIC: SHOW A MULTI-SELECT DIALOG ---
  Future<void> _showMultiSelect() async {
    final List<String>? results = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: _availableColors,
          initialSelectedItems: _selectedColors,
        );
      },
    );

    // Update the state if the user confirmed their selection.
    if (results != null) {
      setState(() {
        _selectedColors.clear();
        _selectedColors.addAll(results);
      });
      // This is important to re-run validation when colors are selected/deselected.
      widget.formKey.currentState?.validate();
    }
  }


  @override
  Widget build(BuildContext context) {
    // We override the onContinue to process our data first.
    return _FormStepContainer(
      onContinue: _onContinuePressed,
      onBack: widget.onBack,
      child: Form(
        key: widget.formKey,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Colours*',
                  style: TextStyle(
                    color: Color(0xFF354152),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 7),

                // --- FAKE DROPDOWN BUTTON ---
                // This looks like a form field but opens our dialog on tap.
                GestureDetector(
                  onTap: _showMultiSelect,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF9FAFB),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(46.75),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedColors.isEmpty
                                ? 'Select Colours'
                                : _selectedColors.join(', '),
                            style: TextStyle(
                              color: _selectedColors.isEmpty
                                  ? const Color(0xFF717182)
                                  : Colors.black,
                              fontSize: _selectedColors.isEmpty ? 12.30 : 14,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const Opacity(
                          opacity: 0.5,
                          child: Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- HIDDEN VALIDATOR FIELD ---
                // This TextFormField is not visible but is used to show the validation error message.
                TextFormField(
                  controller: widget.colorController,
                  validator: (value) {
                    if (_selectedColors.isEmpty) {
                      return 'Please select at least one color.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isCollapsed: true,
                  ),
                  style: const TextStyle(fontSize: 0, height: 0), // Make the field invisible
                ),
              ],
            ),
          ),

      ),
    );
  }
}

class _SizeVariantStep extends StatefulWidget {
  // 1. MODIFIED: onContinue now accepts the data map.
  final Function(Map<String, Map<String, dynamic>> variantData) onContinue;
  final VoidCallback onBack;
  final GlobalKey<FormState> formKey;
  final TextEditingController colorController;
  final TextEditingController sizeController;

  const _SizeVariantStep({
    super.key,
    required this.onContinue,
    required this.onBack,
    required this.formKey,
    required this.colorController,
    required this.sizeController,
  });

  @override
  _SizeVariantStepState createState() => _SizeVariantStepState();
}

class _SizeVariantStepState extends State<_SizeVariantStep> {
  final ImagePicker _picker = ImagePicker();

  final List<String> _allPossibleColors = [
    'Black', 'White', 'Red', 'Green', 'Blue', 'Yellow', 'Pink', 'Purple',
    'Orange', 'Brown', 'Grey', 'Silver', 'Gold'
  ];
  final List<String> _allPossibleSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  List<String> _activeColorVariants = [];
  final Map<String, Map<String, dynamic>> _variantData = {};

  @override
  void initState() {
    super.initState();
    final colors = widget.colorController.text.split(',').map((e) => e.trim()).toList();
    _activeColorVariants = colors.where((c) => c.isNotEmpty).toList();

    for (var color in _activeColorVariants) {
      _initializeVariantData(color);
    }
  }

  void _initializeVariantData(String color) {
    if (!_variantData.containsKey(color)) {
      _variantData[color] = {
        'sizes': <String>[],
        'images': <XFile>[],
      };
    }
  }

  Future<void> _pickImages(String color) async {
    // Let user pick up to 6 images in one go
    final List<XFile> newImages = await _picker.pickMultiImage();
    if (newImages.isNotEmpty) {
      setState(() {
        final currentImages = _variantData[color]!['images'] as List<XFile>;
        currentImages.addAll(newImages);
        // Enforce the limit of 6 images
        _variantData[color]!['images'] = currentImages.take(6).toList();
        // Re-validate the form to clear any "image required" errors
        widget.formKey.currentState?.validate();
      });
    }
  }

  Future<void> _showSizeMultiSelect(String color) async {
    final List<String>? results = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: _allPossibleSizes,
          initialSelectedItems: List<String>.from(_variantData[color]!['sizes']),
        );
      },
    );

    if (results != null) {
      setState(() {
        _variantData[color]!['sizes'] = results;
      });
      widget.formKey.currentState?.validate();
    }
  }

  Future<void> _addAnotherVariant() async {
    final remainingColors = _allPossibleColors.where((c) => !_activeColorVariants.contains(c)).toList();
    if (remainingColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All available colors have been added.')),
      );
      return;
    }

    final List<String>? results = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: remainingColors,
          initialSelectedItems: const [],
        );
      },
    );

    if (results != null && results.isNotEmpty) {
      setState(() {
        for (var newColor in results) {
          if (!_activeColorVariants.contains(newColor)) {
            _activeColorVariants.add(newColor);
            _initializeVariantData(newColor);
          }
        }
      });
    }
  }

  // 2. MODIFIED: This now passes the full data map to the parent widget.
  void _onContinuePressed() {
    if (widget.formKey.currentState!.validate()) {
      // Validation passed (sizes and images are provided for all variants).
      print("Final Variant Data being passed to parent:");
      print(_variantData);

      // Call the onContinue callback WITH the complete data map.
      // The parent widget is now responsible for handling the file uploads.
      widget.onContinue(_variantData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields for each variant.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FormStepContainer(
      onContinue: _onContinuePressed,
      onBack: widget.onBack,
      showBottomButtons: false,
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            if (_activeColorVariants.isEmpty)
              const Center(child: Text('No colors selected in the previous step.'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeColorVariants.length,
                itemBuilder: (context, index) {
                  final colorName = _activeColorVariants[index];
                  return _buildColorVariantCard(context, colorName);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 21),
              ),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: _addAnotherVariant,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(width: 1, color: Colors.black),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'Add Another Varient',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 11),
            _buildActionButtons(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // 3. MODIFIED: This now includes validation for images.
  Widget _buildColorVariantCard(BuildContext context, String colorName) {
    final variantState = _variantData[colorName]!;
    final List<String> selectedSizes = variantState['sizes'];
    final List<XFile> images = variantState['images'];

    return Container(
      decoration: ShapeDecoration(
        color: const Color(0xFFF8FAFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
          BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius: 0),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 17.5, vertical: 8),
        title: Text(colorName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF101727))),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(17.5, 0, 17.5, 24),
            child: Column(
              children: [
                // --- Available Sizes Field ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Sizes*',
                      style: TextStyle(color: Color(0xFF354152), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 7),
                    TextFormField(
                      controller: TextEditingController(text: selectedSizes.isEmpty ? null : 'valid'),
                      validator: (v) => selectedSizes.isEmpty ? 'Sizes are required for $colorName' : null,
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isCollapsed: true),
                      style: const TextStyle(fontSize: 0, height: 0),
                    ),
                    GestureDetector(
                      onTap: () => _showSizeMultiSelect(colorName),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(46.75),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedSizes.isEmpty ? 'Select Sizes' : selectedSizes.join(', '),
                                style: TextStyle(
                                  color: selectedSizes.isEmpty ? const Color(0xFF717182) : Colors.black,
                                  fontSize: selectedSizes.isEmpty ? 12.30 : 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const Opacity(opacity: 0.5, child: Icon(Icons.keyboard_arrow_down_rounded)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Upload Images Section ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Images*',
                      style: TextStyle(color: Color(0xFF354152), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 7),
                    // Hidden field for image validation
                    TextFormField(
                      controller: TextEditingController(text: images.length >= 3 ? 'valid' : null),
                      validator: (v) {
                        if (images.length < 3) {
                          return 'At least 3 images are required for $colorName';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isCollapsed: true),
                      style: const TextStyle(fontSize: 0, height: 0),
                    ),
                    const SizedBox(height: 7),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: (images.length + 1).clamp(0, 6),
                      itemBuilder: (context, index) {
                        if (index == images.length && images.length < 6) {
                          return _buildAddImageButton(onTap: () => _pickImages(colorName));
                        }
                        if (index >= images.length) return const SizedBox.shrink();
                        final imageFile = images[index];
                        return _buildImageThumbnail(imageFile);
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Upload at least 3 high-quality images. First image will be the main product image.',
                      style: TextStyle(color: Color(0xFF697282), fontSize: 10.50, height: 1.33),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.75),
          border: Border.all(color: const Color(0xFFD0D5DB), width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Color(0xFF697282)),
            SizedBox(height: 4),
            Text('Add Image', style: TextStyle(color: Color(0xFF697282), fontSize: 10.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(XFile imageFile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.75),
      child: Image.file(
        File(imageFile.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _onContinuePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA2DC00),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text(
            'Continue',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10.50),
        OutlinedButton(
          onPressed: widget.onBack,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(width: 1, color: Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text(
            'Back',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}

// lib/sellersscreens/addproduct/add_product_screen.dart

class _InventoryStep extends StatefulWidget {
  final VoidCallback onAddProduct;
  final VoidCallback onBack;
  final GlobalKey<FormState> formKey;
  // We need the controllers to read the selected variants
  final TextEditingController colorController;
  final TextEditingController sizeController;
  // A new controller to store inventory data
  final TextEditingController inventoryController;

  const _InventoryStep({
    super.key,
    required this.onAddProduct,
    required this.onBack,
    required this.formKey,
    required this.colorController,
    required this.sizeController,
    required this.inventoryController,
  });

  @override
  State<_InventoryStep> createState() => _InventoryStepState();
}

class _InventoryStepState extends State<_InventoryStep> {
  // This list will hold the combined variants like "Size M - Colour Black"
  final List<String> _variants = [];
  // This map will hold the TextEditingController for each variant's inventory
  final Map<String, TextEditingController> _inventoryControllers = {};

  @override
  void initState() {
    super.initState();
    _generateVariants();
  }

  /// Parses the color and size controllers to build the list of variants.
  void _generateVariants() {
    // The sizeController now holds data like "Black:[XS,S]; Red:[M,L]"
    final sizeEntries = widget.sizeController.text.split(';').where((s) => s.trim().isNotEmpty);

    for (var entry in sizeEntries) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        final color = parts[0].trim();
        // Remove brackets and split sizes
        final sizes = parts[1].replaceAll(RegExp(r'[\[\]]'), '').split(',');

        for (var size in sizes) {
          if (size.trim().isNotEmpty) {
            final variantName = 'Size ${size.trim()} - Colour $color';
            _variants.add(variantName);
            // Create a dedicated controller for each variant's inventory
            _inventoryControllers[variantName] = TextEditingController();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose all dynamically created controllers
    for (var controller in _inventoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onContinuePressed() {
    if (widget.formKey.currentState!.validate()) {
      // Form is valid, now structure the inventory data for submission
      final inventoryData = _inventoryControllers.entries.map((entry) {
        final variantName = entry.key; // "Size S - Colour Black"
        final quantity = entry.value.text;
        return '"$variantName":$quantity'; // e.g., "Size S - Colour Black":10
      }).join(',');

      widget.inventoryController.text = '{$inventoryData}'; // e.g., {"Size S - Colour Black":10, "Size M - Colour Black":15}

      print("Final Inventory Data: ${widget.inventoryController.text}");

      // Call the final submission method
      widget.onAddProduct();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all inventory fields.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Use the custom _FormStepContainer but hide its default buttons
    return _FormStepContainer(
      onContinue: _onContinuePressed,
      onBack: widget.onBack,
      showBottomButtons: false, // Hide default buttons
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            // Dynamically build the list of inventory cards
            ListView.separated(
              itemCount: _variants.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final variantName = _variants[index];
                return _buildInventoryCard(
                  variantName,
                  _inventoryControllers[variantName]!,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 21),
            ),
            const SizedBox(height: 28),
            // Add custom action buttons that match the rest of the app
            _buildActionButtons(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  /// Builds a single inventory card that matches the Figma design.
  Widget _buildInventoryCard(String variantName, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17.5, vertical: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFF8FAFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: const [
          BoxShadow(
              color: Color(0x19000000),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: -1),
          BoxShadow(
              color: Color(0x19000000),
              blurRadius: 3,
              offset: Offset(0, 1),
              spreadRadius: 0),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        shape: const Border(), // Removes divider when expanded
        collapsedShape: const Border(), // Removes divider when collapsed
        title: Text(
          variantName,
          style: const TextStyle(
            color: Color(0xFF101727),
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.only(top: 16, bottom: 16),
        children: [
          TextFormField(
            controller: controller,
            validator: (v) =>
            v == null || v.isEmpty ? 'Inventory is required' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Inventory Available*',
              labelStyle: const TextStyle(
                color: Color(0xFF717182),
                fontSize: 12.30,
                fontFamily: 'Plus Jakarta Sans',
              ),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(46),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(46),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(46),
                borderSide: const BorderSide(color: Color(0xFFA2DC00), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            keyboardType: TextInputType.number,
          )
        ],
      ),
    );
  }

  /// Builds the action buttons to match the Figma design
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Add Product Button
        ElevatedButton(
          onPressed: _onContinuePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA2DC00),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Add Product',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10.50),
        // Back Button
        OutlinedButton(
          onPressed: widget.onBack,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(width: 1, color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Back',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
*/
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Make sure these import paths are correct for your project structure
import 'package:zatch_app/model/categories_response.dart';
import 'package:zatch_app/sellersscreens/addproduct/product_added_success_screen.dart';
import 'package:zatch_app/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controller to manage which page (step) is visible
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // API Service instance
  final ApiService _apiService = ApiService();

  // --- FORM KEYS FOR VALIDATION ---
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  // --- STATE FOR API-DRIVEN DATA ---
  List<Category> _allCategories = [];
  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;

  // --- STATE MANAGEMENT FOR FORM DATA (STEP 1) ---
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  String _orderAcceptingType = "autoAccept";
  bool _isBargainEnabled = true;
  double _autoAcceptDiscount = 5.0;
  double _maxDiscount = 15.0;

  // --- STATE MANAGEMENT FOR FORM DATA (STEP 2, 3, etc.) ---
  final _colorController = TextEditingController();
  final _inventoryController = TextEditingController();
  String? _productId;

  // This map now holds the complete variant data from Step 3 to be used in Step 4
  Map<String, Map<String, dynamic>> _variantDataForStep4 = {};

  @override
  void initState() {
    super.initState();
    // Listen to changes in the sale price to update the bargain card
    _salePriceController.addListener(_updateBargainCard);
    _fetchCategories(); // Fetch data when the screen loads
  }

  @override
  void dispose() {
    // Dispose all controllers
    _pageController.dispose();
    _productNameController.dispose();
    _descriptionController.dispose();
    _salePriceController.removeListener(_updateBargainCard); // Remove listener
    _salePriceController.dispose();
    _discountedPriceController.dispose();
    _stockQuantityController.dispose();
    _colorController.dispose();
    _inventoryController.dispose();
    super.dispose();
  }

  // A simple method to trigger a rebuild when the price changes
  void _updateBargainCard() {
    setState(() {});
  }

  /// Fetch categories from the API and update the state.
  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _allCategories = categories;
        });
      }
    } catch (e) {
      _showMessage("Failed to load categories: ${e.toString()}", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Shows a snackbar with a message.
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 16,
            right: 16),
      ),
    );
  }

  /// Central logic for steps 1 and 2.
  Future<void> _handleNext() async {
    if (_isLoading) return;

    bool isFormValid = false;
    switch (_currentStep) {
      case 0:
        isFormValid = _step1FormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isFormValid = _step2FormKey.currentState?.validate() ?? false;
        break;
    }

    if (!isFormValid) {
      _showMessage("Please fill all required fields.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Only Step 1 makes an API call in this handler.
      if (_currentStep == 0) {
        Map<String, dynamic> payload = {
          "step": "1",
          "category": _selectedCategory?.slug ?? _selectedCategory?.name ?? '',
          "subCategory": (_selectedSubCategory?.id.startsWith('dummy-id') ?? false)
              ? '' // Send empty string for dummy sub-category
              : _selectedSubCategory?.slug ?? _selectedSubCategory?.name ?? '',
          "name": _productNameController.text,
          "description": _descriptionController.text,
          "price": int.tryParse(_salePriceController.text) ?? 0,
          "discountedPrice": int.tryParse(_discountedPriceController.text) ?? 0,
          "totalStock": int.tryParse(_stockQuantityController.text) ?? 0,
          "orderAcceptingType": _orderAcceptingType,
          "globalBargainSettings": {"enabled": _isBargainEnabled},
          "bargainSettings": {
            "autoAcceptDiscount": _autoAcceptDiscount,
            "maximumDiscount": _maxDiscount
          }
        };
        final response = await _apiService.submitProductStep(payload);

        if (response.containsKey('productId')) {
          _productId = response['productId'];
        }
        _showMessage(response['message'] ?? "Step 1 completed successfully!");
      }

      // If validation passes (for both steps 1 and 2), move to the next page.
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Special handler for Step 3 (Sizes & Images).
  Future<void> _handleStep3Next(Map<String, Map<String, dynamic>> variantData) async {
    if (!(_step3FormKey.currentState?.validate() ?? false)) {
      _showMessage("Please fill all required fields for each variant.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Store data for Step 4 (Inventory)
      _variantDataForStep4 = variantData;

      final formData = FormData();
      formData.fields.add(MapEntry('productId', _productId ?? ''));
      formData.fields.add(MapEntry('step', '3'));

      for (var entry in variantData.entries) {
        final color = entry.key;
        final data = entry.value;
        final List<String> sizes = data['sizes'];
        final List<XFile> images = data['images'];

        // Add sizes for the current color variant
        for(int i=0; i<sizes.length; i++) {
          formData.fields.add(MapEntry('variants[$color][sizes][$i]', sizes[i]));
        }

        // Add images for the current color variant
        for (int i = 0; i < images.length; i++) {
          final imageFile = images[i];
          formData.files.add(MapEntry(
            'variants[$color][images][$i]',
            await MultipartFile.fromFile(imageFile.path, filename: imageFile.name),
          ));
        }
      }

      // --- ACTUAL API CALL ---
      // final response = await _apiService.submitProductStepWithImages(formData);
      // _showMessage(response['message'] ?? "Variants and images submitted successfully!");

      // Simulating a successful API call for now
      print("SUBMITTING FORM DATA (SIMULATED): ${formData.fields} and ${formData.files.length} files");
      await Future.delayed(const Duration(seconds: 1));
      _showMessage("Variants and images submitted successfully!");


      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handles the final submission (Step 4: Inventory).
  Future<void> _handleFinalSubmission() async {
    if (!(_step4FormKey.currentState?.validate() ?? false)) {
      _showMessage("Please fill all inventory fields.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = {
        "step": "4",
        "productId": _productId,
        "inventory": _inventoryController.text, // JSON string from the inventory step
      };

      print("FINAL PAYLOAD (SIMULATED): $payload");
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const ProductAddedSuccessScreen(),
        ),
            (Route<dynamic> route) => false,
      );

    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }



  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(92.0),
        child: Container(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 40.0, bottom: 16),
          decoration: const ShapeDecoration(
            color: Color(0xFFCCF656),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (_currentStep == 0) {
                    Navigator.of(context).pop();
                  } else {
                    _previousPage();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFDFDEDE)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.black, size: 20),
                ),
              ),
              const Text(
                'Add Products',
                style: TextStyle(
                  color: Color(0xFF121111),
                  fontSize: 16,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 44), // Spacer for centering title
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 24.0),
                child: _FigmaProductStepper(currentStep: _currentStep),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() {
                      _currentStep = page;
                    });
                  },
                  children: [
                    // STEP 1
                    _ProductDetailsStep(
                      formKey: _step1FormKey,
                      onContinue: _handleNext,
                      nameController: _productNameController,
                      descriptionController: _descriptionController,
                      salePriceController: _salePriceController,
                      discountedPriceController: _discountedPriceController,
                      stockQuantityController: _stockQuantityController,
                      onBargainChanged: (enabled, autoAccept, max) {
                        setState(() {
                          _isBargainEnabled = enabled;
                          _autoAcceptDiscount = autoAccept;
                          _maxDiscount = max;
                        });
                      },
                      onOrderTypeChanged: (type) {
                        setState(() => _orderAcceptingType = type);
                      },
                      orderAcceptingType: _orderAcceptingType,
                      allCategories: _allCategories,
                      selectedCategory: _selectedCategory,
                      selectedSubCategory: _selectedSubCategory,
                      onCategoryChanged: (category) {
                        setState(() {
                          _selectedCategory = category;
                          _selectedSubCategory = null; // Reset sub-category
                        });
                      },
                      onSubCategoryChanged: (subCategory) {
                        setState(() {
                          _selectedSubCategory = subCategory;
                        });
                      },
                    ),
                    // STEP 2
                    _ColorVariantStep(
                      formKey: _step2FormKey,
                      onContinue: _handleNext,
                      onBack: _previousPage,
                      colorController: _colorController,
                    ),
                    // STEP 3
                    _SizeVariantStep(
                      formKey: _step3FormKey,
                      onContinue: _handleStep3Next, // Use the special handler for step 3
                      onBack: _previousPage,
                      colorController: _colorController,
                    ),
                    // STEP 4
                    _InventoryStep(
                      formKey: _step4FormKey,
                      onAddProduct: _handleFinalSubmission, // Use the final submission handler
                      onBack: _previousPage,
                      variantData: _variantDataForStep4, // Pass the data from step 3
                      inventoryController: _inventoryController,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

// ===================================================================
// ==== STEPPER AND CONTAINER WIDGETS
// ===================================================================
class _FigmaProductStepper extends StatelessWidget {
  final int currentStep;
  const _FigmaProductStepper({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final List<String> steps = [
      'Product\nDetails',
      'Colors',
      'Sizes',
      'Inventory'
    ];

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final bool isActive = currentStep >= index;
            final bool isCompleted = currentStep > index;

            // The line connecting the circles
            final Widget line = Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? const Color(0xFFA2DC00)
                    : const Color(0xFFDDDDDD),
              ),
            );

            // The circle itself
            final Widget circle = Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFA2DC00)
                    : const Color(0xFFDDDDDD),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFA2DC00)
                        : const Color(0xFFD9D9D9),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            );

            // If it's not the first circle, add a line before it
            if (index > 0) {
              return Expanded(
                child: Row(
                  children: [line, circle],
                ),
              );
            }
            return circle; // First circle has no preceding line
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(steps.length, (index) {
            return Expanded(
              child: Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF2C2C2C),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: currentStep == index
                      ? FontWeight.w600
                      : FontWeight.w400,
                  height: 1.36,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FormStepContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback onContinue;
  final VoidCallback? onBack;
  final String continueText;
  final bool showBottomButtons;

  const _FormStepContainer({
    super.key,
    required this.child,
    required this.onContinue,
    this.onBack,
    this.continueText = 'Continue',
    this.showBottomButtons = true, // Default to true for other steps
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: child,
          ),
        ),
        if (showBottomButtons)
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA2DC00),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    continueText,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (onBack != null) ...[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ]
              ],
            ),
          )
      ],
    );
  }
}

// ===================================================================
// ==== STEP 1: PRODUCT DETAILS
// ===================================================================

class _ProductDetailsStep extends StatelessWidget {
  final VoidCallback onContinue;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController salePriceController;
  final TextEditingController discountedPriceController;
  final TextEditingController stockQuantityController;
  final Function(bool, double, double) onBargainChanged;
  final ValueChanged<String> onOrderTypeChanged;
  final String orderAcceptingType;
  final List<Category> allCategories;
  final Category? selectedCategory;
  final SubCategory? selectedSubCategory;
  final ValueChanged<Category?> onCategoryChanged;
  final ValueChanged<SubCategory?> onSubCategoryChanged;

  const _ProductDetailsStep({
    super.key,
    required this.onContinue,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.salePriceController,
    required this.discountedPriceController,
    required this.stockQuantityController,
    required this.onBargainChanged,
    required this.onOrderTypeChanged,
    required this.orderAcceptingType,
    required this.allCategories,
    required this.selectedCategory,
    required this.selectedSubCategory,
    required this.onCategoryChanged,
    required this.onSubCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final subCategories = selectedCategory?.subCategories ?? [];
    final bool hasRealSubCategories = subCategories.isNotEmpty &&
        !(subCategories.length == 1 &&
            subCategories.first.id.startsWith('dummy-id'));

    final double salePrice = double.tryParse(salePriceController.text) ?? 0.0;

    return _FormStepContainer(
      onContinue: onContinue,
      showBottomButtons: false, // HIDE the default buttons for Step 1
      child: Form(
        key: formKey,
        child: Column(
          children: [
            // --- PRODUCT DETAILS CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 17.50, vertical: 24),
              decoration: ShapeDecoration(
                color: const Color(0xFFF8FAFB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                shadows: [
                  const BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
                  const BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius: 0),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 20, color: Color(0xFF101727)),
                      const SizedBox(width: 7),
                      const Text('Product Details', style: TextStyle(color: Color(0xFF101727), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown<Category>(
                    label: 'Category *',
                    hint: 'Select Category',
                    value: selectedCategory,
                    items: allCategories,
                    onChanged: onCategoryChanged,
                    itemToString: (Category cat) => cat.name,
                    validator: (v) => v == null ? "Category is required" : null,
                  ),
                  const SizedBox(height: 16),
                  if (hasRealSubCategories)
                    _buildDropdown<SubCategory>(
                      label: 'Sub Category *',
                      hint: 'Select Sub Category',
                      value: selectedSubCategory,
                      items: subCategories,
                      onChanged: onSubCategoryChanged,
                      itemToString: (SubCategory sub) => sub.name,
                      validator: (v) => v == null ? "Sub Category is required" : null,
                    ),
                  if (hasRealSubCategories) const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Product Name *',
                    hint: 'Enter product name',
                    controller: nameController,
                    validator: (v) => (v == null || v.isEmpty) ? "Product Name is required" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Description *',
                    hint: 'Describe your product...',
                    controller: descriptionController,
                    maxLines: 4,
                    validator: (v) => (v == null || v.isEmpty) ? "Description is required" : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Sale price *',
                          hint: '0',
                          controller: salePriceController,
                          hasCurrencySymbol: true,
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 10.50),
                      Expanded(
                        child: _buildTextField(
                          label: 'Discounted price',
                          hint: '0',
                          controller: discountedPriceController,
                          hasCurrencySymbol: true,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Stock Quantity *',
                    hint: 'Enter Stock Quantity',
                    controller: stockQuantityController,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? "Stock is required" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildOrderAcceptingType(),
                ],
              ),
            ),
            const SizedBox(height: 21),

            // --- BARGAIN SETTINGS CARD ---
            _FigmaBargainSettingsCard(
              salePrice: salePrice,
              onChanged: onBargainChanged,
            ),

            // --- SCROLLABLE ACTION BUTTONS ---
            const SizedBox(height: 28),
            _buildActionButtons(context),
            const SizedBox(height: 28), // Add some padding at the very bottom
          ],
        ),
      ),
    );
  }

  // --- NEW WIDGET FOR THE SCROLLABLE ACTION BUTTONS ---
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
          onPressed: () {
            // Closes the AddProductScreen entirely
            Navigator.of(context).pop();
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(width: 1, color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Cancel',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 10.50),
        ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA2DC00),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Generic Text Field styled to match Figma
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool hasCurrencySymbol = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF354152),
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF717182),
              fontSize: 12.30,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: hasCurrencySymbol
                ? const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 14.0, 4.0, 14.0),
              child: Text('₹',
                  style:
                  TextStyle(color: Color(0xFF717182), fontSize: 16)),
            )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: EdgeInsets.fromLTRB(
                hasCurrencySymbol ? 0 : 16, 14, 16, 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines > 1 ? 16 : 46.75),
              borderSide: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines > 1 ? 16 : 46.75),
              borderSide: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines > 1 ? 16 : 46.75),
              borderSide:
              const BorderSide(width: 1, color: Color(0xFFA2DC00)),
            ),
          ),
        ),
      ],
    );
  }

  // Generic Dropdown styled to match Figma
  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemToString,
    required FormFieldValidator<T>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF354152),
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 7),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemToString(item), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0x80344054)), // Opacity 50% on color #344054
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF717182),
              fontSize: 12.30,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(46.75),
              borderSide: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(46.75),
              borderSide: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(46.75),
              borderSide:
              const BorderSide(width: 1, color: Color(0xFFA2DC00)),
            ),
          ),
        ),
      ],
    );
  }

  // Order accepting type radio buttons
  Widget _buildOrderAcceptingType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Accepting Type *',
          style: TextStyle(
            color: Color(0xFF354152),
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: _RadioListTile(
                title: 'Auto Accept',
                value: 'autoAccept',
                groupValue: orderAcceptingType,
                onChanged: (val) {
                  if (val != null) {
                    onOrderTypeChanged(val);
                  }
                },
              ),
            ),
            Expanded(
              child: _RadioListTile(
                title: 'Ask before accepting',
                value: 'manual',
                groupValue: orderAcceptingType,
                onChanged: (val) {
                  if (val != null) {
                    onOrderTypeChanged(val);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ===================================================================
// ==== STEP 1 HELPER WIDGETS
// ===================================================================

class _RadioListTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioListTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: const Color(0xFFA2DC00),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaBargainSettingsCard extends StatefulWidget {
  final double salePrice;
  final Function(bool, double, double) onChanged;

  const _FigmaBargainSettingsCard({
    required this.salePrice,
    required this.onChanged,
  });

  @override
  __FigmaBargainSettingsCardState createState() =>
      __FigmaBargainSettingsCardState();
}

class __FigmaBargainSettingsCardState extends State<_FigmaBargainSettingsCard> {
  bool _isBargainEnabled = true;
  double _autoAcceptDiscount = 5.0;
  double _maxDiscount = 30.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_isBargainEnabled, _autoAcceptDiscount, _maxDiscount);
    });
  }

  void _handleSwitchChanged(bool value) {
    setState(() => _isBargainEnabled = value);
    widget.onChanged(value, _autoAcceptDiscount, _maxDiscount);
  }

  void _handleAutoAcceptChanged(double value) {
    setState(() => _autoAcceptDiscount = value);
    widget.onChanged(_isBargainEnabled, value, _maxDiscount);
  }

  void _handleMaxDiscountChanged(double value) {
    setState(() => _maxDiscount = value);
    widget.onChanged(_isBargainEnabled, _autoAcceptDiscount, value);
  }

  @override
  Widget build(BuildContext context) {
    final double priceFloor = widget.salePrice * (1 - _maxDiscount / 100);
    final double autoAcceptValue = widget.salePrice * (1 - _autoAcceptDiscount / 100);

    return Container(
      padding: const EdgeInsets.all(17.50),
      decoration: ShapeDecoration(
        color: const Color(0xFFF8FAFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: [
          const BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
          const BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius: 0),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.sell_outlined, size: 20, color: Color(0xFF101727)),
                  SizedBox(width: 7),
                  Text('Bargain Settings', style: TextStyle(color: Color(0xFF101727), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
                ],
              ),
              Switch(
                value: _isBargainEnabled,
                onChanged: _handleSwitchChanged,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF030213),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),
          if (_isBargainEnabled) ...[
            const SizedBox(height: 21),
            _buildSlider(
              label: 'Auto-Accept Discount',
              value: _autoAcceptDiscount,
              onChanged: _handleAutoAcceptChanged,
              displayColor: const Color(0xFF016630),
              backgroundColor: const Color(0xFFECECF0),
              displayValue: '${_autoAcceptDiscount.toInt()}% (₹${autoAcceptValue.toStringAsFixed(0)})',
              description: 'Orders at this discount or lower will be auto-accepted',
            ),
            const SizedBox(height: 21),
            _buildSlider(
              label: 'Maximum Discount',
              value: _maxDiscount,
              onChanged: _handleMaxDiscountChanged,
              displayColor: const Color(0xFF9F2D00),
              backgroundColor: const Color(0xFFFFECD4),
              displayValue: '${_maxDiscount.toInt()}%',
            ),
            const SizedBox(height: 21),
            _buildPriceFloorInfo(priceFloor),
          ]
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required Color displayColor,
    required Color backgroundColor,
    required String displayValue,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF354152), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.75),
              decoration: ShapeDecoration(
                color: backgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.75)),
              ),
              child: Text(
                displayValue,
                textAlign: TextAlign.center,
                style: TextStyle(color: displayColor, fontSize: 10.50, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 14.0,
            trackShape: const RoundedRectSliderTrackShape(),
            activeTrackColor: const Color(0xFF030213),
            inactiveTrackColor: const Color(0xFFECECF0),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0, elevation: 2.0),
            thumbColor: Colors.white,
            overlayColor: Colors.transparent,
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            onChanged: onChanged,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Color(0xFF697282), fontSize: 10.50, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400),
          ),
        ]
      ],
    );
  }

  Widget _buildPriceFloorInfo(double priceFloor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.50, vertical: 10.50),
      decoration: ShapeDecoration(
        color: const Color(0xFFECECF0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Price Floor:', style: TextStyle(color: Color(0xFF354152), fontSize: 12.30, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400)),
              Text('₹${priceFloor.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF101727), fontSize: 12, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 3.5),
          const Text('Buyer will bargain till this price at the most', style: TextStyle(color: Color(0xFF697282), fontSize: 10.50, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

// ===================================================================
// ==== STEP 2: COLOR VARIANT
// ===================================================================

class _ColorVariantStep extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final GlobalKey<FormState> formKey;
  final TextEditingController colorController;

  const _ColorVariantStep({
    super.key,
    required this.onContinue,
    required this.onBack,
    required this.formKey,
    required this.colorController
  });

  @override
  _ColorVariantStepState createState() => _ColorVariantStepState();
}

class _ColorVariantStepState extends State<_ColorVariantStep> {
  // List of available colors to choose from.
  final List<String> _availableColors = [
    'Black', 'White', 'Red', 'Green', 'Blue', 'Yellow', 'Pink', 'Purple',
    'Orange', 'Brown', 'Grey', 'Silver', 'Gold'
  ];

  // This list will hold the colors the user has selected.
  final List<String> _selectedColors = [];

  // This function is called before moving to the next step.
  void _onContinuePressed() {
    // Convert the list of selected colors into a single comma-separated string for the next step.
    widget.colorController.text = _selectedColors.join(',');

    // Trigger the validation and then proceed.
    if (widget.formKey.currentState!.validate()) {
      widget.onContinue();
    }
  }

  // Shows a multi-select dialog to pick colors
  Future<void> _showMultiSelect() async {
    final List<String>? results = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: _availableColors,
          initialSelectedItems: _selectedColors,
        );
      },
    );

    // Update the state if the user confirmed their selection.
    if (results != null) {
      setState(() {
        _selectedColors.clear();
        _selectedColors.addAll(results);
      });
      // This is important to re-run validation when colors are selected/deselected.
      widget.formKey.currentState?.validate();
    }
  }


  @override
  Widget build(BuildContext context) {
    // We override the onContinue to process our data first.
    return _FormStepContainer(
      onContinue: _onContinuePressed,
      onBack: widget.onBack,
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Colours*',
              style: TextStyle(
                color: Color(0xFF354152),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 7),

            // --- FAKE DROPDOWN BUTTON ---
            // This looks like a form field but opens our dialog on tap.
            GestureDetector(
              onTap: _showMultiSelect,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF9FAFB),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(46.75),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedColors.isEmpty
                            ? 'Select Colours'
                            : _selectedColors.join(', '),
                        style: TextStyle(
                          color: _selectedColors.isEmpty
                              ? const Color(0xFF717182)
                              : Colors.black,
                          fontSize: _selectedColors.isEmpty ? 12.30 : 14,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Opacity(
                      opacity: 0.5,
                      child: Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ],
                ),
              ),
            ),

            // --- HIDDEN VALIDATOR FIELD ---
            // This TextFormField is not visible but is used to show the validation error message.
            TextFormField(
              // Update the controller automatically for validation purposes
              controller: TextEditingController(text: _selectedColors.isNotEmpty ? 'valid' : null),
              validator: (value) {
                if (_selectedColors.isEmpty) {
                  return 'Please select at least one color.';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
              style: const TextStyle(fontSize: 0, height: 0), // Make the field invisible
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// ==== HELPER WIDGET FOR THE COLOR/SIZE SELECTION DIALOG
// ===================================================================

class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelectedItems;

  const MultiSelectDialog({
    super.key,
    required this.items,
    required this.initialSelectedItems,
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  // A temporary list to hold selections within the dialog
  final List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    // Copy the initial selections into the local state of the dialog
    _selectedItems.addAll(widget.initialSelectedItems);
  }

  // Called when a checkbox is tapped.
  void _itemChange(String item, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(item);
      } else {
        _selectedItems.remove(item);
      }
    });
  }

  // Closes the dialog without saving changes.
  void _cancel() {
    Navigator.pop(context);
  }

  // Closes the dialog and returns the selected items to the previous screen.
  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Items'),
      content: SingleChildScrollView(
        child: ListBody(
          // Create a CheckboxListTile for each available item.
          children: widget.items.map((item) {
            return CheckboxListTile(
              value: _selectedItems.contains(item),
              title: Text(item),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (isChecked) {
                if (isChecked != null) {
                  _itemChange(item, isChecked);
                }
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

// ===================================================================
// ==== STEP 3: SIZE AND IMAGE VARIANT
// ===================================================================

class _SizeVariantStep extends StatefulWidget {
  // The onContinue callback now passes the structured data map.
  final Function(Map<String, Map<String, dynamic>> variantData) onContinue;
  final VoidCallback onBack;
  final GlobalKey<FormState> formKey;
  final TextEditingController colorController;

  const _SizeVariantStep({
    super.key,
    required this.onContinue,
    required this.onBack,
    required this.formKey,
    required this.colorController,
  });

  @override
  _SizeVariantStepState createState() => _SizeVariantStepState();
}

class _SizeVariantStepState extends State<_SizeVariantStep> {
  final ImagePicker _picker = ImagePicker();

  final List<String> _allPossibleColors = [
    'Black', 'White', 'Red', 'Green', 'Blue', 'Yellow', 'Pink', 'Purple',
    'Orange', 'Brown', 'Grey', 'Silver', 'Gold'
  ];
  final List<String> _allPossibleSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  List<String> _activeColorVariants = [];
  // This holds the data for each color: its selected sizes and its images
  final Map<String, Map<String, dynamic>> _variantData = {};

  @override
  void initState() {
    super.initState();
    // Read the colors selected in the previous step
    final colors = widget.colorController.text.split(',').map((e) => e.trim()).toList();
    _activeColorVariants = colors.where((c) => c.isNotEmpty).toList();

    // Initialize the data map for each active color
    for (var color in _activeColorVariants) {
      _initializeVariantData(color);
    }
  }

  // Sets up the initial structure for a new color variant
  void _initializeVariantData(String color) {
    if (!_variantData.containsKey(color)) {
      _variantData[color] = {
        'sizes': <String>[],
        'images': <XFile>[],
      };
    }
  }

  // Let the user pick multiple images for a specific color
  Future<void> _pickImages(String color) async {
    final List<XFile> newImages = await _picker.pickMultiImage();
    if (newImages.isNotEmpty) {
      setState(() {
        final currentImages = _variantData[color]!['images'] as List<XFile>;
        currentImages.addAll(newImages);
        // Enforce the limit of 6 images
        _variantData[color]!['images'] = currentImages.take(6).toList();
        // Re-validate the form to clear any "image required" errors
        widget.formKey.currentState?.validate();
      });
    }
  }

  // Show a dialog to select multiple sizes for a specific color
  Future<void> _showSizeMultiSelect(String color) async {
    final List<String>? results = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: _allPossibleSizes,
          initialSelectedItems: List<String>.from(_variantData[color]!['sizes']),
        );
      },
    );

    if (results != null) {
      setState(() {
        _variantData[color]!['sizes'] = results;
      });
      // Re-validate to clear any "size required" errors
      widget.formKey.currentState?.validate();
    }
  }

  // Allow the user to add a new color variant not selected in the previous step
  Future<void> _addAnotherVariant() async {
    final remainingColors = _allPossibleColors.where((c) => !_activeColorVariants.contains(c)).toList();
    if (remainingColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All available colors have been added.')),
      );
      return;
    }

    final List<String>? results = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: remainingColors,
          initialSelectedItems: const [],
        );
      },
    );

    if (results != null && results.isNotEmpty) {
      setState(() {
        for (var newColor in results) {
          if (!_activeColorVariants.contains(newColor)) {
            _activeColorVariants.add(newColor);
            _initializeVariantData(newColor);
          }
        }
      });
    }
  }

  // Gathers the data and passes it to the parent widget
  void _onContinuePressed() {
    // Call the onContinue callback WITH the complete data map.
    // The parent widget is now responsible for handling the API call.
    widget.onContinue(_variantData);
  }

  @override
  Widget build(BuildContext context) {
    return _FormStepContainer(
      onContinue: _onContinuePressed,
      onBack: widget.onBack,
      showBottomButtons: false, // Use custom buttons at the bottom of the scroll view
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            if (_activeColorVariants.isEmpty)
              const Center(child: Text('No colors selected in the previous step.'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeColorVariants.length,
                itemBuilder: (context, index) {
                  final colorName = _activeColorVariants[index];
                  return _buildColorVariantCard(context, colorName);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 21),
              ),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: _addAnotherVariant,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(width: 1, color: Colors.black),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'Add Another Variant',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 11),
            _buildActionButtons(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // Builds the card for a single color variant (with size and image selection)
  Widget _buildColorVariantCard(BuildContext context, String colorName) {
    final variantState = _variantData[colorName]!;
    final List<String> selectedSizes = variantState['sizes'];
    final List<XFile> images = variantState['images'];

    return Container(
      decoration: ShapeDecoration(
        color: const Color(0xFFF8FAFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
          BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius: 0),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 17.5, vertical: 8),
        title: Text(colorName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF101727))),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(17.5, 0, 17.5, 24),
            child: Column(
              children: [
                // --- Available Sizes Field ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Sizes*',
                      style: TextStyle(color: Color(0xFF354152), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 7),
                    // Hidden field for size validation
                    TextFormField(
                      controller: TextEditingController(text: selectedSizes.isEmpty ? null : 'valid'),
                      validator: (v) => selectedSizes.isEmpty ? 'Sizes are required for $colorName' : null,
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isCollapsed: true),
                      style: const TextStyle(fontSize: 0, height: 0),
                    ),
                    GestureDetector(
                      onTap: () => _showSizeMultiSelect(colorName),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(46.75),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedSizes.isEmpty ? 'Select Sizes' : selectedSizes.join(', '),
                                style: TextStyle(
                                  color: selectedSizes.isEmpty ? const Color(0xFF717182) : Colors.black,
                                  fontSize: selectedSizes.isEmpty ? 12.30 : 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const Opacity(opacity: 0.5, child: Icon(Icons.keyboard_arrow_down_rounded)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Upload Images Section ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Images*',
                      style: TextStyle(color: Color(0xFF354152), fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 7),
                    // Hidden field for image validation
                    TextFormField(
                      controller: TextEditingController(text: images.length >= 3 ? 'valid' : null),
                      validator: (v) {
                        if (images.length < 3) {
                          return 'At least 3 images are required for $colorName';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isCollapsed: true),
                      style: const TextStyle(fontSize: 0, height: 0),
                    ),
                    const SizedBox(height: 7),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: (images.length + 1).clamp(0, 6),
                      itemBuilder: (context, index) {
                        // Show the "Add Image" button if there's space
                        if (index == images.length && images.length < 6) {
                          return _buildAddImageButton(onTap: () => _pickImages(colorName));
                        }
                        // Don't build anything beyond the image count
                        if (index >= images.length) return const SizedBox.shrink();

                        final imageFile = images[index];
                        return _buildImageThumbnail(imageFile);
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Upload at least 3 high-quality images. First image will be the main product image.',
                      style: TextStyle(color: Color(0xFF697282), fontSize: 10.50, height: 1.33),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // The button for adding new images
  Widget _buildAddImageButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.75),
          border: Border.all(color: const Color(0xFFD0D5DB), width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Color(0xFF697282)),
            SizedBox(height: 4),
            Text('Add Image', style: TextStyle(color: Color(0xFF697282), fontSize: 10.5)),
          ],
        ),
      ),
    );
  }

  // The thumbnail for a selected image
  Widget _buildImageThumbnail(XFile imageFile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.75),
      child: Image.file(
        File(imageFile.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  // The "Continue" and "Back" buttons for this step
  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _onContinuePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA2DC00),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text(
            'Continue',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10.50),
        OutlinedButton(
          onPressed: widget.onBack,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(width: 1, color: Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text(
            'Back',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// ==== STEP 4: INVENTORY
// ===================================================================

class _InventoryStep extends StatefulWidget {
  final VoidCallback onAddProduct;
  final VoidCallback onBack;
  final GlobalKey<FormState> formKey;
  // Receives the full variant data map from the parent state
  final Map<String, Map<String, dynamic>> variantData;
  // A controller to store the final inventory JSON
  final TextEditingController inventoryController;

  const _InventoryStep({
    super.key,
    required this.onAddProduct,
    required this.onBack,
    required this.formKey,
    required this.variantData,
    required this.inventoryController,
  });

  @override
  State<_InventoryStep> createState() => _InventoryStepState();
}

class _InventoryStepState extends State<_InventoryStep> {
  // This list will hold the combined variants like "Size M - Colour Black"
  final List<String> _variants = [];
  // This map will hold the TextEditingController for each variant's inventory
  final Map<String, TextEditingController> _inventoryControllers = {};

  @override
  void initState() {
    super.initState();
    _generateVariants();
  }

  /// Parses the variant data map passed from the parent to build the UI.
  void _generateVariants() {
    widget.variantData.forEach((color, data) {
      final List<String> sizes = data['sizes'];
      for (var size in sizes) {
        if (size.trim().isNotEmpty) {
          final variantName = 'Size ${size.trim()} - Colour $color';
          _variants.add(variantName);
          // Create a dedicated controller for each variant's inventory
          _inventoryControllers[variantName] = TextEditingController();
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose all dynamically created controllers
    for (var controller in _inventoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Prepares the inventory data and calls the final submission method
  void _onContinuePressed() {
    if (widget.formKey.currentState!.validate()) {
      // Form is valid, now structure the inventory data for submission
      final inventoryData = _inventoryControllers.entries.map((entry) {
        final variantName = entry.key; // "Size S - Colour Black"
        final quantity = entry.value.text;
        // e.g., "Size S - Colour Black":10
        return '"$variantName":${int.tryParse(quantity) ?? 0}';
      }).join(',');

      // e.g., {"Size S - Colour Black":10, "Size M - Colour Black":15}
      widget.inventoryController.text = '{$inventoryData}';

      // Call the final submission method in the parent widget
      widget.onAddProduct();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all inventory fields.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Use the custom _FormStepContainer but hide its default buttons
    return _FormStepContainer(
      onContinue: _onContinuePressed,
      onBack: widget.onBack,
      showBottomButtons: false, // Hide default buttons, use custom ones
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            // Dynamically build the list of inventory cards
            ListView.separated(
              itemCount: _variants.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final variantName = _variants[index];
                return _buildInventoryCard(
                  variantName,
                  _inventoryControllers[variantName]!,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 21),
            ),
            const SizedBox(height: 28),
            // Add custom action buttons that match the rest of the app
            _buildActionButtons(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  /// Builds a single inventory card that matches the Figma design.
  Widget _buildInventoryCard(String variantName, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17.5, vertical: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFF8FAFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: const [
          BoxShadow(
              color: Color(0x19000000),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: -1),
          BoxShadow(
              color: Color(0x19000000),
              blurRadius: 3,
              offset: Offset(0, 1),
              spreadRadius: 0),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        shape: const Border(), // Removes divider when expanded
        collapsedShape: const Border(), // Removes divider when collapsed
        title: Text(
          variantName,
          style: const TextStyle(
            color: Color(0xFF101727),
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.only(top: 16, bottom: 16),
        children: [
          TextFormField(
            controller: controller,
            validator: (v) =>
            v == null || v.isEmpty ? 'Inventory is required' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Inventory Available*',
              labelStyle: const TextStyle(
                color: Color(0xFF717182),
                fontSize: 12.30,
                fontFamily: 'Plus Jakarta Sans',
              ),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(46),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(46),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(46),
                borderSide: const BorderSide(color: Color(0xFFA2DC00), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            keyboardType: TextInputType.number,
          )
        ],
      ),
    );
  }

  /// Builds the action buttons to match the Figma design
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Add Product Button
        ElevatedButton(
          onPressed: _onContinuePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA2DC00),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Add Product',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10.50),
        // Back Button
        OutlinedButton(
          onPressed: widget.onBack,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(width: 1, color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Back',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

