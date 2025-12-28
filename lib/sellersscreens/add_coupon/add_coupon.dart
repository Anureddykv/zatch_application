import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/sellersscreens/add_coupon/controller/add_coupon_controller.dart';
import 'package:zatch_app/sellersscreens/add_coupon/create_new_coupon_screen.dart';
import 'package:zatch_app/sellersscreens/sellerdashbord/SellerDashboardScreen.dart';

class AddCouponDashboard extends StatefulWidget {
  const AddCouponDashboard({super.key});

  @override
  State<AddCouponDashboard> createState() => _AddCouponDashboardState();
}

class _AddCouponDashboardState extends State<AddCouponDashboard> {
  final AddCouponController controller = Get.put<AddCouponController>(
    AddCouponController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 325,
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
                              "Create Coupon Codes",
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
                                    "Create Coupon Codes",
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
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                                      "Performance Summary",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                          selectedItemBuilder: (
                                                            BuildContext
                                                            context,
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
                                                              value:
                                                                  "this_week",
                                                              child: Text(
                                                                "This Week",
                                                              ),
                                                            ),
                                                            DropdownMenuItem(
                                                              value:
                                                                  "last_15_days",
                                                              child: Text(
                                                                "Last 15 Days",
                                                              ),
                                                            ),
                                                            DropdownMenuItem(
                                                              value:
                                                                  "last_month",
                                                              child: Text(
                                                                "Last Month",
                                                              ),
                                                            ),
                                                          ],
                                                          onChanged: (value) {
                                                            controller
                                                                .selectedValue
                                                                .value = value!;
                                                            controller
                                                                .getcoupondashboard(
                                                                  value,
                                                                );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Obx(() {
                                                if (controller
                                                    .isLoading
                                                    .value) {
                                                  return const SizedBox(
                                                    height: 100,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  );
                                                }
                                                final data =
                                                    controller
                                                        .coupondashboardresponse
                                                        .value;

                                                if (data == null) {
                                                  return SizedBox.shrink();
                                                }
                                                final summary =
                                                    data.couponPerformanceSummary;

                                                return Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(1),
                                                    1: FlexColumnWidth(1),
                                                    2: FlexColumnWidth(1),
                                                  },
                                                  children: [
                                                    TableRow(
                                                      children: [
                                                        buildStatItem(
                                                          icon:
                                                              Icons
                                                                  .currency_rupee,
                                                          color: Color(
                                                            0xFFCCF656,
                                                          ),
                                                          value:
                                                              '${summary.orders}',
                                                          label: "Order",
                                                          percentText:
                                                              "${summary.ordersChange} ${controller.selectedValue.value}",
                                                        ),
                                                        buildStatItem(
                                                          icon: Icons.abc,
                                                          color: Color(
                                                            0xFFCCF656,
                                                          ),
                                                          value:
                                                              " ₹ ${summary.gmv}",
                                                          label: "GMV",
                                                          percentText:
                                                              "${summary.gmvChange} ${controller.selectedValue.value}",
                                                        ),
                                                        buildStatItem(
                                                          icon:
                                                              Icons
                                                                  .drag_indicator,
                                                          color:
                                                              Colors
                                                                  .yellowAccent,
                                                          value:
                                                              "${summary.views}",
                                                          label:
                                                              "Pending Orders",
                                                          percentText:
                                                              "${summary.viewsChange} ${controller.selectedValue.value}",
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              }),
                                              AppSizedBox.height10,
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          log("create coupon  screen");
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const CreateNewCouponScreen(),
                                            ),
                                          );
                                          // Navigator.of(context).pushNamed('/child1');
                                          // Navigator.of(context, rootNavigator: true).push(
                                          //   MaterialPageRoute(
                                          //     builder: (_) => const UploadBuyBitsScreen(),
                                          //   ),
                                          // );
                                        },
                                        child: Container(
                                          // height: 200,
                                          // width: 300,
                                          decoration: BoxDecoration(
                                            color: Color(
                                              0xFFCCF656,
                                            ).withOpacity(0.4),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              // color: Colors.white.withOpacity(0.3),
                                              // width: 1.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add,
                                                  color:
                                                      AppColors
                                                          .contentColorWhite,
                                                  size: 15,
                                                ),
                                                Text(
                                                  "Create New Coupon Code",
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
                                    ],
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
                      'Offers(2)',
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
                        tabs: const [Tab(text: "Active"), Tab(text: "Expired")],
                      ),
                    ),

                    //body
                    GestureDetector(
                      onTap: () {},
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
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text(
                                                'Summer Sale 2025',
                                                style: TextStyle(
                                                  color: Color(0xFF101727),
                                                  fontSize: 14,
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 10),
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
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
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

                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(1),
                                    2: FlexColumnWidth(1.5),
                                  },
                                  children: const [
                                    TableRow(
                                      children: [
                                        Text(
                                          'Offer Percentage',
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
                                          '30%',
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
                                          'Minimum Spend',
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
                                          '300₹',
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
                                          'Max Discount',
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
                                          '300₹',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

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
                                        '47',
                                        style: TextStyle(
                                          color: Color(0xFF101727),
                                          fontSize: 16,
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '24',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text('Orders'),
                                      Text('Products'),
                                      Text('Total Revenue'),
                                    ],
                                  ),
                                ],
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
