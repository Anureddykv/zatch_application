import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/model/order_response_model.dart';
import 'package:zatch_app/sellersscreens/seller_order/controller/sellerOrderscreencontroller.dart';
import 'package:zatch_app/sellersscreens/seller_order/seller_order_details_screens/seller_order_details_screens.dart';

class Sellerorderscreen extends StatefulWidget {
  const Sellerorderscreen({super.key});

  @override
  State<Sellerorderscreen> createState() => _SellerorderscreenState();
}

class _SellerorderscreenState extends State<Sellerorderscreen> {
  final Sellerorderscreencontroller ordercontroller =
      Get.put<Sellerorderscreencontroller>(Sellerorderscreencontroller());

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
                              "Order Management",
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
                                    "Order Management ",
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
                                                  "Order Statistics",
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
                                                          ordercontroller
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
                                                      onChanged: (value) {
                                                        ordercontroller
                                                            .selectedValue
                                                            .value = value!;
                                                        ordercontroller
                                                            .getsellerOrderstatics(
                                                              value,
                                                            );
                                                        log(value);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Obx(() {
                                            if (ordercontroller
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
                                                ordercontroller
                                                    .orderresponse
                                                    .value;

                                            if (data == null) {
                                              return SizedBox.shrink();
                                            }
                                            final summary = data.summary;

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
                                                          Icons.currency_rupee,
                                                      color: Color(0xFFCCF656),
                                                      value: summary.revenue,
                                                      label: "Total Revenue",
                                                      percentText:
                                                          "${summary.revenueChange} ${ordercontroller.selectedValue.value}",
                                                    ),
                                                    buildStatItem(
                                                      icon: Icons.abc,
                                                      color: Color(0xFFCCF656),
                                                      value: "32",
                                                      label: "Total Orders",
                                                      percentText:
                                                          "+18% this week",
                                                    ),
                                                    buildStatItem(
                                                      icon:
                                                          Icons.drag_indicator,
                                                      color:
                                                          Colors.yellowAccent,
                                                      value:
                                                          "${summary.pendingOrders}",
                                                      label: "Pending Orders",
                                                      percentText:
                                                          "${summary.pendingChange} ${ordercontroller.selectedValue.value}",
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Orders',
                      style: TextStyle(
                        color: Color(0xFF101727),
                        fontSize: 15.18,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
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
                        children: [
                          const Icon(
                            Icons.search,
                            size: 20,
                            color: Color(0xFF626262),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: ordercontroller.searchCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Search ',
                                hintStyle: TextStyle(
                                  color: Color(0xFF626262),
                                  fontSize: 14,
                                  fontFamily: 'Encode Sans',
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Column(
                      children: [
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
                            controller: ordercontroller.tabController,
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
                              Tab(text: "In Progress"),
                              Tab(text: "Return"),
                              Tab(text: "Done"),
                            ],
                          ),
                        ),

                        Obx(() {
                          if (ordercontroller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final data = ordercontroller.orderresponse.value;

                          if (data == null) {
                            return const SizedBox.shrink();
                          }
                          if (ordercontroller.selectedTabIndex.value == 0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🔹 HEADER — shows ONLY ONCE
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              shape: BoxShape.rectangle,
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 7),
                                          const Text(
                                            'Ready To Shipped',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.filter_list_alt,
                                                color: AppColors.greycolor,
                                                size: 15,
                                              ),
                                              Text(
                                                'Filter',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          AppSizedBox.width10,
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.sort,
                                                color: AppColors.greycolor,
                                                size: 15,
                                              ),
                                              Text(
                                                'Sort',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: data.orders.inProgress.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 25),
                                  itemBuilder: (context, index) {
                                    final order = data.orders.inProgress[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 10.0,
                                        left: 10,
                                      ),
                                      child: orderstile(order: order),
                                    );
                                  },
                                ),
                              ],
                            );
                          } else if (ordercontroller.selectedTabIndex.value ==
                              1) {
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.orders.returns.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 25),
                              itemBuilder: (context, index) {
                                final order = data.orders.returns[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    right: 10.0,
                                    left: 10,
                                  ),
                                  child: orderstile(
                                    order: order,
                                    isProgress: false,
                                  ),
                                );
                              },
                            );
                          } else if (ordercontroller.selectedTabIndex.value ==
                              2) {
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.orders.completed.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 25),
                              itemBuilder: (context, index) {
                                final order = data.orders.completed[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    right: 10.0,
                                    left: 10,
                                  ),
                                  child: orderstile(
                                    order: order,
                                    isProgress: false,
                                  ),
                                );
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
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
}

// ignore: camel_case_types
class orderstile extends StatelessWidget {
  final OrderScreenOrder order;
  final bool isProgress;
  const orderstile({super.key, required this.order, this.isProgress = true});

  @override
  Widget build(BuildContext context) {
    final statusConfig = getOrderStatusConfig(order.statusLabel);
    final Sellerorderscreencontroller ordercontroller =
        Get.put<Sellerorderscreencontroller>(Sellerorderscreencontroller());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            log(order.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SellerOrderDetailsScreens(order: order),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "ID:${order.orderId}",
                              style: const TextStyle(
                                color: Color(0xFF101727),
                                fontSize: 12,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),

                            AppSizedBox.width10,
                            OrderStatusLabel(
                              text: statusConfig.label,
                              backgroundColor: statusConfig.bgColor,
                              textColor: statusConfig.textColor,
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            _handleOrderInprogressAction(context, order, value);
                          },
                          itemBuilder: (context) {
                            return order.actions.map((action) {
                              return PopupMenuItem<String>(
                                value: action,
                                child: Text(action),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    ),
                    AppSizedBox.height10,
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded),
                        AppSizedBox.width10,
                        Text(
                          ordercontroller.formatCreatedAt(order.createdAt),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    AppSizedBox.height10,
                    Divider(thickness: 0.5, color: Colors.grey[500]),
                    AppSizedBox.height10,
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1.5),
                      },
                      children: [
                        TableRow(
                          children: [
                            const Text(
                              'Order Type',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const Text(
                              '-',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              order.orderType,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const TableRow(
                          children: [
                            SizedBox(height: 6),
                            SizedBox(height: 6),
                            SizedBox(height: 6),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              'Delivery Type',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const Text(
                              '-',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              order.deliveryType,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const TableRow(
                          children: [
                            SizedBox(height: 6),
                            SizedBox(height: 6),
                            SizedBox(height: 6),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const Text(
                              '-',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              order.location,
                              style: const TextStyle(
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
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '${order.totalCost}',
                                    style: const TextStyle(
                                      color: Color(0xFF101727),
                                      fontSize: 16,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Cost'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '${order.totalQuantity}',
                                    style: const TextStyle(
                                      color: Color(0xFF101727),
                                      fontSize: 16,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('QTY'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    ordercontroller.formatDueDate(
                                      order.dueDate,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Due Date'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppSizedBox.height10,
                    isProgress
                        ? SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
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
                              "Take Action",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleOrderInprogressAction(
    BuildContext context,
    OrderScreenOrder live,
    String action,
  ) {
    switch (action) {
      case 'Confirm':
        // navigate to edit screen
        break;

      case 'Cancel':
        // show cancel confirmation
        break;
    }
  }
}

class OrderStatusLabel extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const OrderStatusLabel({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Sellerorderscreencontroller ordercontroller =
        Get.put<Sellerorderscreencontroller>(Sellerorderscreencontroller());
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class OrderStatusConfig {
  final String label;
  final Color bgColor;
  final Color textColor;

  OrderStatusConfig({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });
}

OrderStatusConfig getOrderStatusConfig(String status) {
  final normalizedStatus = status.toLowerCase().replaceAll(' ', '_');

  switch (normalizedStatus) {
    case 'ready_to_ship':
      return OrderStatusConfig(
        label: 'Ready to Ship',
        textColor: const Color.fromRGBO(77, 174, 66, 1),
        bgColor: const Color.fromRGBO(204, 246, 86, 1),
      );

    case 'delivered':
      return OrderStatusConfig(
        label: 'Delivered',
        textColor: const Color.fromRGBO(77, 174, 66, 1),
        bgColor: const Color.fromRGBO(204, 246, 86, 1),
      );

    case 'order_placed':
      return OrderStatusConfig(
        label: 'Order Placed',
        textColor: const Color.fromRGBO(255, 199, 115, 1),
        bgColor: const Color.fromRGBO(253, 244, 209, 1),
      );

    case 'return_processing':
      return OrderStatusConfig(
        label: 'Return Processing',
        textColor: const Color.fromRGBO(253, 233, 233, 1),
        bgColor: const Color.fromRGBO(253, 233, 233, 1),
      );

    case 'return_processed':
      return OrderStatusConfig(
        label: 'Return Processed',
        textColor: const Color.fromRGBO(253, 233, 233, 1),
        bgColor: const Color.fromRGBO(202, 241, 103, 1),
      );

    case 'shipped':
      return OrderStatusConfig(
        label: 'Shipped',
        textColor: const Color.fromRGBO(136, 162, 255, 1),
        bgColor: const Color.fromRGBO(189, 203, 255, 1),
      );

    case 'cancelled':
      return OrderStatusConfig(
        label: 'Cancelled',
        textColor: const Color.fromRGBO(211, 47, 47, 1),
        bgColor: const Color.fromRGBO(255, 205, 210, 1),
      );

    default:
      return OrderStatusConfig(
        label: status,
        textColor: Colors.black,
        bgColor: Colors.grey.shade200,
      );
  }
}
