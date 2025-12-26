import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zatch/model/CartApiResponse.dart';
import 'package:zatch/model/carts_model.dart';
import 'package:zatch/model/bargain_model.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/view/product_view/product_detail_screen.dart';
import 'package:zatch/view/setting_view/payments_shipping_screen.dart';
import 'package:zatch/utils/snackbar_utils.dart';
import 'package:zatch/utils/local_storage.dart';
import 'home_page.dart';
import 'zatching_details_screen.dart';

class CartScreen extends StatefulWidget {
  final Function(Widget)? onNavigate;
  final int initialIndex;

  const CartScreen({super.key, this.onNavigate, this.initialIndex = 0});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  // ✅ PERSISTENT FIX: Use a regular set and load from LocalStorage
  final Set<String> _readZatchIds = {};
  // ✅ STATIC to persist selected tab when coming back within same session
  static int _persistentTabIndex = 0;

  void _handleNavigation(Widget screen) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(screen);
    } else if (homePageKey.currentState != null) {
      homePageKey.currentState!.navigateToSubScreen(screen);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  late Future<CartModel?> _cartFuture;
  CartModel? _cart;
  final Map<String, bool> _selectedItems = {};

  late Future<BargainListResponse> _bargainsFuture;
  List<BargainModel> _bargains = [];

  @override
  void initState() {
    super.initState();
    
    // Determine which tab to show: 
    // Prioritize widget.initialIndex if it's explicitly set (e.g., from Account Settings)
    // Otherwise, use the last selected tab index.
    int startingIndex = widget.initialIndex != 0 ? widget.initialIndex : _persistentTabIndex;
    
    _tabController = TabController(length: 2, vsync: this, initialIndex: startingIndex);
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _persistentTabIndex = _tabController.index;
      }
    });

    _loadReadZatches();
    _cartFuture = _fetchCart();
    _bargainsFuture = _fetchBargains();
  }

  Future<void> _loadReadZatches() async {
    final ids = await LocalStorage.getReadZatches();
    if (mounted) {
      setState(() {
        _readZatchIds.addAll(ids);
      });
    }
  }

  Future<void> _markAsRead(String bargainId) async {
    setState(() {
      _readZatchIds.add(bargainId);
    });
    await LocalStorage.setReadZatches(_readZatchIds);
  }

  Future<CartModel?> _fetchCart() async {
    try {
      final cart = await _apiService.getCart();
      if (cart != null) {
        for (var item in cart.items) {
          _selectedItems.putIfAbsent(item.id, () => true);
        }
        if (mounted) setState(() => _cart = cart);
      }
      return cart;
    } catch (e) {
      if (mounted) SnackBarUtils.showTopSnackBar(context, "Error fetching cart: $e", isError: true);
      return null;
    }
  }

  Future<BargainListResponse> _fetchBargains() async {
    try {
      final response = await _apiService.getMyBargains();
      if (mounted) setState(() => _bargains = response.bargains);
      return response;
    } catch (e) {
      debugPrint("Error fetching bargains: $e");
      return BargainListResponse(success: false, bargains: []);
    }
  }

  Future<void> _updateCartItem(CartItemModel item, int newQuantity) async {
    final int oldQuantity = item.quantity;
    setState(() => item.quantity = newQuantity);
    try {
      final updatedCart = await _apiService.updateCartItem(productId: item.productId, quantity: newQuantity, color: item.variant.color);
      if (updatedCart != null && mounted) setState(() => _cart = updatedCart as CartModel?);
    } catch (e) {
      if (mounted) {
        setState(() => item.quantity = oldQuantity);
        SnackBarUtils.showTopSnackBar(context, "Failed to update quantity: $e", isError: true);
      }
    }
  }

  Future<void> _removeCartItem(CartItemModel item) async {
    try {
      await _apiService.removeCartItem(productId: item.productId);
      if (mounted && _cart != null) {
        setState(() {
          _cart!.items.removeWhere((i) => i.id == item.id);
          _selectedItems.remove(item.id);
        });
        SnackBarUtils.showTopSnackBar(context, "${item.name} removed", isError: false);
      }
    } catch (e) {
      if (mounted) SnackBarUtils.showTopSnackBar(context, e.toString(), isError: true);
    }
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _showRemoveItemDialog(CartItemModel item) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to remove this product from the cart?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Remove'), onPressed: () { Navigator.of(context).pop(); _removeCartItem(item); }),
          ],
        );
      },
    );
  }

  void _onBackTap() {
    // ✅ FIX: Prefer closeSubScreen if it's a sub-screen to avoid popping HomePage
    if (homePageKey.currentState != null && homePageKey.currentState!.hasSubScreen) {
      homePageKey.currentState!.closeSubScreen();
    } else if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cart", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, centerTitle: true, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _onBackTap,
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
            child: TabBar(
              controller: _tabController, dividerColor: Colors.transparent, indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4), indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              labelColor: Colors.black, unselectedLabelColor: Colors.grey.shade700,
              tabs: const [Tab(text: "Cart"), Tab(text: "Zatches")],
            ),
          ),
          Expanded(child: TabBarView(controller: _tabController, children: [_buildCartTab(), _buildZatchesTab()])),
        ],
      ),
    );
  }

  Widget _buildCartTab() {
    return FutureBuilder<CartModel?>(
      future: _cartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _cart == null) return const Center(child: CircularProgressIndicator());
        final cartItems = _cart?.items ?? [];
        if (cartItems.isEmpty && snapshot.connectionState != ConnectionState.waiting) return const Center(child: Text("Your cart is empty.", style: TextStyle(fontSize: 16, color: Colors.grey)));

        final selectedCartItems = cartItems.where((item) => _selectedItems[item.id] ?? true).toList();
        double itemsTotalPriceValue = selectedCartItems.fold(0, (sum, i) => sum + (i.price * i.quantity));
        double shippingFeeValue = selectedCartItems.isNotEmpty ? 10.0 : 0.0;
        double subTotalPriceValue = itemsTotalPriceValue + shippingFeeValue;
        
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 180),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Dismissible(
                  key: Key(item.id), direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _removeCartItem(item),
                  confirmDismiss: (direction) => _showRemoveItemDialog(item).then((_) => false),
                  background: Container(margin: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(14)), alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.delete, color: Colors.white)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))]),
                    child: ListTile(
                      onTap: () => _handleNavigation(ProductDetailScreen(productId: item.productId, onNavigate: widget.onNavigate)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      leading: Row(mainAxisSize: MainAxisSize.min, children: [
                        Checkbox(value: _selectedItems[item.id] ?? true, shape: const CircleBorder(), activeColor: const Color(0xFFB7DF4B), onChanged: (val) => setState(() => _selectedItems[item.id] = val ?? false)),
                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.image, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.error))),
                      ]),
                      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        if (item.variant.color != null && item.variant.color!.isNotEmpty) Text("Color: ${item.variant.color}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text("${item.price.toStringAsFixed(2)}₹", style: const TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline), color: Colors.grey, iconSize: 20, onPressed: () { if (item.quantity > 1) { _updateCartItem(item, item.quantity - 1); } else { _showRemoveItemDialog(item); } }),
                        Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add_circle_outline), color: Colors.grey, iconSize: 20, onPressed: () => _updateCartItem(item, item.quantity + 1)),
                      ]),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)), boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, -2))]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Items (${selectedCartItems.length} Selected)"), Text("${itemsTotalPriceValue.toStringAsFixed(2)}₹")]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Shipping Fee"), Text("${shippingFeeValue.toStringAsFixed(2)}₹")]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Sub Total", style: TextStyle(fontWeight: FontWeight.bold)), Text("${subTotalPriceValue.toStringAsFixed(2)}₹", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB7DF4B), minimumSize: const Size.fromHeight(45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: selectedCartItems.isNotEmpty ? () { 
                        _handleNavigation(CheckoutOrPaymentsScreen(isCheckout: true, isDirectOrder: false, selectedItems: selectedCartItems, itemsTotalPrice: itemsTotalPriceValue, shippingFee: shippingFeeValue, subTotalPrice: subTotalPriceValue)); 
                      } : null,
                      child: const Text("Pay", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildZatchesTab() {
    return FutureBuilder<BargainListResponse>(
      future: _bargainsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _bargains.isEmpty) return const Center(child: CircularProgressIndicator());
        if (_bargains.isEmpty) return const Center(child: Text("No zatches found.", style: TextStyle(fontSize: 16, color: Colors.grey)));

        // ✅ Categorize lists based on status
        final active = _bargains.where((b) => b.status == "pending" || b.status == "buyer_countered" || b.status == "countered").toList();
        final past = _bargains.where((b) => b.status == "rejected" || b.status == "accepted" || b.status == "auto_accepted").toList();
        final expired = _bargains.where((b) => b.status == "expired").toList();

        return RefreshIndicator(
          onRefresh: () async { setState(() => _bargainsFuture = _fetchBargains()); await _bargainsFuture; },
          child: ListView(
            children: [
              if (active.isNotEmpty) ...[ 
                _sectionHeader("Active Zatches"), 
                for (var b in active) _zatchDesignItem(b, isUnread: !_readZatchIds.contains(b.id), isExpired: false)
              ],
              if (past.isNotEmpty) ...[ 
                _sectionHeader("Past Zatches"), 
                for (var b in past) _zatchDesignItem(b, isUnread: !_readZatchIds.contains(b.id), isExpired: false) 
              ],
              if (expired.isNotEmpty) ...[ 
                _sectionHeader("Expired Zatches"), 
                for (var b in expired) _zatchDesignItem(b, isUnread: false, isExpired: true) 
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Column(
      children: [
        const Divider(height: 1, color: Color(0xFFE8E8E8)),
        Container(
          width: double.infinity, height: 64,
          alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 22),
          child: Text(title, style: const TextStyle(color: Color(0xFF121111), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
        ),
        const Divider(height: 1, color: Color(0xFFE8E8E8)),
      ],
    );
  }

  Widget _zatchDesignItem(BargainModel bargain, {required bool isUnread, required bool isExpired}) {
    final product = bargain.product;
    final seller = bargain.seller;
    
    // ✅ DEBUG PRINT: Show prices in console
    debugPrint("--- ZATCH ITEM DEBUG ---");
    debugPrint("Product: ${product?.name}");
    debugPrint("Offer Price: ${bargain.offeredPrice}");
    debugPrint("Current/Seller Price: ${bargain.currentPrice}");
    debugPrint("------------------------");

    // Status Label logic
    String statusLabel = bargain.status ?? "Request";
    if (isExpired) {
      statusLabel = "Expired";
    } else if (bargain.status == "accepted") {
      statusLabel = "Accepted";
    } else if (bargain.status == "auto_accepted") {
      statusLabel = "Auto Accepted";
    } else if (bargain.status == "rejected") {
      statusLabel = "Rejected";
    } else if (bargain.status == "seller_countered") {
      statusLabel = "Seller Responded";
    }
    
    // ✅ Dynamic UI logic matching Figma design
    Color bgColor = const Color(0xFFFCFCFF); 
    if (isUnread) bgColor = const Color(0xFFFAFFEB); 

    return InkWell(
      onTap: () {
        // ✅ PERSISTENT FIX: Update set, save to LocalStorage, and last selected tab index
        _markAsRead(bargain.id);
        _persistentTabIndex = 1; // Ensure we stay on Zatches tab
        _handleNavigation(ZatchingDetailsScreen(bargainId: bargain.id));
      },
      child: Container(
        width: double.infinity,
        height: 163,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: bgColor, border: const Border(bottom: BorderSide(color: Color(0xFFE8E8E8)))),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image (70x70 with borderRadius 30)
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                      image: NetworkImage(product?.images.isNotEmpty == true ? product!.images.first.url : "https://placehold.co/70x70"), 
                      fit: BoxFit.cover,
                      // ✅ Grayscale filter for expired items
                      colorFilter: isExpired 
                        ? const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      1, 0,
                          ])
                        : null,
                    ),
                    boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 5))],
                  ),
                ),
                const SizedBox(width: 16),
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(product?.name ?? "Product", style: const TextStyle(color: Color(0xFF001E2F), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600, height: 1.71)),
                      Text("Sold by : ${seller?.username ?? 'Unknown'}", style: const TextStyle(color: Color(0xFF74777F), fontSize: 12, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400, height: 1.67)),
                      const SizedBox(height: 4),
                      Text(
                        statusLabel, 
                        style: TextStyle(
                          color: isExpired ? Colors.grey : (bargain.status == "accepted" ? Colors.blue : (bargain.status == "rejected" ? Colors.red : (statusLabel == "Seller Responded" ? const Color(0xFF001E2F) : const Color(0xFF97CD01)))), 
                          fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600
                        )
                      ),
                    ],
                  ),
                ),
                // Time & Unread Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bargain.createdAt != null ? DateFormat('EEEE, h:mm a').format(bargain.createdAt!) : "", 
                      style: const TextStyle(color: Color(0xFF74777F), fontSize: 12, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400)
                    ),
                    const SizedBox(height: 8),
                    if (isUnread && !isExpired)
                      Container(
                        width: 22, height: 22, decoration: const BoxDecoration(color: Color(0xFFCCF656), shape: BoxShape.circle),
                        alignment: Alignment.center, child: const Text("1", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black)),
                      ),
                  ],
                ),
              ],
            ),
            // Prices positioned at bottom matching Figma Positioned(left: 103, top: 94)
            Positioned(
              left: 86,
              bottom: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _priceColumn("Quote Price", "${bargain.offeredPrice.toStringAsFixed(2)} ₹"),
                  const SizedBox(width: 40),
                  _priceColumn("Seller Price", "${bargain.currentPrice.toStringAsFixed(2)} ₹", expiry: bargain.status == "seller_countered" ? "20h" : null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceColumn(String label, String price, {String? expiry}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF74777F), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400, height: 1.43)),
        Text.rich(TextSpan(children: [
          TextSpan(text: price, style: const TextStyle(color: Color(0xFF292526), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
          if (expiry != null) TextSpan(text: " ( Expires in $expiry )", style: const TextStyle(color: Color(0xFFFF7A50), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
        ])),
      ],
    );
  }
}
