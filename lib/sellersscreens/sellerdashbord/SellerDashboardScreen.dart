import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/sellersscreens/add_coupon/add_coupon.dart';
import 'package:zatch_app/sellersscreens/add_reel/screens/add_reels_screen.dart';
import 'package:zatch_app/sellersscreens/add_zatches/zatchesscreen.dart';
import 'package:zatch_app/sellersscreens/addproduct/add_product_screen.dart';
import 'package:zatch_app/sellersscreens/inventory/inventory_screen.dart';
import 'package:zatch_app/sellersscreens/seller_order/sellerorderscreen.dart';
import 'package:zatch_app/sellersscreens/seller_payment_screen.dart/seller_payment_screen.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergoliveoverview/sellergoliveoverview.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergolivescreens/seller_go_live_screen.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergolivescreens/seller_live_dashboard.dart';

// Main screen is now a StatefulWidget to manage the selected tab
class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  // State variable to keep track of the selected tab index
  int _selectedIndex = 1; // Start with 'Dashboard' selected (index 1)

  // List of the main screen widgets for each tab
  // NOTE: DashboardPage is now const because it doesn't have internal state.
  static final List<Widget> _screenOptions = <Widget>[
    const DashboardHome(), // Corresponds to index 1
    const Sellerorderscreen(), // Corresponds to index 2
    InventoryScreen(), // Corresponds to index 3
    const SellerPaymentScreen(), // Corresponds to index 4
  ];

  // Method to handle tap events on the BottomNavigationBar
  void _onItemTapped(int index) {
    // The "Back" button at index 0 is a special case
    if (index == 0) {
      // It will not change the selected screen, it just pops the current route.
      Navigator.of(context).pop();
      return;
    }
    // For all other tabs, update the state to show the correct screen
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body now dynamically changes based on the selected tab.
      body: IndexedStack(
        index: _selectedIndex - 1, // Adjusted index for the list
        children: _screenOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back), // 'Back' button
            label: 'Back',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payments'),
          // BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Zatch'),
          // BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Coupon'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFA2DC00),
        unselectedItemColor: const Color(0xFFC2C2C2),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        Widget page = const DashboardPage();
        // if (settings.name == '/golive') {
        //   page = const SellerLiveDashboard();
        // }
        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}
// --- BODY CONTENT WIDGETS FOR EACH TAB ---

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a CustomScrollView to combine a non-scrolling AppBar
    // with a scrolling body.
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, // Keeps the AppBar visible at the top
            expandedHeight: 230.0, // Total height of the header area
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false, // Removes the default back button
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(context), // The header content
            ),
          ),
          // The rest of the page content goes here and will be scrollable
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(29, 30, 29, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                // The rounded corners are now on the body container
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              // Use a Column for the main page content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatsAndLeadsCard(),
                  const SizedBox(height: 20),
                  const SetupProgressCard(
                    completedTasks: [
                      'Upload first product',
                      'Add product images (min 3)',
                    ],
                    allTasks: [
                      'Upload first product',
                      'Add product images (min 3)',
                      'Set auto-accept bargain %',
                      'Upload first reel',
                      'Verify bank details',
                      'Accept seller terms',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildQuickLinks(context),
                  const SizedBox(height: 20),
                  _buildOtherLinks(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the fixed header content that will not scroll
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const ShapeDecoration(
        gradient: RadialGradient(
          center: Alignment(0.18, 0.27),
          radius: 1.40,
          colors: [Color(0xFFCCF656), Color(0xFFA3DD00)],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top row: Greeting and Profile Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, Welcome 👋',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'Raju Nikil',
                      style: TextStyle(
                        color: Color(0xFF121111),
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Stack(
                      children: [
                        const Icon(Icons.notifications_none, size: 28),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFF4B4B),
                              shape: OvalBorder(
                                side: BorderSide(
                                  width: 1.5,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 43,
                      height: 42,
                      decoration: ShapeDecoration(
                        color: Colors.red,
                        image: const DecorationImage(
                          image: NetworkImage("https://placehold.co/43x42"),
                          fit: BoxFit.fill,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.80),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Info Cards Row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InfoCard(title: 'Total Products', value: '200'),
                ),
                SizedBox(width: 13),
                Expanded(
                  child: InfoCard(title: 'Total Buy Bits', value: '140(200)'),
                ),
                SizedBox(width: 13),
                Expanded(
                  child: InfoCard(title: 'Total Buy Bits', value: '70/100'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds the "Quick links" section
  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick links',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            QuickLinkItem(
              icon: Icons.sensors,
              label: 'Go Live',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SellerLiveDashboard(),
                  ),
                );
                // Navigator.of(context).pushNamed('/golive');
              },
            ),
            QuickLinkItem(
              icon: Icons.movie_creation_outlined,
              label: 'Add Reel',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Addreelspage()),
                );
              },
            ),
            QuickLinkItem(
              icon: Icons.add_box_outlined,
              label: 'Add Product',
              onTap: () {},
            ),
            QuickLinkItem(
              icon: Icons.inventory_2_outlined,
              label: 'Zatch',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Zatchesscreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // Builds the "Other Links" section
  Widget _buildOtherLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Other Links',
          style: TextStyle(
            color: Color(0xFF101727),
            fontSize: 15.18,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        ManageStoreCard(
          title: 'Edit Profile',
          icon: Icons.person_outline,
          ontap: () {},
        ),
        ManageStoreCard(
          title: 'Manage Products',
          icon: Icons.inventory_2_outlined,
          productCount: 13,
          ontap: () {},
        ),
        ManageStoreCard(
          title: 'Payments',
          icon: Icons.currency_rupee,
          ontap: () {},
        ),
        ManageStoreCard(
          title: 'Add Coupon ',
          icon: Icons.currency_rupee,
          ontap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddCouponDashboard(),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Placeholder widget for the 'Orders' tab content.
Widget buildStatItem({
  required IconData? icon,
  required Color color,
  required String value,
  required String label,
  required String percentText,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color,
          child: Icon(icon, color: Colors.black, size: 18),
        ),
        const SizedBox(height: 15),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          percentText,
          style: const TextStyle(color: Color(0xFFCCF656), fontSize: 10),
        ),
      ],
    ),
  );
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  const InfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 18,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class StatsAndLeadsCard extends StatelessWidget {
  const StatsAndLeadsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE8E8E8)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Text(
                      'This Week',
                      style: TextStyle(fontSize: 12, fontFamily: 'Encode Sans'),
                    ),
                    Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatItem(
                value: '60k',
                label: 'Product Views',
                barColor: Color(0xFFB3D3B5),
                progress: 0.8,
              ),
              StatItem(
                value: '300',
                label: 'Total Orders',
                barColor: Color(0xFFFFD484),
                progress: 0.6,
              ),
              StatItem(
                value: '30k ₹',
                label: 'Revenue',
                barColor: Color(0xFFFFA2A0),
                progress: 0.4,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            'Leads',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Leads Chart Placeholder',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color barColor;
  final double progress;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
    required this.barColor,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 8, // Set a fixed width for the bar container
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 48 * progress,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF696969),
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class QuickLinkItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickLinkItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: ShapeDecoration(
              color: const Color(0xFFC9F44E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Icon(icon, size: 36),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class ManageStoreCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int? productCount;
  final VoidCallback ontap;

  const ManageStoreCard({
    super.key,
    required this.title,
    required this.icon,
    this.productCount,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Card(
        elevation: 1,
        shadowColor: const Color(0x19000000),
        color: const Color(0xFFF9FAFB),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFF2F4F6)),
          borderRadius: BorderRadius.circular(12.75),
        ),
        margin: const EdgeInsets.only(bottom: 7),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF9C9),
                  borderRadius: BorderRadius.circular(8.75),
                ),
                child: Icon(icon, color: const Color(0xFF4A5565), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF101727),
                    fontSize: 13.12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (productCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA2DC00),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    productCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class SetupProgressCard extends StatelessWidget {
  final List<String> allTasks;
  final List<String> completedTasks;

  const SetupProgressCard({
    super.key,
    required this.allTasks,
    required this.completedTasks,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        allTasks.isNotEmpty ? completedTasks.length / allTasks.length : 0;
    String nextTask = allTasks.firstWhere(
      (task) => !completedTasks.contains(task),
      orElse: () => 'Setup Complete!',
    );

    return Card(
      elevation: 2,
      shadowColor: const Color(0x19000000),
      color: const Color(0xFFF8FAFB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.75)),
      child: Padding(
        padding: const EdgeInsets.all(17.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Your Seller Setup',
              style: TextStyle(
                color: Color(0xFF101727),
                fontSize: 15.31,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0x19030112),
                      color: const Color(0xFFA2DC00),
                      minHeight: 7,
                    ),
                  ),
                ),
                const SizedBox(width: 10.5),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFF495565),
                    fontSize: 12.30,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.5),
            const Text(
              'More complete profiles sell 3x faster',
              style: TextStyle(
                color: Color(0xFF697282),
                fontSize: 9.68,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 21),
            ...allTasks.map((task) {
              final bool isCompleted = completedTasks.contains(task);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.5),
                child: Row(
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          isCompleted
                              ? const Color(0xFFA2DC00)
                              : const Color(0xFFE5E7EB),
                      size: 21,
                    ),
                    const SizedBox(width: 10.5),
                    Text(
                      task,
                      style: TextStyle(
                        color: const Color(0xFF101727),
                        fontSize: 11.34,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Color(0xFFFA2B36),
                        fontSize: 12.30,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 10.5),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA2DC00),
                minimumSize: const Size(double.infinity, 40.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.75),
                ),
                elevation: 1,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nextTask,
                    style: const TextStyle(
                      color: Color(0xFF101727),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Color(0xFF101727),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 40.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.75),
                  side: const BorderSide(color: Colors.black),
                ),
                elevation: 0,
              ),
              child: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
