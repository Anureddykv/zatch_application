import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/model/order_response_model.dart';
import 'package:zatch_app/sellersscreens/seller_order/controller/sellerOrderscreencontroller.dart';

class SellerOrderDetailsScreens extends StatefulWidget {
  final OrderScreenOrder order;
  const SellerOrderDetailsScreens({super.key, required this.order});

  @override
  State<SellerOrderDetailsScreens> createState() =>
      _SellerOrderDetailsScreensState();
}

class _SellerOrderDetailsScreensState extends State<SellerOrderDetailsScreens> {
  final Sellerorderscreencontroller ordercontroller =
      Get.put<Sellerorderscreencontroller>(Sellerorderscreencontroller());

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var screenHeight = MediaQuery.sizeOf(context).height;
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
                    onTap: () => Navigator.pop(context),
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
                    'Order Details',
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
      body: Stack(
        children: [
          Column(
            children: [
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 24.0,
                  ),
                  child: OrderDetailsStepper(
                    currentStep: ordercontroller.currentStep.value,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Obx(() {
                        if (ordercontroller.currentStep.value == 0) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: PackOrderDetails(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: _PackDeliveryinfo(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: _packPaymentDetails(),
                              ),
                            ],
                          );
                        } else if (ordercontroller.currentStep.value == 1) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: PackOrderDetails(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: _PackDeliveryinfo(),
                              ),
                            ],
                          );
                        } else if (ordercontroller.currentStep.value == 2) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: ShippingOrderProgress(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: PackOrderDetails(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: _PackDeliveryinfo(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: _packPaymentDetails(),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      }),
                      AppSizedBox.height100,
                      AppSizedBox.height100,
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 5,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Obx(() {
                        return ordercontroller.currentStep.value != 0
                            ? const SizedBox.shrink()
                            : const Text(
                              'Cancel order',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Plus Jakarta Sans',
                                color: Colors.red,
                              ),
                            );
                      }),
                      const SizedBox(height: 16),
                      Obx(() {
                        return ordercontroller.currentStep.value == 2
                            ? SizedBox.shrink()
                            : SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  // Navigator.pop(context);
                                  ordercontroller.goToPreviousStep();
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 50,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child:
                                // yourlivesscreenscontroller.currentStep.value ==
                                //         0
                                const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),

                                //     : const Text(
                                //       'Back',
                                //       style: TextStyle(
                                //         fontSize: 17,
                                //         fontWeight: FontWeight.bold,
                                //         color: Colors.black,
                                //       ),
                                //     ),
                              ),
                            );
                      }),
                    ],
                  ),
                ),
                Obx(() {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      right: 30,
                      left: 30,
                      bottom: 30,
                      top: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        // ordercontroller.currentStep.value = 1;
                        ordercontroller.goToNextStep(context, themeData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(163, 221, 0, 1),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        getActionButtonText(ordercontroller.currentStep.value),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getActionButtonText(int step) {
    switch (step) {
      case 0:
        return 'Ready to Ship';
      case 1:
        return 'Mark as Shipped';
      case 2:
        return 'Delivered';
      case 3:
        return 'Money Recieved';
      default:
        return 'Done';
    }
  }

  Widget _buildActionButtons() {
    ThemeData themeData = Theme.of(context);
    var screenHeight = MediaQuery.sizeOf(context).height;
    return Column(
      children: [
        // Add Product Button
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA2DC00),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Add Product',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10.50),
        // Back Button
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(width: 1, color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Back',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget PackOrderDetails() {
    ThemeData themeData = Theme.of(context);
    var screenHeight = MediaQuery.sizeOf(context).height;
    return Column(
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
              DropDownWidgets(
                alwaysOpen: false,
                items: [
                  DropDownItem(
                    label: 'Order Id',
                    value: '${widget.order.orderId}',
                    onTap: () async {},
                  ),
                  DropDownItem(
                    label: 'Order Date',
                    value: '${widget.order.createdAt}',
                    onTap: () async {},
                  ),
                  DropDownItem(
                    label: 'Address',
                    value: '${widget.order.location}',
                    onTap: () async {},
                  ),
                ],
                title: 'Order Details',
                column: Column(
                  children: [
                    Divider(thickness: 0.5, color: Colors.grey[300]),
                    Obx(() {
                      if (ordercontroller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data = widget.order.products;

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 25),
                        itemBuilder: (context, index) {
                          final order = data[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 10.0,
                              left: 10,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                      child: Image.network(
                                        order.productImage,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Image.asset(
                                            "assets/images/image_95.png",
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.productName,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: themeData
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      themeData
                                                          .colorScheme
                                                          .onSurface,
                                                ),
                                          ),
                                          AppSizedBox.height5,
                                          Text(
                                            'description',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                              fontFamily: 'Inter',

                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Quantity',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                                fontFamily: 'Inter',

                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text('-'),
                                            const SizedBox(width: 10),
                                            Text(
                                              '${order.quantity}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Price',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                                fontFamily: 'Inter',

                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text('-'),
                                            const SizedBox(width: 10),
                                            Text(
                                              '${order.price}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                                fontFamily: 'Inter',

                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                    Divider(thickness: 0.5, color: Colors.grey[300]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _packPaymentDetails() {
    ThemeData themeData = Theme.of(context);
    var screenHeight = MediaQuery.sizeOf(context).height;
    return Column(
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
              DropDownWidgets(
                column: Column(
                  children: [
                    paymentdetailsrow(
                      themeData: themeData,
                      widget: widget,
                      heading: 'Total Revenue',
                      value: widget.order.totalCost,
                    ),
                    SizedBox(height: 10),
                    paymentdetailsrow(
                      themeData: themeData,
                      widget: widget,
                      heading: 'Commission',
                      value: widget.order.totalCost,
                    ),
                    SizedBox(height: 10),
                    paymentdetailsrow(
                      themeData: themeData,
                      widget: widget,
                      heading: 'Shipping',
                      value: widget.order.totalCost,
                    ),
                    SizedBox(height: 10),
                    paymentdetailsrow(
                      themeData: themeData,
                      widget: widget,
                      heading: 'Tax',
                      value: widget.order.totalCost,
                    ),
                    SizedBox(height: 10),
                    paymentdetailsrow(
                      themeData: themeData,
                      widget: widget,
                      heading: 'Gst',
                      value: widget.order.totalCost,
                    ),
                    SizedBox(height: 10),
                    Divider(thickness: 0.5, color: Colors.grey[300]),
                    SizedBox(height: 10),
                    paymentdetailsrow(
                      themeData: themeData,
                      widget: widget,
                      heading: 'Payment',
                      value: widget.order.totalCost,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                items: [],
                title: 'Payment Details',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _PackDeliveryinfo() {
    return Column(
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
              DropDownWidgets(
                column: Column(children: []),
                items: [
                  DropDownItem(
                    label: 'Name',
                    value: widget.order.buyer.name,
                    onTap: () async {},
                  ),
                  DropDownItem(
                    label: 'Order Date',
                    value: '${widget.order.createdAt}',
                    onTap: () async {},
                  ),
                  DropDownItem(
                    label: 'Address',
                    value: '${widget.order.location}',
                    onTap: () async {},
                  ),
                ],
                title: 'Delivery Information',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget ShippingOrderProgress() {
    return Container(
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
          DropDownWidgets(
            column: Column(
              children: [
                OrderProgressSteps(
                  currentStep: ordercontroller.currentStep.value,
                ),
              ],
            ),
            items: [],
            title: 'Order Progress',
          ),
        ],
      ),
    );
  }
}

final Sellerorderscreencontroller ordercontroller =
    Get.put<Sellerorderscreencontroller>(Sellerorderscreencontroller());

void showMarkAsShippedBottomSheet(BuildContext context, ThemeData themeData) {
  final TextEditingController trackingController = TextEditingController();
  String? selectedCourier;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping Method',
                  style: themeData.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeData.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You can select your Shipping Method',
                  style: themeData.textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: themeData.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),

                /// Courier Method
                DropdownButtonFormField<String>(
                  value: selectedCourier,
                  decoration: InputDecoration(
                    labelText: 'Courier Method',
                    filled: true,
                    labelStyle: TextStyle(fontSize: 12),
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'FedEx', child: Text('FedEx')),
                    DropdownMenuItem(value: 'DHL', child: Text('DHL')),
                    DropdownMenuItem(
                      value: 'Blue Dart',
                      child: Text('Blue Dart'),
                    ),
                    DropdownMenuItem(
                      value: 'Delhivery',
                      child: Text('Delhivery'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCourier = value;
                    });
                  },
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: trackingController,
                  decoration: InputDecoration(
                    labelText: 'Tracking ID',
                    filled: true,
                    labelStyle: TextStyle(fontSize: 12),
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                /// Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigator.pop(context);
                      ordercontroller.goToPreviousStep();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black, width: 1),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child:
                    // yourlivesscreenscontroller.currentStep.value ==
                    //         0
                    const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(163, 221, 0, 1),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      if (trackingController.text.isEmpty ||
                          selectedCourier == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                          ),
                        );
                        return;
                      }
                      log('Current step: ${ordercontroller.currentStep.value}');

                      ordercontroller.currentStep.value++;
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Confirm',
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
          );
        },
      );
    },
  );
}

class paymentdetailsrow extends StatelessWidget {
  const paymentdetailsrow({
    super.key,
    required this.themeData,
    required this.widget,
    required this.heading,
    required this.value,
  });

  final ThemeData themeData;
  final SellerOrderDetailsScreens widget;
  final heading;
  final value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          heading,
          style: themeData.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.normal,
            color: themeData.colorScheme.onSurface,
          ),
        ),
        Text(
          '$value',
          style: themeData.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.normal,
            color: themeData.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class DropDownWidgets extends StatefulWidget {
  final String title;
  final List<DropDownItem> items;
  final Widget column;
  final bool alwaysOpen;

  const DropDownWidgets({
    super.key,
    required this.title,
    required this.items,
    this.alwaysOpen = false,
    required this.column,
  });

  @override
  State<DropDownWidgets> createState() => _DropDownWidgetsState();
}

class _DropDownWidgetsState extends State<DropDownWidgets> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();

    isExpanded = widget.alwaysOpen;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var screenHeight = MediaQuery.sizeOf(context).height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        GestureDetector(
          onTap:
              widget.alwaysOpen
                  ? null
                  : () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: themeData.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeData.colorScheme.onSurface,
                ),
              ),

              if (!widget.alwaysOpen)
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: themeData.colorScheme.onSurface,
                ),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.01),

        /// Content
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              Column(
                children:
                    widget.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Text(
                              item.label,
                              style: themeData.textTheme.labelSmall,
                            ),
                            const SizedBox(width: 10),
                            const Text('-'),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: item.onTap,
                                child: Text(
                                  item.value,
                                  overflow: TextOverflow.ellipsis,
                                  style: themeData.textTheme.labelSmall,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
              widget.column,
            ],
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class DropDownItem {
  final String label;
  final String value;
  final VoidCallback? onTap;

  DropDownItem({required this.label, required this.value, this.onTap});
}

class OrderDetailsStepper extends StatelessWidget {
  final int currentStep;
  const OrderDetailsStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final List<String> steps = [
      'Pack\nOrder',
      'Order\nShipped',
      'Shipping',
      'Money\nReceived',
    ];

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final bool isActive = currentStep >= index;
            final bool isCompleted = currentStep > index;
            // The line connecting the circles
            final Widget line = Expanded(
              child: Container(
                height: 2,
                color:
                    isCompleted
                        ? const Color(0xFFA2DC00)
                        : const Color(0xFFDDDDDD),
              ),
            );
            final Widget circle = Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    isActive
                        ? const Color(0xFFA2DC00)
                        : const Color(0xFFDDDDDD),
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? const Color(0xFFA2DC00)
                                    : const Color(0xFFD9D9D9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                        ),
              ),
            );
            if (index > 0) {
              return Expanded(child: Row(children: [line, circle]));
            }
            return circle;
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            return Text(
              steps[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF2C2C2C),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight:
                    currentStep == index ? FontWeight.w600 : FontWeight.w400,
                height: 1.36,
                wordSpacing: 1.6,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class OrderProgressSteps extends StatelessWidget {
  final int currentStep;
  OrderProgressSteps({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final List<String> steps = [
      'Order Accepted',
      'Shipped',
      'in Transit',
      'Out for Delivery',
      'Delivered',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final bool isActive = currentStep >= index;
        final bool isCompleted = currentStep > index;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                /// Circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? const Color(0xFFA2DC00)
                            : const Color(0xFFDDDDDD),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        isCompleted
                            ? Icon(
                              _getStepIcon(index),
                              color: Colors.white,
                              size: 15,
                            )
                            : Icon(
                              _getStepIcon(index),
                              color: Colors.white,
                              size: 15,
                            ),
                  ),
                ),

                if (index != steps.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color:
                        isCompleted
                            ? const Color(0xFFA2DC00)
                            : const Color(0xFFDDDDDD),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            /// RIGHT SIDE TEXT
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Step Title
                  Text(
                    orderdes[index]['title']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          currentStep == index
                              ? FontWeight.w600
                              : FontWeight.w400,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// Step Description
                  Text(
                    orderdes[index]['desc']!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7A7A7A),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  final List<Map<String, String>> orderdes = [
    {
      'title': 'Order Accepted',
      'desc': 'The order has been confirmed\n 2024-01-08 at 11.20',
    },
    {
      'title': 'Order Shipped',
      'desc': 'packege shipped \n 2024-01-08 at 11.20',
    },
    {'title': 'In Transit', 'desc': 'The package is on the way to you'},
    {
      'title': 'Out for Delivery',
      'desc': 'package to transit\n ETA-2024-01-08 at',
    },
    {'title': 'Delivered', 'desc': 'Order successfully delivered'},
  ];
  IconData _getStepIcon(int index) {
    switch (index) {
      case 0: // Order Accepted
        return Icons.check_circle_rounded;

      case 1: // Shipped
        return Icons.inventory_2_outlined;

      case 2: // In Transit
        return Icons.send_rounded;

      case 3: // Out for Delivery
        return Icons.local_shipping_outlined;

      case 4: // Delivered
        return Icons.home_rounded;

      default:
        return Icons.circle;
    }
  }
}
