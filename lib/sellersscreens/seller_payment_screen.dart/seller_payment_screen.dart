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
                                    "Payment",
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
                PaymentTypeContent(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class Paymenttypeselector extends StatefulWidget {
  final ValueChanged<String>? onTypeChanged;
  const Paymenttypeselector({super.key, this.onTypeChanged});

  @override
  State<Paymenttypeselector> createState() => _PaymenttypeselectorState();
}

class _PaymenttypeselectorState extends State<Paymenttypeselector> {
  String selectedTrip = 'Due';

  @override
  Widget build(BuildContext context) {
    final tripTypes = ['Due', 'Done', 'Adjustment'];

    return Column(
      children: [
        // Outer grey background container
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200], // full background grey
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  tripTypes.map((tripType) {
                    final bool isSelected = selectedTrip == tripType;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTrip = tripType;
                        });
                        widget.onTypeChanged?.call(selectedTrip);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 25,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Text(
                          tripType,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),

        // const SizedBox(height: 20),

        // Optional: Show card based on selection
        // if (selectedTrip == 'Due') _duepaymentcard(),
        // if (selectedTrip == 'Done') _donepaymentcard(),
        // if (selectedTrip == 'Adjustment') _adjustmentpaymentcard(),
      ],
    );
  }
}

class PaymentTypeContent extends StatefulWidget {
  const PaymentTypeContent({super.key});

  @override
  State<PaymentTypeContent> createState() => _PaymentTypeContentState();
}

class _PaymentTypeContentState extends State<PaymentTypeContent> {
  String selectedType = 'Due';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Paymenttypeselector(
          onTypeChanged: (type) {
            setState(() {
              selectedType = type;
            });
          },
        ),

        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 17.0, right: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Receivables',
                style: TextStyle(
                  color: Color(0xFF101727),
                  fontSize: 15.31,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.filter_list_alt,
                    color: AppColors.greycolor,
                    size: 15,
                  ),
                  Text(
                    'Filter',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (selectedType == 'Due')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _duepaymentcard(),
          ),
        if (selectedType == 'Done')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _donepaymentcard(),
          ),
        if (selectedType == 'Adjustment')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _adjustmentpaymentcard(),
          ),
      ],
    );
  }
}

Widget _duepaymentcard() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 3),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Payment ID - 12344585',
                      style: TextStyle(
                        color: Color(0xFF101727),
                        fontSize: 16.18,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSizedBox.width10,
                    AppSizedBox.width10,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 243, 199, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color.fromRGBO(255, 142, 3, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Icon(Icons.more_vert, size: 15, color: Colors.black),
              ],
            ),
            AppSizedBox.height5,
            Text(
              'Order ID - 1231233',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.normal,
              ),
            ),
            AppSizedBox.height10,
            Row(
              children: [
                Icon(Icons.calendar_month_rounded),
                AppSizedBox.width5,
                Text(
                  'Due date -',
                  style: TextStyle(
                    color: Color(0xFF101727),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSizedBox.width10,
                Text(
                  '12 Oct -25 oct,2025',
                  style: TextStyle(
                    color: Color(0xFF101727),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            AppSizedBox.height10,

            Divider(thickness: 0.5, color: Colors.grey[500]),
            AppSizedBox.height10,
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '₹ 13500',
                      style: TextStyle(
                        color: Color(0xFF101727),
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹ 3500',
                      style: TextStyle(
                        color: Color(0xFF101727),
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹ 10500',
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Gross', style: TextStyle(color: Colors.grey)),
                    Text('Fee', style: TextStyle(color: Colors.grey)),
                    Text('Total', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            AppSizedBox.height10,
          ],
        ),
      ),
    ],
  );
}

Widget _donepaymentcard() => Column(
  children: [
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 3),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Payment ID - 12344585',
                    style: TextStyle(
                      color: Color(0xFF101727),
                      fontSize: 16.18,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSizedBox.width10,
                  AppSizedBox.width10,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(204, 246, 86, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Paid',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color.fromRGBO(77, 174, 66, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Icon(Icons.more_vert, size: 15, color: Colors.black),
            ],
          ),
          AppSizedBox.height5,
          Text(
            'Order ID - 1231233',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.normal,
            ),
          ),
          AppSizedBox.height10,
          Row(
            children: [
              Icon(Icons.calendar_month_rounded),
              AppSizedBox.width5,
              Text(
                'Due date -',
                style: TextStyle(
                  color: Color(0xFF101727),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSizedBox.width10,
              Text(
                '12 Oct -25 oct,2025',
                style: TextStyle(
                  color: Color(0xFF101727),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSizedBox.height10,
          AppSizedBox.height5,
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: [
                  const Text(
                    'Gross Revenue',
                    style: TextStyle(color: Colors.black),
                  ),
                  const Text(
                    '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    '₹ 13500',
                    style: TextStyle(
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
                    'Fee Revenue',
                    style: TextStyle(color: Colors.black),
                  ),
                  const Text(
                    '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    '₹ 3,500',
                    style: TextStyle(
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
                    'Total Revenue',
                    style: TextStyle(color: Colors.black),
                  ),
                  const Text(
                    '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    '₹ 10,500',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/pdfimage.png', width: 40),
                  AppSizedBox.width5,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('Invoice 258522'), Text('2.00 MB')],
                  ),
                ],
              ),
              Icon(Icons.file_download_outlined),
            ],
          ),
          AppSizedBox.height10,
        ],
      ),
    ),
  ],
);
Widget _adjustmentpaymentcard() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 3),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment ID -',
                          style: TextStyle(
                            color: Color(0xFF101727),
                            fontSize: 16.18,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '152887565',
                          style: TextStyle(
                            color: Color(0xFF101727),
                            fontSize: 15,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    AppSizedBox.width10,
                    AppSizedBox.width10,
                    AppSizedBox.width50,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(204, 246, 86, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Processed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color.fromRGBO(77, 174, 66, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Icon(Icons.more_vert, size: 15, color: Colors.black),
              ],
            ),
            AppSizedBox.height5,
            Text(
              'Order ID - 1231233',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.normal,
              ),
            ),
            AppSizedBox.height10,
            Row(
              children: [
                Icon(Icons.calendar_month_rounded),
                AppSizedBox.width5,
                Text(
                  'Due date -',
                  style: TextStyle(
                    color: Color(0xFF101727),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSizedBox.width10,
                Text(
                  '12 Oct -25 oct,2025',
                  style: TextStyle(
                    color: Color(0xFF101727),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            AppSizedBox.height10,
            AppSizedBox.height5,
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    const Text('Type', style: TextStyle(color: Colors.black)),
                    const Text(
                      '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      'Adjustment',
                      style: TextStyle(
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
                      'Order Adjustment',
                      style: TextStyle(color: Colors.black),
                    ),
                    const Text(
                      '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      'ORD105',
                      style: TextStyle(
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
                      'Platform Fees',
                      style: TextStyle(color: Colors.black),
                    ),
                    const Text(
                      '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      '₹ 3500',
                      style: TextStyle(
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
                    const Text('Refund', style: TextStyle(color: Colors.black)),
                    const Text(
                      '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      '₹ 3500',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
