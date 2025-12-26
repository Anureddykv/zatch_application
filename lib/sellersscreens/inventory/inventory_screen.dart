import 'package:flutter/material.dart';
import 'package:zatch/sellersscreens/addproduct/add_product_screen.dart';
import 'package:zatch/sellersscreens/inventory/view_product_screen.dart';

// ===================================================================
// 1. DEFINE YOUR DATA MODEL AT THE TOP
// ===================================================================
class Product {
  final int id;
  final String title;
  final String subtitle;
  final String cost;
  final String sku;
  final int stock;
  final String imageUrl;
  final bool lowStock;
  final bool outOfStock;
  bool isActive; // It's mutable, so it can't be final

  Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.cost,
    required this.sku,
    required this.stock,
    required this.imageUrl,
    this.lowStock = false,
    this.outOfStock = false,
    this.isActive = true, // <-- The crucial fix: initialize the value
  });
}


// Enum for sorting options
enum SortOption { none, alpha, stock }

// Enum for filter status
enum FilterStatus { none, lowStock, outOfStock }

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // ===================================================================
  // 2. NOW, THE List.generate USES THE CORRECT Product CLASS
  // ===================================================================
  final List<Product> _allProducts = List.generate(
    20,
        (i) => Product(
      id: i,
      title: 'Modern Light Clothes ${i + 1}',
      subtitle: 'Women Dress',
      cost: '₹${212 + i * 10}',
      sku: 'SKU${12 + i}',
      stock: (i % 5) == 4 ? 0 : (i % 5 == 3 ? 5 : 24 - i),
      imageUrl: 'https://picsum.photos/seed/${i + 1}/200/200',
      lowStock: (i % 5 == 3),
      outOfStock: (i % 5) == 4,
      // 'isActive' is now correctly initialized by the constructor's default
    ),
  );

  late List<Product> _filteredProducts;
  final List<Product> _selectedProducts = [];
  final TextEditingController _searchController = TextEditingController();

  SortOption _sortOption = SortOption.none;
  FilterStatus _filterStatus = FilterStatus.none;
  final GlobalKey _filterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(_allProducts);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilterAndSort() {
    setState(() {
      List<Product> tempProducts = _allProducts.where((product) {
        final query = _searchController.text.toLowerCase();
        if (query.isEmpty) return true;
        return product.title.toLowerCase().contains(query) ||
            product.subtitle.toLowerCase().contains(query);
      }).toList();

      // Filtering
      if (_filterStatus == FilterStatus.lowStock) {
        tempProducts =
            tempProducts.where((p) => p.lowStock && !p.outOfStock).toList();
      } else if (_filterStatus == FilterStatus.outOfStock) {
        tempProducts = tempProducts.where((p) => p.outOfStock).toList();
      }

      // Sorting
      if (_sortOption == SortOption.alpha) {
        tempProducts.sort((a, b) => a.title.compareTo(b.title));
      } else if (_sortOption == SortOption.stock) {
        tempProducts.sort((a, b) => a.stock.compareTo(b.stock));
      }

      _filteredProducts = tempProducts;
    });
  }

  void _onSearchChanged() {
    _applyFilterAndSort();
  }

  void _onProductSelected(Product product) {
    setState(() {
      if (_selectedProducts.any((p) => p.id == product.id)) {
        _selectedProducts.removeWhere((p) => p.id == product.id);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  void _showFilterDialog() {
    final RenderBox renderBox =
    _filterKey.currentContext!.findRenderObject() as RenderBox;
    final overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return _FilterDialog(
          position: position,
          onApply: (sortOption, filterStatus) {
            setState(() {
              _sortOption = sortOption;
              _filterStatus = filterStatus;
            });
            _applyFilterAndSort();
          },
          initialSortOption: _sortOption,
          initialFilterStatus: _filterStatus,
        );
      },
    );
  }

  void _showProductActionsDialog(BuildContext context, GlobalKey key, Product product) {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return _ProductActionsDialog(
          position: position,
          product: product,
          iconRenderBox: renderBox,
          onToggleActiveStatus: () {
            setState(() {
              product.isActive = !product.isActive;
            });
            Navigator.pop(context); // Close the dialog after action
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildBody(context),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedProducts.isNotEmpty) _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_selectedProducts.length} Item${_selectedProducts.length > 1 ? 's' : ''} Selected',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 59,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Center(
                child: Text(
                  'Out of Stock',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 59,
              decoration: ShapeDecoration(
                color: const Color(0xFFA2DC00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Center(
                child: Text(
                  'In Stock',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // This widget remains the same
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCCF656), Color(0x00CCF656)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDFDEDE)),
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
              const Text(
                'Inventory',
                style: TextStyle(
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF121111),
                ),
              ),
              const Icon(Icons.notifications_none, size: 26),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'My Inventory',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFF101727),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_allProducts.length} products • ${_selectedProducts.length} selected',
            style: const TextStyle(
              color: Color(0xFF495565),
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _gradientCard('₹16.8K', 'Inventory Value', '+8% this month',
                  const Color(0x4CCCF656), '₹'),
              _gradientCard(
                  '${_allProducts.length}',
                  'Total Products',
                  '+3 this month',
                  const Color(0x4CCCF656),
                  null,
                  icon: Icons.inventory_2_outlined),
              _gradientCard('1', 'Low Stock', 'Need attention',
                  const Color(0x33F5692B), null,
                  icon: Icons.warning_amber_rounded),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.analytics_outlined, size: 20),
              label: const Text(
                'View analytics',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF101727),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.75),
                  side: const BorderSide(color: Color(0xFFA2DC00)),
                ),
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientCard(String title, String subtitle, String foot,
      Color iconBg, String? symbol,
      {IconData? icon}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.75),
          boxShadow: const [
            BoxShadow(
                color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1)),
            BoxShadow(
                color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8.75),
              ),
              child: icon != null
                  ? Icon(icon, size: 16, color: const Color(0xFF4A5565))
                  : Center(
                child: Text(
                  symbol ?? '',
                  style: const TextStyle(
                    color: Color(0xFF4A5565),
                    fontSize: 14.05,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 19.36,
                fontFamily: 'Inter',
                color: Color(0xFF101727),
              ),
            ),
            const SizedBox(height: 3.5),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF697282),
                fontSize: 9.84,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 3.5),
            Text(
              foot,
              style: TextStyle(
                color: subtitle == 'Low Stock'
                    ? const Color(0xFFC93400)
                    : const Color(0xFF00A63D),
                fontSize: 9.52,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products',
                style: TextStyle(
                  color: Color(0xFF101727),
                  fontSize: 18,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProductScreen(),
                    ),
                  );
                },
                child: const Text(
                  '+ Add Products',
                  style: TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 2,
                          offset: Offset(0, 1)),
                      BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 3,
                          offset: Offset(0, 1)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          size: 20, color: Color(0xFF626262)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search Products or People...',
                            hintStyle: TextStyle(
                              color: Color(0xFF626262),
                              fontSize: 14,
                              fontFamily: 'Encode Sans',
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                key: _filterKey,
                onTap: _showFilterDialog,
                child: Row(
                  children: const [
                    Text(
                      'Filter',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                    Icon(Icons.filter_list, color: Color(0xFF666666)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = _filteredProducts[index];
              return _gradientProductTile(p);
            },
          ),
        ],
      ),
    );
  }

  Widget _gradientProductTile(Product p) {
    final isSelected = _selectedProducts.any((prod) => prod.id == p.id);
    final GlobalKey actionKey = GlobalKey();

    // Define the greyscale color filter for inactive products
    const ColorFilter greyscale = ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0,      0,      0,      1, 0,
    ]);

    // The main tile content, without the InkWell for the menu
    Widget productTileContent = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected && p.isActive ? const Color(0xFFFAFDF2) : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12.75),
        border: Border.all(
          color: isSelected && p.isActive ? const Color(0xFFA2DC00) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 4),
            decoration: ShapeDecoration(
              color: isSelected && p.isActive ? const Color(0xFFA2DC00) : const Color(0xFFF2F4F6),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: isSelected && p.isActive ? const Color(0xFFA2DC00) : Colors.black.withOpacity(0.1),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: isSelected && p.isActive
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.75),
            child: Image.network(
              p.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.30, fontFamily: 'Plus Jakarta Sans', color: Color(0xFF101727))),
                const SizedBox(height: 4),
                Text(p.subtitle, style: const TextStyle(color: Color(0xFF697282), fontSize: 14, fontFamily: 'Plus Jakarta Sans')),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _productDetailRow('Cost', p.cost),
                    const SizedBox(height: 4),
                    _productDetailRow('SKU', p.sku),
                    const SizedBox(height: 4),
                    _productDetailRow('Stock', '${p.stock} Units'),
                  ],
                ),
              ],
            ),
          ),
          // Leave an empty space for the action menu icon that will be in the Stack
          const SizedBox(width: 24),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        // Only allow selection if the product is active
        if (p.isActive) {
          _onProductSelected(p);
        }
      },
      child: Stack(
        children: [
          // The main content, which will be greyscaled if inactive
          ColorFiltered(
            colorFilter: !p.isActive ? greyscale : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
            child: productTileContent,
          ),

          // --- Action Menu and Badges ---
          // This Positioned widget sits ON TOP of the ColorFiltered content,
          // so its children can always receive taps.
          Positioned(
            top: 4,
            right: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  key: actionKey,
                  onTap: () => _showProductActionsDialog(context, actionKey, p),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0), // Increased padding for easier tapping
                    child: Icon(Icons.more_vert),
                  ),
                ),
                const SizedBox(height: 8),
                if (!p.isActive)
                  _badge('Inactive', const Color(0xFF717182), const Color(0xFFF4F4F4))
                else if (p.outOfStock)
                  _badge('Out of Stock', const Color(0xFFFEE1E1), const Color(0xFF9E0711))
                else if (p.lowStock)
                    _badge('Low Stock', const Color(0xFFFFECD4), const Color(0xFF9F2D00))
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _productDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label -',
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Inter',
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: Color(0xFF272727),
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.75),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: fg,
          fontSize: 10.50,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ===================================================================
// 3. REMOVE THE DUPLICATE CLASSES FROM THE BOTTOM OF THE FILE
//    AND KEEP THE DIALOG WIDGETS
// ===================================================================

// Custom Dialog for Filtering
class _FilterDialog extends StatefulWidget {
  final RelativeRect position;
  final Function(SortOption, FilterStatus) onApply;
  final SortOption initialSortOption;
  final FilterStatus initialFilterStatus;

  const _FilterDialog({
    required this.position,
    required this.onApply,
    required this.initialSortOption,
    required this.initialFilterStatus,
  });

  @override
  __FilterDialogState createState() => __FilterDialogState();
}

class __FilterDialogState extends State<_FilterDialog> {
  late SortOption _sortOption;
  late FilterStatus _filterStatus;

  @override
  void initState() {
    super.initState();
    _sortOption = widget.initialSortOption;
    _filterStatus = widget.initialFilterStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: widget.position.top - 140, // Adjust position to appear correctly
          left: widget.position.left - 250,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 309,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 10,
                      offset: Offset(0, 0))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter',
                    style: TextStyle(
                      color: Color(0xFF494949),
                      fontSize: 16,
                      fontFamily: 'Source Sans Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<FilterStatus>(
                    value: _filterStatus,
                    decoration: InputDecoration(
                      hintText: 'Filter by Status',
                      hintStyle: TextStyle(color: const Color(0x7F171717)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Color(0x9979747E)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: FilterStatus.none, child: Text('All')),
                      DropdownMenuItem(
                          value: FilterStatus.lowStock,
                          child: Text('Low Stock')),
                      DropdownMenuItem(
                          value: FilterStatus.outOfStock,
                          child: Text('Out of Stock')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _filterStatus = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sort',
                    style: TextStyle(
                      color: Color(0xFF494949),
                      fontSize: 16,
                      fontFamily: 'Source Sans Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _sortOption = SortOption.alpha;
                      });
                      widget.onApply(_sortOption, _filterStatus);
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Sort by A to Z',
                        style: TextStyle(
                          color: _sortOption == SortOption.alpha
                              ? Theme.of(context).primaryColor
                              : const Color(0xFF25213B),
                          fontSize: 16,
                          fontWeight: _sortOption == SortOption.alpha
                              ? FontWeight.bold
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _sortOption = SortOption.stock;
                      });
                      widget.onApply(_sortOption, _filterStatus);
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Sort by Stock',
                        style: TextStyle(
                          color: _sortOption == SortOption.stock
                              ? Theme.of(context).primaryColor
                              : const Color(0xFF25213B),
                          fontSize: 16,
                          fontWeight: _sortOption == SortOption.stock
                              ? FontWeight.bold
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductActionsDialog extends StatelessWidget {
  final RelativeRect position;
  final Product product;
  final RenderBox iconRenderBox;
  final VoidCallback onToggleActiveStatus;

  const _ProductActionsDialog({
    required this.position,
    required this.product,
    required this.iconRenderBox,
    required this.onToggleActiveStatus,
  });

  @override
  Widget build(BuildContext context) {
    const double dialogWidth = 199.0;
    final String toggleActionText = product.isActive ? 'Make Product Inactive' : 'Make Product Active';

    return Stack(
      children: [
        Positioned(
          top: position.bottom,
          left: position.left + iconRenderBox.size.width - dialogWidth,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: dialogWidth,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 3,
                      offset: Offset(0, 0))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildActionItem(context, 'Edit', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProductScreen(),
                      ),
                    );
                  }),
                  _buildActionItem(context, 'Delete', () {
                    print('Delete ${product.title}');
                    Navigator.pop(context);
                  }),
                  _buildActionItem(context, 'View Product', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewProductScreen(product: product),
                      ),
                    );
                  }),
                  _buildActionItem(context, toggleActionText, onToggleActiveStatus),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
      BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color(0xFF6A7282),
            fontSize: 16,
            fontFamily: 'Source Sans Pro',
          ),
        ),
      ),
    );
  }
}
