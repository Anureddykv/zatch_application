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
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              indicator: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
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

  // Helper to fetch multiple statuses and merge them
  Future<List<OrderModel>> _fetchAllStatuses() async {
    List<OrderModel> allOrders = [];
    for (String status in widget.statuses) {
      try {
        final orders = await _apiService.getMyOrders(status: status);
        allOrders.addAll(orders);
      } catch (e) {
        debugPrint("Error fetching $status orders: $e");
      }
    }
    // Sort by date (newest first)
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
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFA3DD00)));
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
            padding: const EdgeInsets.only(top: 8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCardFromModel(context, order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCardFromModel(BuildContext context, OrderModel order) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final isCanceled = order.status.toLowerCase() == 'cancelled';
    final isDelivered = order.status.toLowerCase() == 'delivered';

    // 1. Determine Colors and Text
    Color bgColor = const Color(0xFFFBFFEF); // Default Greenish
    Color highlightColor = Colors.green;
    String highlightWord = order.status.toUpperCase();
    String statusMessage = "Status: ${order.status}";

    // Format Date
    String dateStr = "Soon";
    if (order.expectedDelivery != null) {
      dateStr = DateFormat('d MMMM y').format(order.expectedDelivery!);
    } else {
      dateStr = DateFormat('d MMMM y').format(order.createdAt);
    }

    if (isCanceled) {
      bgColor = const Color(0xFFFFEEE6); // Reddish
      highlightColor = Colors.red;
      highlightWord = "Canceled";
      statusMessage = "Your order is Canceled.";
    } else if (isDelivered) {
      statusMessage = "Successfully Delivered on $dateStr";
      highlightWord = dateStr;
    } else if (order.status == 'shipped') {
      statusMessage = "Shipped. Delivery Expected $dateStr";
      highlightWord = dateStr;
    } else {
      // Pending / Confirmed
      statusMessage = "Order Placed. Expected by $dateStr";
      highlightWord = dateStr;
    }

    // 2. Map Status to Enum for TrackScreen
    OrderStatus trackStatus = OrderStatus.processing;
    if (order.status == 'shipped') trackStatus = OrderStatus.inTransit;
    if (order.status == 'delivered') trackStatus = OrderStatus.delivered;
    if (order.status == 'cancelled') trackStatus = OrderStatus.canceled;

    // 3. Build the UI
    return _buildOrderCard(
      imageUrl: firstItem?.image ?? "https://placehold.co/150",
      title: firstItem?.name ?? "Unknown Item",
      subtitle: "Order #${order.orderId.length > 8 ? order.orderId.substring(order.orderId.length - 8) : order.orderId}",
      qty: "${firstItem?.qty ?? 0} PCS",
      price: firstItem?.price.toString() ?? "0",
      totalPrice: order.pricing.total.toStringAsFixed(2),
      address: "Tap to view delivery details",
      statusMessage: statusMessage,
      bgColor: bgColor,
      highlightColor: highlightColor,
      highlightWord: highlightWord,
      isCanceled: isCanceled,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackOrderScreen(status: trackStatus),
          ),
        );
      },
    );
  }

  /// ✅ Existing Status text builder (Moved from main state to here or make static)
  Widget _buildStatusText(
      String statusMessage, Color highlightColor, String highlightWord) {
    if (!statusMessage.contains(highlightWord)) {
      return Text(statusMessage, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500));
    }

    final parts = statusMessage.split(highlightWord);

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        children: [
          TextSpan(text: parts[0], style: const TextStyle(color: Colors.black)),
          TextSpan(
            text: highlightWord,
            style:
            TextStyle(color: highlightColor, fontWeight: FontWeight.w600),
          ),
          if (parts.length > 1)
            TextSpan(
                text: parts[1], style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  /// ✅ Existing Order Card Builder
  Widget _buildOrderCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required String qty,
    required String price,
    required String totalPrice, // Changed from calculating inside
    required String address,
    required String statusMessage,
    required Color bgColor,
    required Color highlightColor,
    required String highlightWord,
    required bool isCanceled,
    VoidCallback? onTap,
  }) {

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // product row
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.error)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(subtitle,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),

                            if (!isCanceled)
                              Text("₹$price   x   $qty",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13)),
                          ],
                        ),
                      ),

                      Text("₹$totalPrice",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),

                // address
                Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.home, size: 22, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(address,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87)),
                      ),
                    ],
                  ),
                ),

                // status
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping,
                          size: 20, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildStatusText(
                              statusMessage, highlightColor, highlightWord)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // floating 3 dots
          Positioned(
            top: 2,
            right: 15,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Colors.black),
              onSelected: (val) {
                // Handle actions
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: "details", child: Text("View Details")),
                PopupMenuItem(value: "reorder", child: Text("Reorder")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
