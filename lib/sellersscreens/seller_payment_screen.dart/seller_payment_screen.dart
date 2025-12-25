import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/sellersscreens/sellerdashbord/SellerDashboardScreen.dart';

class SellerPaymentScreen extends StatefulWidget {
  const SellerPaymentScreen({super.key});

  @override
  State<SellerPaymentScreen> createState() => _SellerPaymentScreenState();
}

class _SellerPaymentScreenState extends State<SellerPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
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
                              "Payment",
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
                            top: 40,
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
                                      backgroundColor:
                                          AppColors.contentColorWhite,
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
                                    "Order Management ",
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
                            top: 90,
                            left: 0,
                            right: 0,
                            child: ClipRRect(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Column(
                                  children: [
                                    BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 12,
                                        sigmaY: 12,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            // height: 200,
                                            // width: 300,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                // color: Colors.white.withOpacity(0.3),
                                                // width: 1.2,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsGeometry.all(
                                                10,
                                              ),
                                              child: Column(
                                                children: [
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Revenue Summary",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "This Week",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .white70,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .arrow_drop_down_outlined,
                                                            color:
                                                                AppColors
                                                                    .contentColorWhite,
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
                                                            icon:
                                                                Icons
                                                                    .currency_rupee,
                                                            color: Color(
                                                              0xFFCCF656,
                                                            ),
                                                            value: "₹ 48,000",
                                                            label:
                                                                "Total Revenue",
                                                            percentText:
                                                                "-8% this week",
                                                          ),
                                                          buildStatItem(
                                                            icon:
                                                                Icons
                                                                    .currency_rupee_sharp,
                                                            color: Color(
                                                              0xFFCCF656,
                                                            ),
                                                            value: "₹ 44000",
                                                            label:
                                                                "Net Revenue",
                                                            percentText:
                                                                "+18% this week",
                                                          ),
                                                          buildStatItem(
                                                            icon:
                                                                Icons
                                                                    .drag_indicator,
                                                            color:
                                                                Colors
                                                                    .yellowAccent,
                                                            value: "₹ 24000",
                                                            label: "Pending",
                                                            percentText: "",
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppSizedBox.height5,
                                    Container(
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
                                      child: const Padding(
                                        padding: EdgeInsetsGeometry.only(
                                          left: 20,
                                          right: 20,
                                          top: 10,
                                          bottom: 10,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Last Payment",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_month,
                                                  color:
                                                      AppColors
                                                          .contentColorWhite,
                                                ),
                                                Text(
                                                  "2024-01-15",
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity, // now it will take full width
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      color: Color.fromRGBO(204, 246, 86, 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming bank or UPI details',
                          style: TextStyle(
                            color: Color(0xFF101727),
                            fontSize: 15.31,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSizedBox.height10,
                        Text(
                          'Ensure your payment details are up to date for smooth payment',
                          style: TextStyle(
                            color: Color(0xFF101727),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        AppSizedBox.height20,
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                color: Colors.black,
                                width: 0.1,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 50,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Update now",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
