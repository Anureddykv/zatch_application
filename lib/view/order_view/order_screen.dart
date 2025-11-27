import 'package:flutter/material.dart';
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

  /// ✅ Status text builder
  Widget _buildStatusText(
      String statusMessage, Color highlightColor, String highlightWord) {
    final parts = statusMessage.split(highlightWord);

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        children: [
          TextSpan(text: parts[0], style: const TextStyle(color: Colors.black)),
          TextSpan(
            text: highlightWord,
            style: TextStyle(color: highlightColor, fontWeight: FontWeight.w600),
          ),
          if (parts.length > 1)
            TextSpan(text: parts[1], style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required String qty,
    required String price,
    required String address,
    required String statusMessage,
    required Color bgColor,
    required Color highlightColor,
    required String highlightWord,
    required bool isCanceled,
    VoidCallback? onTap, // 👈 new parameter
  }) {
    final double priceVal = double.tryParse(price) ?? 0.0;
    final int qtyVal = int.tryParse(qty.split(" ").first) ?? 1;
    final double totalVal = priceVal * qtyVal;

    return GestureDetector(   // 👈 wrap with tap handler
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

                            // ✅ show qty × price only if not canceled
                            if (!isCanceled)
                              Text("₹$price   x   $qty",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500, fontSize: 13)),
                          ],
                        ),
                      ),

                      // ✅ total always
                      Text("₹${totalVal.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),

                // address
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
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

          // ✅ floating 3 dots on top-right of card
          Positioned(
            top: 2,
            right: 15,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Colors.black),
              onSelected: (val) {
                if (val == "details") {
                  // handle details
                } else if (val == "reorder") {
                  // handle reorder
                }
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
          // tabbar
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

          // views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Ongoing Orders
                ListView(
                  padding: const EdgeInsets.only(top: 8),
                  children: [
                    _buildOrderCard(
                      imageUrl: "https://i.pravatar.cc/150?img=3",
                      title: "Modern light clothes",
                      subtitle: "Dress modern",
                      qty: "4 PCS",
                      price: "212.99",
                      address:
                      "A-403 Mantri Celestia, Financial District, Nanakram Guda...",
                      statusMessage:
                      "Your order is Shipped Successfully from our end. Delivery Expected 9 August 2025",
                      bgColor: const Color(0xFFFBFFEF),
                      highlightColor: Colors.green,
                      highlightWord: "9 August 2025",
                      isCanceled: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TrackOrderScreen(
                              status: OrderStatus.inTransit, // ✅ pass correct enum
                            ),
                          ),
                        );
                      },
                    ),
                    _buildOrderCard(
                      imageUrl: "https://i.pravatar.cc/150?img=4",
                      title: "Modern light clothes",
                      subtitle: "Dress modern",
                      qty: "2 PCS",
                      price: "212.99",
                      address:
                      "A-403 Mantri Celestia, Financial District, Nanakram Guda...",
                      statusMessage: "Your order is Canceled by the seller.",
                      bgColor: const Color(0xFFFFEEE6),
                      highlightColor: Colors.red,
                      highlightWord: "Canceled",
                      isCanceled: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TrackOrderScreen(
                              status: OrderStatus.canceled, // ✅ pass correct enum
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Past Orders
                ListView(
                  padding: const EdgeInsets.only(top: 8),
                  children: [
                    // ✅ Delivered order
                    _buildOrderCard(
                      imageUrl: "https://i.pravatar.cc/150?img=5",
                      title: "Modern light clothes",
                      subtitle: "Dress modern",
                      qty: "4 PCS",
                      price: "212.99",
                      address:
                      "A-403 Mantri Celestia, Financial District, Nanakram Guda...",
                      statusMessage:
                      "Your order is Successfully Delivered on 9 August 2025",
                      bgColor: const Color(0xFFFBFFEF),
                      highlightColor: Colors.green,
                      highlightWord: "9 August 2025",
                      isCanceled: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TrackOrderScreen(
                              status: OrderStatus.delivered, // ✅ show delivered flow
                            ),
                          ),
                        );
                      },
                    ),

                    // ❌ Canceled order
                    _buildOrderCard(
                      imageUrl: "https://i.pravatar.cc/150?img=6",
                      title: "Modern light clothes",
                      subtitle: "Dress modern",
                      qty: "2 PCS",
                      price: "212.99",
                      address:
                      "A-403 Mantri Celestia, Financial District, Nanakram Guda...",
                      statusMessage: "Order Canceled on 9 August 2025",
                      bgColor: const Color(0xFFFFEEE6),
                      highlightColor: Colors.red,
                      highlightWord: "9 August 2025",
                      isCanceled: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TrackOrderScreen(
                              status: OrderStatus.canceled,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )

              ],
            ),
          ),
        ],
      ),
    );
  }
}
