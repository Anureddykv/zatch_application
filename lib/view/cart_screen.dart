import 'package:flutter/material.dart';
import 'package:zatch_app/model/carts_model.dart';
import 'package:zatch_app/view/product_view/product_detail_screen.dart';
import 'package:zatch_app/view/setting_view/payments_shipping_screen.dart';
import 'zatching_details_screen.dart';

class CartItem {
  String name;
  String description;
  double price;
  bool isSelected;
  int quantity;
  String? saleInfo;
  String imageUrl;
  final String id;


  CartItem({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isSelected = true,
    this.quantity = 1,
    this.saleInfo,
  }): id = UniqueKey().toString();
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 🛒 Cart items
  List<CartItem> cartItems = [
    CartItem(
      name: "Modern light clothes",
      description: "Dress modern",
      price: 5.1,
      imageUrl: "https://picsum.photos/200/300",
      quantity: 4,
      isSelected: true,
    ),
    CartItem(
      name: "Modern light clothes",
      description: "Dress modern",
      price: 5.1,
      imageUrl: "https://picsum.photos/201/300",
      quantity: 4,
      isSelected: true,
    ),
    CartItem(
      name: "Modern light clothes",
      description: "Dress modern",
      price: 5.1,
      imageUrl: "https://picsum.photos/202/300",
      quantity: 4,
      isSelected: false,
      saleInfo: "Sale ends in 30 min",
    ),
    CartItem(
      name: "Modern light clothes",
      description: "Dress modern",
      price: 5.1,
      imageUrl: "https://picsum.photos/203/300",
      quantity: 4,
      isSelected: false,
    ),
  ];

  // ⏱ Zatches mock data
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
    Zatch(
      id: "3",
      name: "Modern light clothes",
      description: "Dress modern",
      seller: "Neu Fashions, Hyderabad",
      imageUrl: "https://picsum.photos/202/300",
      active: false,
      status: "Offer Rejected",
      quotePrice: "212.99 ₹",
      sellerPrice: "800 ₹",
      quantity: 4,
      subTotal: "800 ₹",
      date: "Yesterday 12:00PM",
    ),
    Zatch(
      id: "4",
      name: "Modern light clothes",
      description: "Dress modern",
      seller: "Neu Fashions, Hyderabad",
      imageUrl: "https://picsum.photos/203/300",
      active: true,
      status: "Seller Offer",
      quotePrice: "212.99 ₹",
      sellerPrice: "800 ₹",
      quantity: 4,
      subTotal: "800 ₹",
      date: "Yesterday 12:00PM",
    ),
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Future<void> _showRemoveItemDialog(CartItem item) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Do you want to remove this product from the cart?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
              onPressed: () {
                setState(() {
                  cartItems.remove(item);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
      ),
      body: Column(
        children: [
          // 🔹 Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
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

  /// 🛒 CART TAB DESIGN
  Widget _buildCartTab() {
    int selectedItemsCount = cartItems.where((item) => item.isSelected).length;

    double itemsTotalPriceValue = cartItems
        .where((i) => i.isSelected)
        .fold(0, (sum, i) => sum + (i.price * i.quantity));

    double shippingFeeValue = selectedItemsCount > 0 ? 10.0 : 0.0;
    double subTotalPriceValue = itemsTotalPriceValue + shippingFeeValue;

    String totalItemsPrice = "${itemsTotalPriceValue.toStringAsFixed(2)}₹";
    String shippingFee = "${shippingFeeValue.toStringAsFixed(2)}₹";
    String subTotalPrice = "${subTotalPriceValue.toStringAsFixed(2)}₹";

    return Stack(
      children: [
        cartItems.isEmpty
            ? const Center(
          child: Text(
            "Your cart is empty.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.only(bottom: 180),
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final item = cartItems[index];
            return GestureDetector(onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: /*item.id*/ "681ec215ce1efa433a4f5133",)));
            },
              child: Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  setState(() {
                    cartItems.remove(item); // Use remove(item) for safety
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${item.name} removed from cart"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6), // Match item margin
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: item.isSelected,
                          shape: const CircleBorder(),
                          activeColor: const Color(0xFFB7DF4B),
                          onChanged: (val) {
                            setState(() {
                              item.isSelected = val ?? false;
                            });
                          },
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (item.saleInfo != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              item.saleInfo!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        Text(
                          item.description,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${item.price.toStringAsFixed(1)}₹",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.grey,
                              iconSize: 20,
                              // --- THIS IS THE FINAL CORRECTED LOGIC ---
                              onPressed: () {
                                if (item.quantity > 1) {
                                  setState(() {
                                    item.quantity--;
                                  });
                                } else {
                                  // If quantity is 1, show the dialog to confirm removal
                                  _showRemoveItemDialog(item);
                                }
                              },
                            ),
                            Text(
                              "${item.quantity}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: Colors.grey,
                              iconSize: 20,
                              onPressed: () {
                                setState(() {
                                  item.quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // 🔹 Bottom summary
        if (cartItems.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black26,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Items ($selectedItemsCount Selected)"),
                      Text(totalItemsPrice),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const Text("Shipping Fee"), Text(shippingFee)],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sub Total",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subTotalPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB7DF4B),
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: selectedItemsCount > 0
                        ? () {
                      final selectedItems = cartItems
                          .where((item) => item.isSelected)
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutOrPaymentsScreen(
                            isCheckout: true,
                            selectedItems: selectedItems,
                            itemsTotalPrice: itemsTotalPriceValue, // Pass the double          shippingFee: shippingFeeValue,       // Pass the double
                            subTotalPrice: subTotalPriceValue,     // Pass the double
                          ),
                        ),
                      );

                    }
                        : null,
                    child: const Text(
                      "Pay",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  /// 🕒 ZATCHES TAB DESIGN
  Widget _buildZatchesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Active Zatches",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (final zatch in zatches.where((z) => z.active)) _zatchItem(zatch),
        const SizedBox(height: 20),
        const Text(
          "Expired",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (final zatch in zatches.where((z) => !z.active)) _zatchItem(zatch),
      ],
    );
  }

  Widget _zatchItem(Zatch zatch) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ZatchingDetailsScreen(zatch: zatch),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              zatch.active ? Colors.green.withOpacity(0.05) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: zatch.active ? Colors.green.shade200 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                zatch.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        zatch.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        zatch.date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Sold by: ${zatch.seller}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    zatch.status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: zatch.active ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Quote Price: ${zatch.quotePrice}",
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (zatch.sellerPrice.isNotEmpty)
                        Expanded(
                          child: Text(
                            "Seller Price: ${zatch.sellerPrice}",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  zatch.active ? Colors.red : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  if (zatch.expiresIn != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        zatch.expiresIn!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
