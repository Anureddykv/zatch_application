import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/sellersscreens/add_zatches/controller/addzatchcontroller.dart';
import 'package:zatch_app/sellersscreens/add_zatches/zatch_details_screen.dart';
import 'package:zatch_app/sellersscreens/sellerdashbord/SellerDashboardScreen.dart';

class Zatchesscreen extends StatefulWidget {
  const Zatchesscreen({super.key});

  @override
  State<Zatchesscreen> createState() => _ZatchesscreenState();
}

class _ZatchesscreenState extends State<Zatchesscreen> {
  final Addzatchcontroller controller = Get.put<Addzatchcontroller>(
    Addzatchcontroller(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
            floating: false,
            automaticallyImplyLeading: false,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final collapsedHeight =
                    kToolbarHeight + MediaQuery.of(context).padding.top;
                final isCollapsed =
                    constraints.biggest.height <= collapsedHeight;

                return Container(
                  color: isCollapsed ? const Color(0xffd5ff4d) : Colors.white,
                  child: FlexibleSpaceBar(
                    title:
                        isCollapsed
                            ? const Text(
                              "Zatches",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            )
                            : const SizedBox.shrink(),
                    centerTitle: true,
                    background: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Image.asset(
                              "assets/images/image102.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 30,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: const CircleAvatar(
                                      radius: 15,
                                      backgroundColor:
                                          AppColors.contentColorWhite,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 5.0),
                                        child: Icon(
                                          Icons.arrow_back_ios,
                                          size: 15,
                                          color: AppColors.contentColorBlack,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    "Zatches",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const Icon(
                                    Icons.notifications_none,
                                    size: 22,
                                    color: AppColors.contentColorWhite,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 90,
                            left: 0,
                            right: 0,
                            child: ClipRRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 12,
                                  sigmaY: 12,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsGeometry.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 15.0,
                                              right: 15,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              // mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  "Bargain Performance Report",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),

                                                Obx(
                                                  () => DropdownButtonHideUnderline(
                                                    child: DropdownButton<
                                                      String
                                                    >(
                                                      value:
                                                          controller
                                                              .selectedValue
                                                              .value,
                                                      dropdownColor:
                                                          Colors.white,
                                                      icon: const Icon(
                                                        Icons
                                                            .arrow_drop_down_outlined,
                                                        color: Colors.white,
                                                      ),
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      selectedItemBuilder: (
                                                        BuildContext context,
                                                      ) {
                                                        return [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  18.0,
                                                                ),
                                                            child: Text(
                                                              "This Week",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  18.0,
                                                                ),
                                                            child: Text(
                                                              "Last 15 Days",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  18.0,
                                                                ),
                                                            child: Text(
                                                              "Last Month",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ];
                                                      },
                                                      items: const [
                                                        DropdownMenuItem(
                                                          value: "this_week",
                                                          child: Text(
                                                            "This Week",
                                                          ),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: "last_15_days",
                                                          child: Text(
                                                            "Last 15 Days",
                                                          ),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: "last_month",
                                                          child: Text(
                                                            "Last Month",
                                                          ),
                                                        ),
                                                      ],
                                                      onChanged: (value) {},
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Obx(() {
                                          //   if (ordercontroller
                                          //       .isLoading
                                          //       .value) {
                                          //     return const SizedBox(
                                          //       height: 100,
                                          //       child: Center(
                                          //         child:
                                          //             CircularProgressIndicator(),
                                          //       ),
                                          //     );
                                          //   }
                                          //   final data =
                                          //       ordercontroller
                                          //           .orderresponse
                                          //           .value;

                                          //   if (data == null) {
                                          //     return SizedBox.shrink();
                                          //   }
                                          //   final summary = data.summary;

                                          //   return Table(
                                          //     columnWidths: const {
                                          //       0: FlexColumnWidth(1),
                                          //       1: FlexColumnWidth(1),
                                          //       2: FlexColumnWidth(1),
                                          //     },
                                          //     children: [
                                          //       TableRow(
                                          //         children: [
                                          //           buildStatItem(
                                          //             icon:
                                          //                 Icons.currency_rupee,
                                          //             color: Color(0xFFCCF656),
                                          //             value: summary.revenue,
                                          //             label: "Total Revenue",
                                          //             percentText:
                                          //                 "${summary.revenueChange} ${ordercontroller.selectedValue.value}",
                                          //           ),
                                          //           buildStatItem(
                                          //             icon: Icons.abc,
                                          //             color: Color(0xFFCCF656),
                                          //             value: "32",
                                          //             label: "Total Orders",
                                          //             percentText:
                                          //                 "+18% this week",
                                          //           ),
                                          //           buildStatItem(
                                          //             icon:
                                          //                 Icons.drag_indicator,
                                          //             color:
                                          //                 Colors.yellowAccent,
                                          //             value:
                                          //                 "${summary.pendingOrders}",
                                          //             label: "Pending Orders",
                                          //             percentText:
                                          //                 "${summary.pendingChange} ${ordercontroller.selectedValue.value}",
                                          //           ),
                                          //         ],
                                          //       ),
                                          //     ],
                                          //   );
                                          // }),
                                          // AppSizedBox.height10,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    AppSizedBox.height10,
                    const Text(
                      'Zatches',
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
                        controller: controller.tabController,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.all(4),
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey.shade900,
                        tabs: const [Tab(text: "Active"), Tab(text: "History")],
                      ),
                    ),
                    //body
                    Text(
                      'zatches will expired in two bussiness days',
                      style: TextStyle(fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ZatchDetailsScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
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
                                        Image.asset(
                                          "assets/images/image_95.png",
                                          height: 70,
                                          width: 70,
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
                                              fontSize: 14,
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          AppSizedBox.height5,
                                          Text(
                                            'Summer Dress',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 10,
                                              fontFamily: 'Inter',

                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          AppSizedBox.height5,
                                          SizedBox(
                                            width: 90,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                      fontWeight:
                                                          FontWeight.w700,
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
                                        'Original Price',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
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
                                        'Zatch Request',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
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
                                        'Quantity',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
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
                                        'Sub total',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '-',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '1000',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              AppSizedBox.height20,
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        // Reject action
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.black,
                                      ),
                                      label: const Text(
                                        "Reject",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        // Counter action
                                      },
                                      icon: const Icon(
                                        Icons.chat_bubble_outline,
                                        color: Colors.black,
                                      ),
                                      label: const Text(
                                        "Counter",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFFA3DD00),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AppSizedBox.height10,
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  right: 10,
                                  left: 10,
                                  bottom: 30,
                                  top: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {} catch (e) {}
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(
                                      163,
                                      221,
                                      0,
                                      1,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 50,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text(
                                    'Approve',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
