import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zatch/Widget/top_picks_this_week_widget.dart';
import 'package:zatch/model/order_model.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/utils/snackbar_utils.dart';
import 'package:zatch/view/product_view/product_detail_screen.dart';
import 'package:zatch/view/help_screen.dart';
import 'package:zatch/view/home_page.dart';
import 'package:zatch/view/setting_view/payments_shipping_screen.dart';
import 'package:zatch/model/CartApiResponse.dart' as cart_model;

class TrackOrderScreen extends StatefulWidget {
  final OrderModel order;

  const TrackOrderScreen({super.key, required this.order});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final ApiService _apiService = ApiService();
  late OrderModel _currentOrder;
  bool _isCancelling = false;
  bool _isGeneratingInvoice = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  int _getStepIndexFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'confirmed':
        return 0; 
      case 'processing': 
        return 1;
      case 'shipped':
      case 'out_for_delivery':
        return 2; 
      case 'delivered':
      case 'completed':
        return 3; 
      case 'cancelled':
        return 0;
      default:
        return 0;
    }
  }

  Future<void> _handleCancelOrder() async {
    final TextEditingController reasonController = TextEditingController();
    
    final String? reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to cancel this order?"),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: "Enter reason for cancellation",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Keep Order", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                SnackBarUtils.showTopSnackBar(context, "Please provide a reason", isError: true);
                return;
              }
              Navigator.pop(context, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Cancel Order", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (reason == null) return;

    setState(() => _isCancelling = true);
    try {
      final updatedOrder = await _apiService.cancelOrder(_currentOrder.id, reason);
      if (mounted) {
        setState(() {
          _currentOrder = updatedOrder;
          _isCancelling = false;
        });
        SnackBarUtils.showTopSnackBar(context, "Order cancelled successfully");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        SnackBarUtils.showTopSnackBar(context, "Failed to cancel order: $e", isError: true);
      }
    }
  }
  Future<void> _handleDownloadInvoice() async {
    setState(() => _isGeneratingInvoice = true);

    try {
      final Map<String, String> invoice =
      await _apiService.generateInvoice(_currentOrder.id);

      final String relativeUrl = invoice['url'] ?? '';

      if (relativeUrl.isEmpty) {
        throw Exception('Invoice URL is empty');
      }

      final String fullUrl = relativeUrl.startsWith('http')
          ? relativeUrl
          : 'https://zatch-e9ye.onrender.com$relativeUrl';

      final Uri uri = Uri.parse(fullUrl);

      if (!await canLaunchUrl(uri)) {
        throw Exception('Could not open invoice');
      }

      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showTopSnackBar(
          context,
          'Failed to download invoice: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingInvoice = false);
      }
    }
  }

  void _handleBuyAgain() {
    if (_currentOrder.items.isNotEmpty) {
      final List<cart_model.CartItemModel> itemsToBuy = _currentOrder.items.map((item) {
        return cart_model.CartItemModel(
          id: "temp_${item.productId}",
          productId: item.productId,
          sellerId: item.sellerId,
          name: item.name,
          description: "",
          price: item.price.toDouble(),
          discountedPrice: item.price.toDouble(),
          image: item.image,
          images: [],
          variant: cart_model.VariantModel(
            color: item.variant?.color,
            size: item.variant?.size,
          ),
          selectedVariant: {
            "color": item.variant?.color,
            "size": item.variant?.size,
          },
          quantity: item.qty,
          category: "",
          subCategory: "",
          productCategory: "",
          lineTotal: item.total.toInt(),
        );
      }).toList();

      final checkoutScreen = CheckoutOrPaymentsScreen(
        isCheckout: true,
        isDirectOrder: true,
        selectedItems: itemsToBuy,
        itemsTotalPrice: _currentOrder.pricing.subtotal.toDouble(),
        shippingFee: _currentOrder.pricing.shipping.toDouble(),
        subTotalPrice: _currentOrder.pricing.total.toDouble(),
      );

      if (homePageKey.currentState != null) {
        homePageKey.currentState!.navigateToSubScreen(checkoutScreen);
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => checkoutScreen));
      }
    }
  }

  void _handleHelpNavigation() {
    if (homePageKey.currentState != null) {
      homePageKey.currentState!.navigateToSubScreen(const HelpScreen());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HelpScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentStep = _getStepIndexFromStatus(_currentOrder.status);
    bool isCanceled = _currentOrder.status.toLowerCase() == 'cancelled';
    bool isDelivered = _currentOrder.status.toLowerCase() == 'delivered';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
              child: Center(
                child: CustomOrderStepper(
                  currentStep: currentStep,
                  isCancelled: isCanceled,
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (isCanceled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildCancelledActions(),
              ),

            if (!isCanceled && !isDelivered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildActionButtons(),
              ),

            if (isDelivered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildDeliveredTopActions(),
              ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFFE0E0E0), thickness: 1),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: _currentOrder.items
                    .map((item) => _buildProductCard(item))
                    .toList(),
              ),
            ),

            if (isDelivered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16),
                child: _buildBuyAgainButton(),
              ),

            const SizedBox(height: 24),

            if (_currentOrder.deliveryAddress != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildDeliveryLocation(_currentOrder.deliveryAddress!),
              ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildShippingDetails(_currentOrder),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildShippingInfo(_currentOrder),
            ),
            const SizedBox(height: 30),

            const TopPicksThisWeekWidget(
              title: "Products from this seller",
              showSeeAll: false,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: InkWell(
        onTap: () {
          if (homePageKey.currentState != null && homePageKey.currentState!.hasSubScreen) {
            homePageKey.currentState!.closeSubScreen();
          } else {
            Navigator.pop(context);
          }
        },
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isCancelling ? null : _handleCancelOrder,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: _isCancelling 
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('Cancel Order', style: TextStyle(color: Colors.black)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleHelpNavigation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F1F1),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Help with Order'),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelledActions() {
    return Center(
      child: Container(
        width: 150,
        child: ElevatedButton(
          onPressed: _handleBuyAgain,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF6F6F6),
            foregroundColor: const Color(0xFF272727),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: const Text('Buy Again', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildDeliveredTopActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _handleHelpNavigation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F1F1),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Help with Order'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isGeneratingInvoice ? null : _handleDownloadInvoice,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF6F6F6),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isGeneratingInvoice 
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('Download Invoice'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyAgainButton() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _handleBuyAgain,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text(
          'Buy Again', 
          style: TextStyle(
            color: Colors.black, 
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w700,
          )
        ),
      ),
    );
  }

  Widget _buildProductCard(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
              item.image,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) =>
                  Container(width: 54, height: 54, color: Colors.grey[200]),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Color(0xFF121111),
                    fontSize: 14,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    if (item.variant?.color != null)
                      Text('Color: ${item.variant!.color}',
                          style: const TextStyle(color: Color(0xFF787676), fontSize: 10)),
                    if (item.variant?.size != null)
                      Text('Size: ${item.variant!.size}',
                          style: const TextStyle(color: Color(0xFF787676), fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.qty} x ${item.price.toStringAsFixed(2)} ₹',
                  style: const TextStyle(
                    color: Color(0xFF292526),
                    fontSize: 14,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.total.toStringAsFixed(2)} ₹',
            style: const TextStyle(
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

  Widget _buildDeliveryLocation(DeliveryAddress address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Location',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Encode Sans'),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Icon(Icons.home_outlined, size: 32, color: Colors.black54),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Encode Sans'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.toString(),
                      style: const TextStyle(
                          color: Color(0xFF8D8D8D), fontSize: 12, fontFamily: 'Encode Sans'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phone: ${address.phone}',
                      style: const TextStyle(
                          color: Color(0xFF8D8D8D), fontSize: 12, fontFamily: 'Encode Sans'),
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

  Widget _buildShippingDetails(OrderModel order) {
    String deliveryDate = "Pending Confirmation";
    if (order.expectedDelivery != null) {
      deliveryDate = DateFormat('d MMMM y').format(order.expectedDelivery!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Details',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Encode Sans'),
        ),
        const SizedBox(height: 12),
        Text('Expected Delivery: $deliveryDate',
            style: const TextStyle(fontSize: 14, fontFamily: 'Encode Sans')),
        const SizedBox(height: 16),
        const Text('Shipped with Zatch Logistics',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Encode Sans')),
        const SizedBox(height: 8),
        Text('Order ID : ${order.orderId}',
            style: const TextStyle(fontSize: 14, fontFamily: 'Encode Sans')),
      ],
    );
  }

  Widget _buildShippingInfo(OrderModel order) {
    Widget infoRow(String title, String value, {bool isBold = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontFamily: 'Encode Sans')),
            Text('$value ₹',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    fontFamily: 'Encode Sans')),
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
              fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Encode Sans'),
        ),
        const SizedBox(height: 12),
        const Divider(color: Color(0xFFE0E0E0)),
        infoRow('Subtotal', order.pricing.subtotal.toStringAsFixed(2)),
        infoRow('Shipping Fee', order.pricing.shipping.toStringAsFixed(2)),
        infoRow('Tax', order.pricing.tax.toStringAsFixed(2)),
        if (order.pricing.discount > 0)
          infoRow('Discount', '- ${order.pricing.discount.toStringAsFixed(2)}'),
        const Divider(color: Color(0xFFE0E0E0)),
        infoRow('Total', order.pricing.total.toStringAsFixed(2), isBold: true),
        const Divider(color: Color(0xFFE0E0E0)),
      ],
    );
  }
}

class CustomOrderStepper extends StatelessWidget {
  final int currentStep;
  final bool isCancelled;

  const CustomOrderStepper({
    super.key,
    required this.currentStep,
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    int visualStep = 0;
    if (currentStep >= 3) visualStep = 2; 
    else if (currentStep >= 2) visualStep = 1; 
    else visualStep = 0; 

    return SizedBox(
      width: 350, 
      height: 85, 
      child: Stack(
        children: [
          Positioned(
            left: 35, 
            right: 35, 
            top: 15, 
            child: Container(
              height: 2,
              color: isCancelled ? const Color(0xFFFF4B4B) : const Color(0xFFDDDDDD),
            ),
          ),
          Positioned(
            left: 35,
            top: 15,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double totalLineWidth = 280;
                double activeWidth = 0;

                if (visualStep == 1) activeWidth = totalLineWidth / 2;
                if (visualStep == 2) activeWidth = totalLineWidth;
                if (isCancelled) activeWidth = totalLineWidth; 

                return Container(
                  width: activeWidth,
                  height: 2,
                  color: isCancelled ? const Color(0xFFFF4B4B) : const Color(0xFFA2DC00),
                );
              },
            ),
          ),

          Positioned(
            left: 21,
            top: 0,
            child: _buildCircleNode(
                isActive: true, 
                isCancelled: false, 
                isCompleted: visualStep > 0 || isCancelled
            ),
          ),
          
          if (!isCancelled) ...[
            Positioned(
              left: 159, 
              top: 0.33,
              child: _buildCircleNode(
                  isActive: visualStep >= 1,
                  isCancelled: false,
                  isCompleted: visualStep > 1
              ),
            ),
            Positioned(
              left: 302, 
              top: 0.33,
              child: _buildCircleNode(
                  isActive: visualStep >= 2,
                  isCancelled: false,
                  isCompleted: visualStep == 2
              ),
            ),
          ],

          if (isCancelled)
            Positioned(
              left: 302, 
              top: 0.33,
              child: _buildCircleNode(
                  isActive: true,
                  isCancelled: true,
                  isCompleted: true
              ),
            ),

          Positioned(
            left: 0,
            top: 45.33,
            width: 80, 
            child: const Text(
              'Order\nAccepted',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2C2C2C),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.36,
              ),
            ),
          ),
          
          if (!isCancelled)
            Positioned(
              left: 135, 
              top: 45.33,
              width: 80,
              child: const Text(
                'Out for\nDelivery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.36,
                ),
              ),
            ),

          Positioned(
            left: 277, 
            top: 45.33,
            width: 80,
            child: Text(
              isCancelled ? 'Order\nCanceled' : 'Order\nDelivered',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2C2C2C),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleNode({
    required bool isActive,
    required bool isCancelled,
    required bool isCompleted,
  }) {
    Color circleColor = const Color(0xFFDDDDDD); 
    Color borderColor = Colors.white;

    if (isCancelled) {
      circleColor = const Color(0xFFFF4B4B);
    } else if (isActive) {
      circleColor = const Color(0xFFA2DC00); 
    }

    return Container(
      width: 32,
      height: 32,
      decoration: ShapeDecoration(
        color: circleColor,
        shape: const OvalBorder(),
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: ShapeDecoration(
            color: Colors.transparent, 
            shape: OvalBorder(
              side: BorderSide(
                width: 4,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: borderColor,
              ),
            ),
          ),
          child: isCancelled 
              ? const Center(child: Icon(Icons.close, size: 10, color: Colors.white))
              : (isActive || isCompleted 
                  ? const Center(child: Icon(Icons.check, size: 10, color: Colors.white))
                  : null),
        ),
      ),
    );
  }
}
