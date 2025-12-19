import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zatch_app/model/order_model.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/order_view/track_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Orders",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // TabBar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              indicator: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Encode Sans',
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'Encode Sans',
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: "Ongoing"),
                Tab(text: "Past Orders"),
              ],
            ),
          ),

          // Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Tab 1: Ongoing Orders (Fetch active statuses)
                OrderListTab(
                  statuses: ["pending", "confirmed", "processing", "shipped"],
                ),

                // Tab 2: Past Orders (Fetch completed/cancelled)
                OrderListTab(
                  statuses: ["delivered", "cancelled"],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable Tab Widget that handles API Fetching & UI Mapping
// ---------------------------------------------------------------------------
class OrderListTab extends StatefulWidget {
  final List<String> statuses;

  const OrderListTab({super.key, required this.statuses});

  @override
  State<OrderListTab> createState() => _OrderListTabState();
}

class _OrderListTabState extends State<OrderListTab> {
  final ApiService _apiService = ApiService();
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = _fetchAllStatuses();
  }

  Future<List<OrderModel>> _fetchAllStatuses() async {
    List<OrderModel> allOrders = [];
    for (String status in widget.statuses) {
      try {
        final orders = await _apiService.getMyOrders(status: status);
        allOrders.addAll(orders);
      } catch (e) {
        debugPrint("Error fetching '$status' orders: $e");
      }
    }
    allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allOrders;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loadOrders();
        });
        await _ordersFuture;
      },
      color: const Color(0xFFA3DD00),
      child: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFA3DD00)));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text("Error: ${snapshot.error}", textAlign: TextAlign.center),
                    TextButton(onPressed: () => setState(() => _loadOrders()), child: const Text("Retry"))
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              // Use the new, styled card
              return _FigmaStyledOrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// A NEW, STYLED WIDGET TO MATCH THE FIGMA DESIGN
// ---------------------------------------------------------------------------
class _FigmaStyledOrderCard extends StatelessWidget {
  final OrderModel order;

  const _FigmaStyledOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final isCanceled = order.status.toLowerCase() == 'cancelled';
    final isDelivered = order.status.toLowerCase() == 'delivered';

    Color statusBgColor = const Color(0xFFFAFFEF); // Default for Ongoing
    Color statusHighlightColor = const Color(0xFF91C207); // Green

    if (isCanceled) {
      statusBgColor = const Color(0xFFFFEEE6); // Reddish
      statusHighlightColor = const Color(0xFFD30000); // Red
    }

    String dateStr = "Unknown Date";
    if (order.expectedDelivery != null) {
      dateStr = DateFormat('d MMMM y').format(order.expectedDelivery!);
    } else {
      dateStr = DateFormat('d MMMM y').format(order.createdAt);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackOrderScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Column(
          children: [
            // Top Section: Product Info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      firstItem?.image ?? "https://placehold.co/95x118",
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(width: 54, height: 54, color: Colors.grey[200]),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem?.name ?? 'Unknown Product',
                          style: const TextStyle(
                            color: Color(0xFF121111),
                            fontSize: 14,
                            fontFamily: 'Encode Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${order.orderId.substring(order.orderId.length - 8)}',
                          style: const TextStyle(
                            color: Color(0xFF787676),
                            fontSize: 10,
                            fontFamily: 'Encode Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${firstItem?.price.toStringAsFixed(2) ?? '0.00'} ₹',
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
                    '${order.pricing.total.toStringAsFixed(2)} ₹',
                    style: const TextStyle(
                      color: Color(0xFF292526),
                      fontSize: 14,
                      fontFamily: 'Encode Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Middle Section: Address
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFD3D3D3)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF2F2F2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Icon(Icons.home_outlined, size: 30, color: Colors.black54),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.deliveryAddress.label,
                            style: const TextStyle(
                              color: Color(0xFF2C2C2C),
                              fontSize: 12,
                              fontFamily: 'Encode Sans',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.deliveryAddress.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF8D8D8D),
                              fontSize: 12,
                              fontFamily: 'Encode Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Section: Status
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: ShapeDecoration(
                color: statusBgColor,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, color: Colors.black54, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Encode Sans',
                            height: 1.5),
                        children: [
                          if (isDelivered) ...[
                            const TextSpan(text: 'Your order is Successfully Delivered on '),
                            TextSpan(
                              text: dateStr,
                              style: TextStyle(
                                  color: statusHighlightColor, fontWeight: FontWeight.w700),
                            ),
                          ] else if (isCanceled) ...[
                            const TextSpan(text: 'Order Canceled on '),
                            TextSpan(
                              text: dateStr,
                              style: TextStyle(
                                  color: statusHighlightColor, fontWeight: FontWeight.w700),
                            ),
                          ] else if (order.status == 'shipped') ...[
                            const TextSpan(text: 'Your order is Shipped Successfully.\nDelivery Expected '),
                            TextSpan(
                              text: dateStr,
                              style: TextStyle(
                                  color: statusHighlightColor, fontWeight: FontWeight.w700),
                            ),
                          ] else ...[
                            const TextSpan(text: 'Your order has been placed.\nDelivery Expected '),
                            TextSpan(
                              text: dateStr,
                              style: TextStyle(
                                  color: statusHighlightColor, fontWeight: FontWeight.w700),
                            ),
                          ]
                        ],
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
