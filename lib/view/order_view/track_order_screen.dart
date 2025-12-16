import 'package:flutter/material.dart';
import 'package:zatch_app/Widget/top_picks_this_week_widget.dart';
import 'package:zatch_app/model/CartApiResponse.dart' as cart_model;
import 'package:zatch_app/model/carts_model.dart';
import 'package:zatch_app/view/setting_view/payments_shipping_screen.dart';
import 'package:zatch_app/view/zatching_details_screen.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/model/product_response.dart';

// Enum to represent the different states of an order
enum OrderStatus {
  accepted,
  processing,
  inTransit,
  outForDelivery,
  delivered,
  canceled
}
class TrackOrderScreen extends StatefulWidget {
  final OrderStatus status;
  final String orderId = "2272345673287";
  final String deliveryDate = "12 Aug 2025";
  final int totalItems = 9;
  final double totalAmount = 1014.95;

  const TrackOrderScreen({super.key, required this.status});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    try {
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
            if (widget.status == OrderStatus.delivered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Center(
                  child: SizedBox(
                    height: 44,
                    width: 200,
                    child: InkWell(
                      onTap: () {
                        // Fully populated Product with all required fields
                        final productToBuy = Product(
                          id: 'prod_123',
                          name: 'Modern light clothes',
                          isTopPick: false,
                          saveCount: 0,
                          viewCount: 0,
                          commentCount: 0,
                          averageRating: 0.0,
                          totalStock: 10,
                          images: [ProductImage(url: "https://i.pravatar.cc/100?img=5", publicId: '', id: '')],
                          price: 212.99,
                          variants: [],
                          likeCount: 5,
                          description: '',
                          reviews: []
                        );
                        _showBuyOrZatchBottomSheet(context, productToBuy, "buy");
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF1F1F1),
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
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
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
    // Minimal version
    return Container(
      height: 50,
      color: Colors.grey[200],
      child: const Center(child: Text("Stepper Placeholder")),
    );
  }

  Widget _buildActionButtons() {
    // Minimal version
    return Row(
      children: [
        ElevatedButton(onPressed: () {}, child: const Text("Cancel")),
        const SizedBox(width: 10),
        ElevatedButton(onPressed: () {}, child: const Text("Buy Again")),
      ],
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
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Icon(Icons.home_outlined, size: 32, color: Colors.black54),
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
                      'A-403 Mantri Celestia, Financial District, Nanakram guda,...',
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
        infoRow('Total (${widget.totalItems} items)', widget.totalAmount.toStringAsFixed(2)),
        infoRow('Shipping Fee', '0.00'),
        infoRow('Discount', '0.00'),
        const Divider(color: Color(0xFFCBCBCB)),
        infoRow('Sub Total', widget.totalAmount.toStringAsFixed(2)),
        const Divider(color: Color(0xFFCBCBCB)),
      ],
    );
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
              "https://i.pravatar.cc/100?img=5",
              width: 54,
              height: 54,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Modern light clothes',
                  style: TextStyle(
                    color: Color(0xFF121111),
                    fontSize: 14,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Dress modern',
                  style: TextStyle(
                    color: Color(0xFF787676),
                    fontSize: 10,
                    fontFamily: 'Encode Sans',
                  ),
                ),
                SizedBox(height: 8),
                Text(
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

  // Remaining methods like _currentStepIndex(), _buildCustomStepper(), _buildActionButtons(),
  // and _showBuyOrZatchBottomSheet remain unchanged but the Product instances now have all required fields.

  int _currentStepIndex() {
    switch (widget.status) {
      case OrderStatus.accepted:
        return 0;
      case OrderStatus.processing: // <--- ADD THIS CASE
        return 0; // Or 1, depending on how your visual stepper is designed
      case OrderStatus.inTransit:
        return 1;
      case OrderStatus.outForDelivery:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.canceled:
        return 0; // Or handle cancellation specifically
    }
  }


  // _buildCustomStepper() and _buildActionButtons() remain unchanged from your previous code

  void _showBuyOrZatchBottomSheet(BuildContext context, Product product, String defaultOption) {
    String? selectedVariant;
    int quantity = 1;
    double bargainPrice = product.price;
    String selectedOption = defaultOption;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          double price = product.price;
          double subTotal = selectedOption == "buy" ? price * quantity : bargainPrice * quantity;

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Buy / Zatch",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
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
