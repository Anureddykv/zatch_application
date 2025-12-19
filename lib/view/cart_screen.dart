import 'package:flutter/material.dart';
import 'package:zatch_app/model/CartApiResponse.dart';
import 'package:zatch_app/model/carts_model.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/product_view/product_detail_screen.dart';
import 'package:zatch_app/view/setting_view/payments_shipping_screen.dart';
import 'home_page.dart';
import 'zatching_details_screen.dart';

class CartScreen extends StatefulWidget {
  final Function(Widget)? onNavigate;

  const CartScreen({super.key, this.onNavigate});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  void _handleNavigation(Widget screen) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(screen);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  late Future<CartModel?> _cartFuture;
  CartModel? _cart;
  final Map<String, bool> _selectedItems = {};

  List<Zatch> zatches = [
    Zatch(
      id: "1",
      name: "Modern light clothes",
      description: "Dress modern",
      seller: "Neu Fashions, Hyderabad",
      imageUrl: "https://picsum.photos/200/300",
      active: true,
      status: "My Offer",
      quotePrice: "212.99 ₹",
      sellerPrice: "800 ₹",
      quantity: 4,
      subTotal: "800 ₹",
      date: "Yesterday 12:00PM",
    ),
    Zatch(
      id: "2",
      name: "Modern light clothes",
      description: "Dress modern",
      seller: "Neu Fashions, Hyderabad",
      imageUrl: "https://picsum.photos/201/300",
      active: false,
      status: "Zatch Expired",
      quotePrice: "212.99 ₹",
      sellerPrice: "800 ₹",
      quantity: 4,
      subTotal: "800 ₹",
      date: "Yesterday 12:00PM",
      expiresIn: "Expires in 20h",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cartFuture = _fetchCart();
  }

  Future<CartModel?> _fetchCart() async {
    try {
      final cart = await _apiService.getCart();
      if (cart != null) {
        for (var item in cart.items) {
          _selectedItems.putIfAbsent(item.id, () => true);
        }
        _cart = cart;
      }
      return cart;
    } catch (e) {
      _showTopSnackBar("Error fetching cart: ${e.toString()}", isError: true);
      return null;
    }
  }

  Future<void> _updateCartItem(CartItemModel item, int newQuantity) async {
    final int oldQuantity = item.quantity;
    setState(() {
      item.quantity = newQuantity;
    });
    try {
      final updatedCart = await _apiService.updateCartItem(
        productId: item.id,
        quantity: newQuantity,
        color: item.variant.color,
      );
      if (updatedCart != null) {
        setState(() {
          _cart = updatedCart as CartModel?;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          item.quantity = oldQuantity;
        });
        _showTopSnackBar("Failed to update quantity: ${e.toString()}", isError: true);
      }
    }
  }

  Future<void> _removeCartItem(CartItemModel item) async {
    try {
      await _apiService.removeCartItem(productId: item.id);
      if (mounted && _cart != null) {
        setState(() {
          _cart!.items.removeWhere((i) => i.id == item.id);
          _selectedItems.remove(item.id);
        });
        _showTopSnackBar("${item.name} removed", isError: false);
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll("Exception:", "").trim();
      _showTopSnackBar(errorMessage, isError: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  void _showTopSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (homePageKey.currentState != null) {
              homePageKey.currentState!.closeSubScreen();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade700,
              tabs: const [Tab(text: "Cart"), Tab(text: "Zatches")],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildCartTab(), _buildZatchesTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartTab() {
    return FutureBuilder<CartModel?>(
      future: _cartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.items.isEmpty) return const Center(child: Text("Your cart is empty.", style: TextStyle(fontSize: 16, color: Colors.grey)));
        final cartItems = _cart?.items ?? [];
        final selectedCartItems = cartItems.where((item) => _selectedItems[item.id] ?? false).toList();
        int selectedItemsCount = selectedCartItems.length;
        double itemsTotalPriceValue = selectedCartItems.fold(0, (sum, i) => sum + (i.price * i.quantity));
        double shippingFeeValue = selectedItemsCount > 0 ? 10.0 : 0.0;
        double subTotalPriceValue = itemsTotalPriceValue + shippingFeeValue;
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 180),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _removeCartItem(item),
                  confirmDismiss: (direction) => _showRemoveItemDialog(item).then((_) => false),
                  background: Container(margin: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(14)), alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.delete, color: Colors.white)),
                  child: GestureDetector(
                    onTap: () => _handleNavigation(ProductDetailScreen(productId: item.id)),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))]),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(value: _selectedItems[item.id] ?? true, shape: const CircleBorder(), activeColor: const Color(0xFFB7DF4B), onChanged: (val) => setState(() => _selectedItems[item.id] = val ?? false)),
                            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.image, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error))),
                          ],
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                            if (item.variant.color != null) Text("Color: ${item.variant.color ?? item.variant.shade}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text("${item.price.toStringAsFixed(2)}₹", style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.remove_circle_outline), color: Colors.grey, iconSize: 20, onPressed: () { if (item.quantity > 1) { _updateCartItem(item, item.quantity - 1); } else { _showRemoveItemDialog(item); } }),
                            Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(icon: const Icon(Icons.add_circle_outline), color: Colors.grey, iconSize: 20, onPressed: () { setState(() { item.quantity = item.quantity + 1; }); }),
                          ],
                        ),
                      ),
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
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Items ($selectedItemsCount Selected)"), Text("${itemsTotalPriceValue.toStringAsFixed(2)}₹")]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Shipping Fee"), Text("${shippingFeeValue.toStringAsFixed(2)}₹")]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Sub Total", style: TextStyle(fontWeight: FontWeight.bold)), Text("${subTotalPriceValue.toStringAsFixed(2)}₹", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB7DF4B), minimumSize: const Size.fromHeight(45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: selectedItemsCount > 0 ? () { Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutOrPaymentsScreen(isCheckout: true, selectedItems: selectedCartItems, itemsTotalPrice: itemsTotalPriceValue, shippingFee: shippingFeeValue, subTotalPrice: subTotalPriceValue))); } : null,
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Active Zatches", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        for (final zatch in zatches.where((z) => z.active)) _zatchItem(zatch),
        const SizedBox(height: 20),
        const Text("Expired", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        for (final zatch in zatches.where((z) => !z.active)) _zatchItem(zatch),
      ],
    );
  }

  Widget _zatchItem(Zatch zatch) {
    return InkWell(
      onTap: () => _handleNavigation(ZatchingDetailsScreen(zatch: zatch)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: zatch.active ? Colors.green.withOpacity(0.05) : Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: zatch.active ? Colors.green.shade200 : Colors.grey.shade300)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(zatch.imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(zatch.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(zatch.date, style: const TextStyle(color: Colors.grey, fontSize: 11))]),
                  Text("Sold by: ${zatch.seller}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(zatch.status, style: TextStyle(fontWeight: FontWeight.bold, color: zatch.active ? Colors.green : Colors.orange)),
                  const SizedBox(height: 4),
                  Row(children: [Expanded(child: Text("Quote Price: ${zatch.quotePrice}", style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)), if (zatch.sellerPrice.isNotEmpty) Expanded(child: Text("Seller Price: ${zatch.sellerPrice}", style: TextStyle(fontSize: 12, color: zatch.active ? Colors.red : Colors.grey[700], fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]),
                  if (zatch.expiresIn != null) Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(zatch.expiresIn!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.red))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
