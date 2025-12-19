import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zatch_app/Widget/top_picks_this_week_widget.dart';
import 'package:zatch_app/model/order_model.dart';

class TrackOrderScreen extends StatelessWidget {
  final OrderModel order;

  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Determine the current step index based on the order status
    int currentStep = _getStepIndexFromStatus(order.status);
    bool isCanceled = order.status.toLowerCase() == 'cancelled';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Custom Stepper (Updated Design) ---
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

            // --- Action Buttons ---
            if (!isCanceled && order.status.toLowerCase() != 'delivered')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildActionButtons(),
              ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFFE0E0E0), thickness: 1),
            const SizedBox(height: 16),

            // --- Product Cards ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: order.items
                    .map((item) => _buildProductCard(item))
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // --- Delivery Location ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildDeliveryLocation(order.deliveryAddress),
            ),
            const SizedBox(height: 30),

            // --- Shipping Details ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildShippingDetails(order),
            ),
            const SizedBox(height: 30),

            // --- Shipping Information ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildShippingInfo(order),
            ),
            const SizedBox(height: 30),

            // --- Recommended Products ---
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

  // Helper Methods (Same as before)
  int _getStepIndexFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'confirmed':
        return 0; // Order Accepted
      case 'processing': // If you want 4 steps, keep this. If 3 steps, remove this case or map to 0/1
        return 1;
      case 'shipped':
      case 'out_for_delivery':
        return 2; // Out for Delivery
      case 'delivered':
      case 'completed':
        return 3; // Delivered
      case 'cancelled':
        return 0;
      default:
        return 0;
    }
  }

  AppBar _buildAppBar(BuildContext context) {
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
      title: Text(
        'Track Order'
        /*'Order #${order.orderId.substring(order.orderId.length - 8)}'*/,
        style: const TextStyle(
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
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Cancel Order', style: TextStyle(color: Colors.black)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
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

// ------------------------------------------------------------------
// REVISED CUSTOM STEPPER (MATCHING FIGMA EXACTLY)
// ------------------------------------------------------------------
class CustomOrderStepper extends StatelessWidget {
  final int currentStep;
  final bool isCancelled;

  // Note: Your Figma design has 3 steps visually:
  // 1. Order Accepted
  // 2. Out for Delivery
  // 3. Order Delivered
  // However, your logic had 4 steps. I've adapted it to 3 main visual steps.
  // If `currentStep` is 0 (Pending) -> Step 1 Active
  // If `currentStep` is 1 (Processing) -> Step 1 Active (or 2 depending on preference)
  // If `currentStep` is 2 (Shipped/Out) -> Step 2 Active
  // If `currentStep` is 3 (Delivered) -> Step 3 Active

  CustomOrderStepper({
    super.key,
    required this.currentStep,
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    // Map logic step (0-3) to visual step (0-2)
    int visualStep = 0;
    if (currentStep >= 3) visualStep = 2; // Delivered
    else if (currentStep >= 2) visualStep = 1; // Out for delivery
    else visualStep = 0; // Accepted / Processing

    return SizedBox(
      width: 350, // Matches Figma width
      height: 85, // Matches Figma height approx
      child: Stack(
        children: [
          // 1. The Horizontal Lines
          // Background Line (Grey)
          Positioned(
            left: 35, // Starts after first circle center
            right: 35, // Ends before last circle center
            top: 15, // Vertically centered to circles (32px / 2 approx)
            child: Container(
              height: 2,
              color: const Color(0xFFDDDDDD),
            ),
          ),
          // Active Line (Green or Red)
          Positioned(
            left: 35,
            top: 15,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Total width of line area (approx 350 - 70 = 280)
                double totalLineWidth = 280;
                double activeWidth = 0;

                if (visualStep == 1) activeWidth = totalLineWidth / 2;
                if (visualStep == 2) activeWidth = totalLineWidth;
                if (isCancelled) activeWidth = 0; // No line progress on cancel usually

                return Container(
                  width: activeWidth,
                  height: 2,
                  color: isCancelled ? Colors.red : const Color(0xFFA2DC00),
                );
              },
            ),
          ),

          // 2. The Circles (Nodes)
          // Node 1: Order Accepted
          Positioned(
            left: 21,
            top: 0,
            child: _buildCircleNode(
                isActive: true, // First step always active unless logic differs
                isCancelled: isCancelled,
                isCompleted: visualStep > 0
            ),
          ),
          // Node 2: Out for Delivery
          Positioned(
            left: 159, // Matches Figma
            top: 0.33,
            child: _buildCircleNode(
                isActive: visualStep >= 1,
                isCancelled: isCancelled && visualStep >= 1,
                isCompleted: visualStep > 1
            ),
          ),
          // Node 3: Order Delivered
          Positioned(
            left: 302, // Matches Figma
            top: 0.33,
            child: _buildCircleNode(
                isActive: visualStep >= 2,
                isCancelled: isCancelled && visualStep >= 2,
                isCompleted: visualStep == 2
            ),
          ),

          // 3. The Text Labels
          Positioned(
            left: 0,
            top: 45.33,
            width: 80, // Constrain width for centering
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
          Positioned(
            left: 135, // Approx center for 159
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
            left: 277, // Approx center for 302
            top: 45.33,
            width: 80,
            child: const Text(
              'Order\nDelivered',
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
        ],
      ),
    );
  }

  Widget _buildCircleNode({
    required bool isActive,
    required bool isCancelled,
    required bool isCompleted,
  }) {
    // Colors from Figma
    Color circleColor = const Color(0xFFDDDDDD); // Default Grey
    Color borderColor = Colors.white;

    if (isCancelled && isActive) {
      circleColor = Colors.red;
    } else if (isActive) {
      circleColor = const Color(0xFFA2DC00); // Green
    }

    // Figma Design uses a specific "Stroke Align Center" approach which implies
    // the white border cuts into the circle or surrounds it.
    // The provided code used: width: 31.87, then inner circles.
    // Here is a clean implementation of that look:

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
            color: Colors.transparent, // Inner part
            shape: OvalBorder(
              side: BorderSide(
                width: 4,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: borderColor,
              ),
            ),
          ),
          // Checkmark logic
          child: (isActive || isCompleted) && !isCancelled
              ? const Center(
              child: Icon(Icons.check, size: 10, color: Colors.white))
              : (isCancelled
              ? const Center(
              child: Icon(Icons.close, size: 10, color: Colors.white))
              : null),
        ),
      ),
    );
  }
}
