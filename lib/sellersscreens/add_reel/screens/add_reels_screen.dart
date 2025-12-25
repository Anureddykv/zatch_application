import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/sellersscreens/add_reel/controllers/add_reels_controller.dart';
import 'package:zatch_app/sellersscreens/add_reel/screens/upload_buy_bits_screen.dart';
import 'package:zatch_app/sellersscreens/sellerdashbord/SellerDashboardScreen.dart';

class Addreelspage extends StatefulWidget {
  const Addreelspage({super.key});

  @override
  State<Addreelspage> createState() => _AddreelspageState();
}

class _AddreelspageState extends State<Addreelspage> {
  // final tabCtrl = Get.put(DashboardTabController());

  final AddReelsController addReelsController = Get.put<AddReelsController>(
    AddReelsController(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/image102.png",
                    fit: BoxFit.fill,
                    height: 350,
                  ),
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const CircleAvatar(
                              backgroundColor: AppColors.contentColorWhite,
                              child: Padding(
                                padding: EdgeInsets.only(left: 12.0),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: AppColors.contentColorBlack,
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            "Buy Bits",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const Icon(
                            Icons.notifications_none,
                            size: 28,
                            color: AppColors.contentColorWhite,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                // height: 200,
                                // width: 300,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    // color: Colors.white.withOpacity(0.3),
                                    // width: 1.2,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsGeometry.all(10),
                                  child: Column(
                                    children: [
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Performance Summary",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          //  Obx(
                                          //   () => DropdownButtonHideUnderline(
                                          //     child: DropdownButton<String>(
                                          //       value:
                                          //           yourlivesscreenscontroller
                                          //               .selectedValue
                                          //               .value,
                                          //       dropdownColor: Colors.white,
                                          //       icon: const Icon(
                                          //         Icons
                                          //             .arrow_drop_down_outlined,
                                          //         color: Colors.white,
                                          //       ),
                                          //       style: const TextStyle(
                                          //         color: Colors.black,
                                          //         fontSize: 13,
                                          //         fontWeight: FontWeight.w500,
                                          //       ),
                                          //       selectedItemBuilder: (
                                          //         BuildContext context,
                                          //       ) {
                                          //         return [
                                          //           const Padding(
                                          //             padding: EdgeInsets.all(
                                          //               18.0,
                                          //             ),
                                          //             child: Text(
                                          //               "This Week",
                                          //               style: TextStyle(
                                          //                 color: Colors.white,
                                          //               ),
                                          //             ),
                                          //           ),
                                          //           const Padding(
                                          //             padding: EdgeInsets.all(
                                          //               18.0,
                                          //             ),
                                          //             child: Text(
                                          //               "Last 15 Days",
                                          //               style: TextStyle(
                                          //                 color: Colors.white,
                                          //               ),
                                          //             ),
                                          //           ),
                                          //           const Padding(
                                          //             padding: EdgeInsets.all(
                                          //               18.0,
                                          //             ),
                                          //             child: Text(
                                          //               "Last Month",
                                          //               style: TextStyle(
                                          //                 color: Colors.white,
                                          //               ),
                                          //             ),
                                          //           ),
                                          //         ];
                                          //       },
                                          //       items: const [
                                          //         DropdownMenuItem(
                                          //           value: "this_week",
                                          //           child: Text("This Week"),
                                          //         ),
                                          //         DropdownMenuItem(
                                          //           value: "last_15_days",
                                          //           child: Text("Last 15 Days"),
                                          //         ),
                                          //         DropdownMenuItem(
                                          //           value: "last_month",
                                          //           child: Text("Last Month"),
                                          //         ),
                                          //       ],
                                          //       onChanged: (value) {
                                          //         yourlivesscreenscontroller
                                          //             .selectedValue
                                          //             .value = value!;
                                          //         yourlivesscreenscontroller
                                          //             .getLiveSummaryData(
                                          //               value,
                                          //             );
                                          //         log(value);
                                          //       },
                                          //     ),
                                          //   ),
                                          // ),
                                          Row(
                                            children: [
                                              Text(
                                                "This Week",
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_drop_down_outlined,
                                                color:
                                                    AppColors.contentColorWhite,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      AppSizedBox.height10,
                                      Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(1),
                                          1: FlexColumnWidth(1),
                                          2: FlexColumnWidth(1),
                                        },
                                        children: [
                                          TableRow(
                                            children: [
                                              buildStatItem(
                                                icon: Icons.visibility,
                                                color: Color(0xFFCCF656),
                                                value: "2596",
                                                label: "views",
                                                percentText: "-8% this week",
                                              ),
                                              buildStatItem(
                                                icon: Icons.currency_rupee,
                                                color: Color(0xFFCCF656),
                                                value: "48000",
                                                label: "Revenue",
                                                percentText: "+18% this week",
                                              ),
                                              buildStatItem(
                                                icon: Icons.drag_indicator,
                                                color: Color(0xFFCCF656),
                                                value: "82",
                                                label: "Pending Orders",
                                                percentText: "+13% this week",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            AppSizedBox.height10,
                            GestureDetector(
                              onTap: () {
                                log("upload buy bits screen");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const UploadBuyBitsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                // height: 200,
                                // width: 300,
                                decoration: BoxDecoration(
                                  color: Color(0xFFCCF656).withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    // color: Colors.white.withOpacity(0.3),
                                    // width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsetsGeometry.only(
                                    left: 20,
                                    right: 20,
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: AppColors.contentColorWhite,
                                        size: 15,
                                      ),
                                      Text(
                                        "Add New Buy Bits",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // AppSizedBox.height10,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Your Buy Bits',
                        style: TextStyle(
                          color: Color(0xFF101727),
                          fontSize: 15.18,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TabBar(
                          controller: addReelsController.tabController,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorPadding: const EdgeInsets.all(4),
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey.shade900,
                          tabs: const [Tab(text: "Live"), Tab(text: "Inacive")],
                        ),
                      ),
                      //body
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFB),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 3),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.all(
                                    const Radius.circular(25),
                                  ),
                                  child: Stack(
                                    children: [
                                      Image.asset("assets/images/image_95.png"),
                                      Positioned(
                                        top: 20,
                                        right: 0,
                                        left: 0,
                                        child: Center(
                                          child: Image.asset(
                                            "assets/images/playicon.png",
                                            height: 50,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Summer Sale 2025',
                                          style: TextStyle(
                                            color: Color(0xFF101727),
                                            fontSize: 15.18,
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        AppSizedBox.height5,
                                        Text(
                                          'Summer Dress, Casual Shirts & Sandals Green Color for women in blue pantdbdcsd',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                            fontFamily: 'Inter',

                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        AppSizedBox.height5,
                                        SizedBox(
                                          width: 90,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 1,
                                              horizontal: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                204,
                                                246,
                                                86,
                                                1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.verified,
                                                  color: Colors.green,
                                                  size: 15,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Active',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color.fromRGBO(
                                                      77,
                                                      174,
                                                      66,
                                                      1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 8, top: 8.0),
                                  child: Icon(Icons.more_vert_outlined),
                                ),
                              ],
                            ),
                            AppSizedBox.height10,

                            Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1.5),
                              },
                              children: const [
                                TableRow(
                                  children: [
                                    Text(
                                      'Assosiated Product',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '3',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    SizedBox(height: 6),
                                    SizedBox(height: 6),
                                    SizedBox(height: 6),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Text(
                                      'Number of Zatches',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '32',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    SizedBox(height: 6),
                                    SizedBox(height: 6),
                                    SizedBox(height: 6),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Text(
                                      'Number of Orders',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '16',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    SizedBox(height: 6),
                                    SizedBox(height: 6),
                                    SizedBox(height: 6),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Text(
                                      'Created on ',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '12/12/2025',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            AppSizedBox.height10,
                            Divider(thickness: 0.5, color: Colors.grey[500]),
                            AppSizedBox.height10,
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      '1250',
                                      style: TextStyle(
                                        color: Color(0xFF101727),
                                        fontSize: 16,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '89%',
                                      style: TextStyle(
                                        color: Color(0xFF101727),
                                        fontSize: 16,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '₹ 23,500',
                                      style: TextStyle(
                                        color: Color(0xFF101727),
                                        fontSize: 16,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('Views'),
                                    Text('Engagement'),
                                    Text('Revenue'),
                                  ],
                                ),
                              ],
                            ),
                            AppSizedBox.height10,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
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
}
