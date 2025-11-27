import 'package:flutter/material.dart';
import 'package:zatch_app/Widget/top_picks_this_week_widget.dart';
import 'package:zatch_app/model/carts_model.dart';
import 'package:zatch_app/view/setting_view/payments_shipping_screen.dart';
import 'package:zatch_app/view/zatching_details_screen.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/model/product_response.dart';

import '../cart_screen.dart';

// Enum to represent the different states of an order
enum OrderStatus { accepted, inTransit, outForDelivery, delivered, canceled }

class TrackOrderScreen extends StatefulWidget {
  // The status is passed to the screen to determine the UI state
  final OrderStatus status;

  // Mock data for demonstration purposes. In a real app, you'd pass an Order object.
  final String orderId = "2272345673287";
  final String deliveryDate = "12 Aug 2025";
  final int totalItems = 9;
  final double totalAmount = 1014.95;

  const TrackOrderScreen({super.key, required this.status});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  // In a real app, you would likely fetch order details, not a generic product list.
  // This part is kept from your original code.
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    try {
      // This fetches general products. You might want a specific API for "seller's products".
      return await _apiService.getProducts();
    } catch (e) {
      debugPrint("Error fetching products: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCustomStepper(),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildActionButtons(),
            ),
            const SizedBox(height: 30),
            const Divider(color: Color(0xFFCBCBCB)),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildProductCard(),
            ),
            // --- MODIFIED SECTION ---
            if (widget.status == OrderStatus.delivered)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Center(
                  child: SizedBox(
                    height: 44,
                    width: 200, // Give it a clear width
                    child: InkWell(
                      onTap: () {
                        // NOTE: This creates a placeholder product. In a real app,
                        // you would use the actual product data from the order.
                        final productToBuy = Product(
                            id: 'prod_123',
                            name: 'Modern light clothes',
                            images: [ProductImage(url: "https://i.pravatar.cc/100?img=5", publicId: '', id: '')],
                            price: 212.99,
                            // You might need to add other required fields depending on your model
                            color: "red",
                            size: "M",
                            likeCount: 5, description: '', reviews: []
                        );
                        _showBuyOrZatchBottomSheet(context, productToBuy, "buy");
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: ShapeDecoration(
                          color: const Color(
                              0xFFF1F1F1), // Using the secondary button style
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Buy Again',
                            style: TextStyle(
                              color: Color(0xFF272727),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDeliveryLocation(),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildShippingDetails(),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildShippingInfo(),
            ),
            const SizedBox(height: 30),
            // Reusing your existing widget for related products
            TopPicksThisWeekWidget(
              title: "products from this seller",
              showSeeAll: false,
            ),
            const SizedBox(width: 12),

          ],
        ),
      ),
    );
  }

  // ----------------------------
  // UI Widgets (Rebuilt to match Figma)
  // ----------------------------

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        customBorder: const CircleBorder(),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFDFDEDE)),
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child:
          const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
        ),
      ),
      title: const Text(
        'Track Order',
        style: TextStyle(
          color: Color(0xFF121111),
          fontSize: 16,
          fontFamily: 'Encode Sans',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCustomStepper() {
    final steps = [
      "Order\nAccepted",
      "In\nTransit",
      if (widget.status != OrderStatus.canceled) "Out for\nDelivery",
      widget.status == OrderStatus.canceled ? "Order\nCanceled" : "Order\nDelivered",
    ];

    int currentIndex = _currentStepIndex();
    final bool isOrderCanceled = widget.status == OrderStatus.canceled;
    // When canceled, progress stops visually before the final 'Canceled' step.
    double progressFactor = isOrderCanceled ? (currentIndex / (steps.length)) : (currentIndex / (steps.length - 1));

    return SizedBox(
      height: 100, // Adjusted height
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Align to top
        children: [
          // This Stack contains the progress line and the step circles
          Stack(
            alignment: Alignment.center,
            children: [
              // The main track line (gray)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(height: 2, color: const Color(0xFFDDDDDD)),
              ),
              // The progress line (green)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progressFactor,
                    child: Container(height: 2, color: const Color(0xFFA2DC00)),
                  ),
                ),
              ),
              // The step circles
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(steps.length, (index) {
                    final isCompleted = index < currentIndex;
                    final isActive = index == currentIndex;
                    final isLastCanceledStep = isOrderCanceled && (index == steps.length - 1);

                    Color stepColor;
                    Widget indicatorChild;

                    if (isLastCanceledStep) {
                      stepColor = const Color(0xFFFF4B4B); // Red for canceled
                      indicatorChild = const Icon(Icons.close, color: Colors.white, size: 20);
                    } else if (isCompleted) {
                      stepColor = const Color(0xFFA2DC00); // Green for completed
                      indicatorChild = const Icon(Icons.check, color: Colors.white, size: 20);
                    } else if (isActive) {
                      stepColor = const Color(0xFFA2DC00); // Green for active
                      indicatorChild = Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: stepColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      );
                    } else {
                      stepColor = const Color(0xFFDDDDDD); // Gray for pending
                      indicatorChild = Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: stepColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      );
                    }

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: stepColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        indicatorChild,
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // --- CORRECTION START ---
          // The text labels, now correctly aligned under the circles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(steps.length, (index) {
                final isLastCanceledStep = isOrderCanceled && (index == steps.length - 1);
                final Color textColor = isLastCanceledStep ? const Color(0xFFFF4B4B) : const Color(0xFF2C2C2C);

                // Wrap each Text widget in a SizedBox to constrain its width,
                // forcing the text to wrap and align centrally.
                return SizedBox(
                  // A width of ~60-80 usually works well for 2-3 lines of text.
                  // This forces the text to be centered within this box.
                  width: 65,
                  child: Text(
                    steps[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.36,
                    ),
                  ),
                );
              }),
            ),
          ),
          // --- CORRECTION END ---
        ],
      ),
    );
  }

  // No changes needed for _currentStepIndex, but including it for context.
  int _currentStepIndex() {
    switch (widget.status) {
      case OrderStatus.accepted:
        return 0;
      case OrderStatus.inTransit:
        return 1;
      case OrderStatus.outForDelivery:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.canceled:
      // When canceled, visually we are at the final step which is 'Canceled'.
        return 2;
    }
  }

  Widget _buildActionButtons() {
    // Reusable button component styled according to Figma
    Widget customButton(String label,
        {bool isPrimary = false, VoidCallback? onPressed}) {
      return Expanded(
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 44,
            decoration: ShapeDecoration(
              color: isPrimary
                  ? const Color(0xFF249B3E)
                  : const Color(0xFFF1F1F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : const Color(0xFF272727),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Logic to show buttons based on order status from Figma
    switch (widget.status) {
      case OrderStatus.delivered:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButton("Help with Order"),
            const SizedBox(width: 16),
            customButton("Download Invoice"),
          ],
        );
      case OrderStatus.canceled:
        return Center(
          child: SizedBox(
            width: 200, // Give it a specific width
            child: Row(
              children: [customButton("Buy Again", isPrimary: true,onPressed:(){
                final productToBuy = Product(
                    id: 'prod_123',
                    name: 'Modern light clothes',
                    images: [ProductImage(url: "https://i.pravatar.cc/100?img=5", publicId: '', id: '')],
                    price: 212.99,
                    // You might need to add other required fields depending on your model
                    color: "red",
                    size: "M",
                    likeCount: 5, description: '', reviews: []
                );
                _showBuyOrZatchBottomSheet(context, productToBuy, "buy");

              } )],
            ),
          ),
        );
      default: // For accepted, inTransit, outForDelivery
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButton("Cancel Order"),
            const SizedBox(width: 12),
            customButton("Buy Again", isPrimary: true,onPressed: (){
              final productToBuy = Product(
                  id: 'prod_123',
                  name: 'Modern light clothes',
                  images: [ProductImage(url: "https://i.pravatar.cc/100?img=5", publicId: '', id: '')],
                  price: 212.99,
                  // You might need to add other required fields depending on your model
                  color: "red",
                  size: "M",
                  likeCount: 5, description: '', reviews: []
              );
              _showBuyOrZatchBottomSheet(context, productToBuy, "buy");

            }),
          ],
        );
    }
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD3D3D3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              "https://i.pravatar.cc/100?img=5", // Placeholder
              width: 54,
              height: 54,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Modern light clothes',
                  style: TextStyle(
                    color: Color(0xFF121111),
                    fontSize: 14,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dress modern',
                  style: TextStyle(
                    color: Color(0xFF787676),
                    fontSize: 10,
                    fontFamily: 'Encode Sans',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '2 x 212.99 ₹',
                  style: TextStyle(
                    color: Color(0xFF292526),
                    fontSize: 14,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '442 ₹',
            style: TextStyle(
              color: Color(0xFF292526),
              fontSize: 14,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Location',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFD3D3D3)),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 66,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF2F2F2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: const Icon(Icons.home_outlined,
                    size: 32, color: Colors.black54),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home',
                      style: TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 12,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'A-403 Mantri Celestia, Financial District,Nanakram guda,....',
                      style: TextStyle(
                        color: Color(0xFF8D8D8D),
                        fontSize: 12,
                        fontFamily: 'Encode Sans',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShippingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Details',
          style: TextStyle(
            color: Color(0xFF121111),
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Deliver on : ${widget.deliveryDate}',
          style: const TextStyle(
            color: Color(0xFF292526),
            fontSize: 14,
            fontFamily: 'Encode Sans',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Shipped with DELHIVARY',
          style: TextStyle(
            color: Color(0xFF121111),
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tracking ID : ${widget.orderId}',
          style: const TextStyle(
            color: Color(0xFF292526),
            fontSize: 14,
            fontFamily: 'Encode Sans',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You can also contact delivery partner for order updates',
          style: TextStyle(
            color: Color(0xFF292526),
            fontSize: 11,
            fontFamily: 'Encode Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildShippingInfo() {
    // Reusable row for shipping info
    Widget infoRow(String title, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF292526),
                fontSize: 14,
                fontFamily: 'Encode Sans',
              ),
            ),
            Text(
              '$value ₹',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF121111),
                fontSize: 14,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Information',
          style: TextStyle(
            color: Color(0xFF121111),
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(color: Color(0xFFCBCBCB)),
        infoRow('Total (${widget.totalItems} items)',
            widget.totalAmount.toStringAsFixed(2)),
        infoRow('Shipping Fee', '0.00'),
        infoRow('Discount', '0.00'),
        const Divider(color: Color(0xFFCBCBCB)),
        infoRow('Sub Total', widget.totalAmount.toStringAsFixed(2)),
        const Divider(color: Color(0xFFCBCBCB)),
      ],
    );
  }

  // --- COPIED METHODS FROM LiveStreamScreen ---

  void _showBuyOrZatchBottomSheet(
      BuildContext context, Product product, String defaultOption) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int quantity = 1;
        double bargainPrice = product.price;
        String selectedOption = defaultOption;

        return StatefulBuilder(builder: (context, setState) {
          double price = product.price;
          double subTotal = selectedOption == "buy"
              ? price * quantity
              : bargainPrice * quantity;

          Widget buildCard({
            required String value,
            required String title,
            required Widget child,
          }) {
            bool isSelected = selectedOption == value;
            return Column(
              children: [
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => selectedOption = value),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color:
                          isSelected ? Colors.black : Colors.grey.shade300,
                          width: isSelected ? 2 : 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              value: value,
                              groupValue: selectedOption,
                              onChanged: (val) =>
                                  setState(() => selectedOption = val!),
                            ),
                            Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        child,
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AppBar with back button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context); // Close Buy/Zatch sheet
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Buy / Zatch",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                buildCard(
                  value: "buy",
                  title: "Buy Product",
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(product.images.first.url,
                            width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text(product.category?.name ?? "Category",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            Text("${price.toStringAsFixed(2)} ₹",
                                style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (quantity > 1) setState(() => quantity--);
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text("$quantity"),
                          IconButton(
                            onPressed: () => setState(() => quantity++),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                buildCard(
                  value: "zatch",
                  title: "Zatch",
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(product.images.first.url,
                                width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(product.category?.name ?? "Category",
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                                Text("${price.toStringAsFixed(2)} ₹",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (quantity > 1) setState(() => quantity--);
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text("$quantity"),
                              IconButton(
                                onPressed: () => setState(() => quantity++),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text("Bargain Price"),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Slider(
                              value: bargainPrice,
                              min: 100,
                              max: price,
                              divisions: ((price - 100) / 10).round(), // Example divisions
                              onChanged: (val) =>
                                  setState(() => bargainPrice = val),
                            ),
                          ),
                          Text("${bargainPrice.toStringAsFixed(0)} ₹"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCCF656),
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (selectedOption == "buy") {
                      final itemToCheckout = CartItem(
                        name: product.name,
                        description: product.category?.name ?? "Live Stream Item",
                        price: product.price,
                        quantity: quantity,
                        imageUrl: product.images.isNotEmpty
                            ? product.images.first.url
                            : "https://placehold.co/100x100?text=P",
                      );

                      double itemsTotal = itemToCheckout.price * itemToCheckout.quantity;
                      double shippingFee = 0.00; // Shipping is free on re-buy
                      double subTotal = itemsTotal + shippingFee;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutOrPaymentsScreen(isCheckout: true,
                            selectedItems: [itemToCheckout],
                            itemsTotalPrice: itemsTotal,
                            shippingFee: shippingFee,
                            subTotalPrice: subTotal,),
                        ),
                      );
                    } else {
                      // Navigate to Bargain screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ZatchingDetailsScreen(
                            zatch: Zatch(
                              id: "temp_${DateTime.now().millisecondsSinceEpoch}",
                              name: product.name,
                              description: product.category?.description ?? "A great product",
                              seller: "Seller Name", // You might get this from product data
                              imageUrl: product.images.first.url,
                              active: true,
                              status: "My Offer",
                              quotePrice: "${bargainPrice.toStringAsFixed(0)} ₹",
                              sellerPrice: "${product.price.toStringAsFixed(0)} ₹",
                              quantity: quantity,
                              subTotal: "${(bargainPrice * quantity).toStringAsFixed(0)} ₹",
                              date: DateTime.now().toString(),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(selectedOption == "buy" ? "Buy" : "Bargain"),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        });
      },
    );
  }
}
