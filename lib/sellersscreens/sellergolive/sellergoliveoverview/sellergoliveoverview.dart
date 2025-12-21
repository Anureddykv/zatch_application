import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/model/live_details_response.dart';
import 'package:zatch_app/sellersscreens/sellerdashbord/SellerDashboardScreen.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergoliveoverview/sellergoliveoverviewcontroller.dart';

class Sellergoliveoverview extends StatefulWidget {
  const Sellergoliveoverview({super.key});

  @override
  State<Sellergoliveoverview> createState() => _SellergoliveoverviewState();
}

class _SellergoliveoverviewState extends State<Sellergoliveoverview> {
  final Sellergoliveoverviewcontroller goliveoverviewcontroller =
      Get.put<Sellergoliveoverviewcontroller>(Sellergoliveoverviewcontroller());
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var screenHeight = MediaQuery.sizeOf(context).height;
    var screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          child: AppBar(
            backgroundColor: const Color(0xffd5ff4d),
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const SellerDashboardScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: AppColors.contentColorWhite,
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.contentColorBlack,
                        size: 16,
                      ),
                    ),
                  ),
                  const Text(
                    'Live Overview',
                    style: TextStyle(
                      color: Color(0xFF101727),
                      fontSize: 15.18,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.notifications_none,
                    size: 28,
                    color: AppColors.contentColorBlack,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              // vertical: screenHeight * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Stack(
                  children: [
                    Obx(() {
                      if (goliveoverviewcontroller.isLoading.value) {
                        return ClipRRect(
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }
                      final data =
                          goliveoverviewcontroller.livedetailsresponse.value;

                      // Display fetched thumbnail if available, otherwise placeholder
                      final imageUrl =
                          goliveoverviewcontroller
                              .livedetailsresponse
                              .value
                              ?.sessionDetails
                              .thumbnail
                              .url;

                      return (imageUrl != null && imageUrl.isNotEmpty)
                          ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                  errorBuilder: (_, __, ___) {
                                    return Image.asset(
                                      'assets/images/thumnailimg.png',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 200,
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                right: 170,
                                top: 80,
                                child: Image.asset(
                                  'assets/images/playicon.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ],
                          )
                          : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/thumnailimg.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                ),
                              ),
                              Positioned(
                                right: 170,
                                top: 80,
                                child: Image.asset(
                                  'assets/images/playicon.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ],
                          );
                    }),

                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '24s',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoContainer(icon: Icons.visibility, text: '120'),
                          const SizedBox(width: 6),

                          _infoContainer(
                            icon: Icons.favorite_border,
                            text: '45',
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Obx(() {
                  final data =
                      goliveoverviewcontroller.livedetailsresponse.value;
                  if (data == null) return const SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.sessionDetails.title,
                        style: const TextStyle(
                          color: Color(0xFF101727),
                          fontSize: 15.18,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        data.sessionDetails.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF2C2C2C),
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.36,
                          wordSpacing: 1.6,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  );
                }),

                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TabBar(
                    controller: goliveoverviewcontroller.tabController,

                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(4),
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade900,
                    tabs: const [
                      Tab(text: "Overview"),
                      Tab(text: "Products"),
                      Tab(text: "Comments"),
                    ],
                  ),
                ),
                // SizedBox(height: screenHeight * 0.02),
                Expanded(
                  child: TabBarView(
                    controller: goliveoverviewcontroller.tabController,
                    children: [
                      OverViewTab(
                        stats:
                            goliveoverviewcontroller
                                .livedetailsresponse
                                .value!
                                .sessionDetails
                                .statsSummary,
                      ),
                      Obx(() {
                        final products =
                            goliveoverviewcontroller
                                .livedetailsresponse
                                .value
                                ?.sessionDetails
                                .products ??
                            [];

                        if (products.isEmpty) {
                          return const Center(child: Text("No products found"));
                        }

                        return ProductTile(products: products);
                      }),
                      Obx(() {
                        final comments =
                            goliveoverviewcontroller
                                .livedetailsresponse
                                .value
                                ?.sessionDetails
                                .comments ??
                            [];

                        if (comments.isEmpty) {
                          return const Center(child: Text("No products found"));
                        }
                        return CommentsTableview(comments: []);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommentsTableview extends StatelessWidget {
  final List<Comment> comments;

  CommentsTableview({super.key, required this.comments});

  final Sellergoliveoverviewcontroller goliveoverviewcontroller =
      Get.put<Sellergoliveoverviewcontroller>(Sellergoliveoverviewcontroller());
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: TextStyle(
            color: Color(0xFF101727),
            fontSize: 12.18,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSizedBox.height10,

        Flexible(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goliveoverviewcontroller.comments.length,
            itemBuilder: (context, index) {
              final comment = goliveoverviewcontroller.comments[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // user image (you can replace with real user image later)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/thumnailimg.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Comment Bubble
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 5,
                          bottom: 5,
                          right: 15,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F4),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(comment.text, softWrap: true),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        AppSizedBox.height10,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text('Add Comment'),
            AppSizedBox.height10,
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: goliveoverviewcontroller.commentcontroller,
                    maxLines: 4,
                    // minLines: 1,
                    decoration: InputDecoration(
                      hintText: "Enter Title",
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                      ),
                      fillColor: Color.fromRGBO(249, 250, 251, 1),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(232, 234, 237, 1),
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(232, 234, 237, 1),
                          width: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        AppSizedBox.height10,
        Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Text('Add Comment', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        AppSizedBox.height50,
      ],
    );
  }
}

// class OverViewTab extends StatelessWidget {
//   const OverViewTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var screenHeight = MediaQuery.sizeOf(context).height;

//     var screenWidth = MediaQuery.sizeOf(context).width;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: screenHeight * 0.02),

//         const Text(
//           'Summary',
//           style: TextStyle(
//             color: Color(0xFF101727),
//             fontSize: 14.18,
//             fontFamily: 'Plus Jakarta Sans',
//             fontWeight: FontWeight.bold,
//           ),
//         ),

//         SizedBox(height: screenHeight * 0.02),

//         // Row 1
//         Row(
//           children: [
//             Expanded(
//               child: _summaryCard(
//                 icon: Icon(Icons.remove_red_eye, size: 14, color: Colors.black),
//                 title: 'Views',
//                 value: '1.2K',
//                 change: '+18% this week',
//               ),
//             ),
//             SizedBox(width: screenWidth * 0.02),
//             Expanded(
//               child: _summaryCard(
//                 icon: Icon(Icons.remove_red_eye, size: 14, color: Colors.black),
//                 title: 'Revenue',
//                 value: '340',
//                 change: '+12% this week',
//               ),
//             ),
//             SizedBox(width: screenWidth * 0.02),
//             Expanded(
//               child: _summaryCard(
//                 icon: Icon(Icons.remove_red_eye, size: 14, color: Colors.black),
//                 title: 'Avg Engagement',
//                 value: '89',
//                 change: '+5% this week',
//               ),
//             ),
//           ],
//         ),

//         SizedBox(height: screenHeight * 0.02),

//         // Row 2
//         Row(
//           children: [
//             Expanded(
//               child: _summaryCard(
//                 icon: Icon(Icons.remove_red_eye, size: 14, color: Colors.black),
//                 title: 'Total Orders',
//                 value: '210',
//                 change: '+9% this week',
//               ),
//             ),
//             SizedBox(width: screenWidth * 0.02),
//             Expanded(
//               child: _summaryCard(
//                 icon: Icon(Icons.remove_red_eye, size: 14, color: Colors.black),
//                 title: 'Add to Cart',
//                 value: '1.5K',
//                 change: '+22% this week',
//               ),
//             ),
//             SizedBox(width: screenWidth * 0.02),
//             Expanded(
//               child: _summaryCard(
//                 icon: Icon(Icons.remove_red_eye, size: 14, color: Colors.black),
//                 title: 'No of Zatches',
//                 value: '76',
//                 change: '+3% this week',
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   /// Reusable Summary Card
//   Widget _summaryCard({
//     required String title,
//     required String value,
//     required String change,
//     required Icon icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8FAFB),
//         borderRadius: BorderRadius.circular(12.75),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x19000000),
//             blurRadius: 3,
//             offset: Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             radius: 14,
//             backgroundColor: Color(0xFFE3E8FF),
//             child: icon,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF101727),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             change,
//             style: const TextStyle(
//               fontSize: 10,
//               color: Colors.green,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
class OverViewTab extends StatelessWidget {
  final LiveStatsSummary stats;
  const OverViewTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.sizeOf(context).height;
    var screenWidth = MediaQuery.sizeOf(context).width;

    // List of summary cards data
    final List<_SummaryData> row1 = [
      _SummaryData(
        title: 'Views',
        value: stats.views.toString(),
        change: "+${stats.viewsChange}this week",
        icon: Icon(Icons.remove_red_eye, size: 14, color: Colors.black),
      ),
      _SummaryData(
        title: 'Revenue',
        value: stats.revenue.toString(),
        change: "+${stats.revenueChange}this week",
        icon: Icon(Icons.attach_money, size: 14, color: Colors.black),
      ),
      _SummaryData(
        title: 'Avg Engagement',
        value: stats.avgEngagement.toString(),
        change: "+${stats.engagementChange}this week",
        icon: Icon(Icons.bar_chart, size: 14, color: Colors.black),
      ),
    ];

    final List<_SummaryData> row2 = [
      _SummaryData(
        title: 'Total Orders',
        value: stats.totalOrders.toString(),
        change: "+${stats.ordersChange}this week",
        icon: Icon(Icons.shopping_bag, size: 14, color: Colors.black),
      ),
      _SummaryData(
        title: 'Add to Cart',
        value: stats.addToCarts.toString(),
        change: "+${stats.addToCartsChange} this week",

        icon: Icon(Icons.add_shopping_cart, size: 14, color: Colors.black),
      ),
      _SummaryData(
        title: 'No of Zatches',
        value: stats.zatches.toString(),
        change: "+${stats.zatchesChange} this week",
        icon: Icon(Icons.star, size: 14, color: Colors.black),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenHeight * 0.02),
        const Text(
          'Summary',
          style: TextStyle(
            color: Color(0xFF101727),
            fontSize: 14.18,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        _buildRow(row1, screenWidth),
        SizedBox(height: screenHeight * 0.02),
        _buildRow(row2, screenWidth),
      ],
    );
  }

  Widget _buildRow(List<_SummaryData> items, double screenWidth) {
    return Row(
      children: List.generate(items.length * 2 - 1, (index) {
        if (index.isEven) {
          int dataIndex = index ~/ 2;
          final data = items[dataIndex];
          return Expanded(
            child: _summaryCard(
              title: data.title,
              value: data.value,
              change: data.change,
              icon: data.icon,
            ),
          );
        } else {
          return SizedBox(width: screenWidth * 0.02);
        }
      }),
    );
  }

  /// Reusable Summary Card
  Widget _summaryCard({
    required String title,
    required String value,
    required String change,
    required Icon icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12.75),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFE3E8FF),
            child: icon,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101727),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            change,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryData {
  final String title;
  final String value;
  final String change;
  final Icon icon;

  _SummaryData({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
  });
}

// ignore: camel_case_types
class ProductTile extends StatelessWidget {
  final List<LiveProductDetails> products;
  const ProductTile({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSizedBox.height10,
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Associated Products',
              style: TextStyle(
                color: Color(0xFF101727),
                fontSize: 12.18,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(Icons.add, size: 15),
                SizedBox(width: 4),
                Text(
                  'Add Products',
                  style: TextStyle(
                    color: Color(0xFF101727),
                    fontSize: 11.18,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        AppSizedBox.height10,

        // List of products
        ...products.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(12.75),
                border: Border.all(color: Colors.transparent, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.75),
                    child:
                        product.images.isNotEmpty
                            ? Image.network(
                              product.images[0].url,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              'assets/images/thumnailimg.png',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                  ),
                  const SizedBox(width: 12),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.3,
                            fontFamily: 'Plus Jakarta Sans',
                            color: Color(0xFF101727),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category.isNotEmpty
                              ? product.category
                              : 'No Category',
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 10.3,
                            fontFamily: 'Plus Jakarta Sans',
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cost - \$${product.price}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 10.3,
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Stock - ${product.stock} Units',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 10.3,
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 2),
                                    Text('1'), // example views
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.star,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 2),
                                    Text('1'), // example rating
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _infoContainer({required IconData icon, required String text}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
