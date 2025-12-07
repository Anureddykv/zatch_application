import 'package:flutter/material.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergolivescreens/seller_go_live_screen.dart';

class SellerLiveDashboard extends StatefulWidget {
  const SellerLiveDashboard({super.key});

  @override
  State<SellerLiveDashboard> createState() => _SellerLiveDashboardState();
}

class _SellerLiveDashboardState extends State<SellerLiveDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25)),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
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
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: AppColors.contentColorWhite,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: AppColors.contentColorBlack,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            "Your Live's ",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          Icon(
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
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Row(
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

                                          Obx(
                                            () => DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value:
                                                    yourlivesscreenscontroller
                                                        .selectedValue
                                                        .value,
                                                dropdownColor: Colors.white,
                                                icon: const Icon(
                                                  Icons
                                                      .arrow_drop_down_outlined,
                                                  color: Colors.white,
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                selectedItemBuilder: (
                                                  BuildContext context,
                                                ) {
                                                  return [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            18.0,
                                                          ),
                                                      child: Text(
                                                        "This Week",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            18.0,
                                                          ),
                                                      child: Text(
                                                        "Last 15 Days",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            18.0,
                                                          ),
                                                      child: Text(
                                                        "Last Month",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ];
                                                },
                                                items: const [
                                                  DropdownMenuItem(
                                                    value: "this_week",
                                                    child: Text("This Week"),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: "last_15_days",
                                                    child: Text("Last 15 Days"),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: "last_month",
                                                    child: Text("Last Month"),
                                                  ),
                                                ],
                                                onChanged: (value) {
                                                  yourlivesscreenscontroller
                                                      .selectedValue
                                                      .value = value!;
                                                  yourlivesscreenscontroller
                                                      .getLiveSummaryData(
                                                        value,
                                                      );
                                                  log(value);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Obx(() {
                                        final data =
                                            yourlivesscreenscontroller
                                                .liveSummaryModel
                                                .value;

                                        if (data == null) {
                                          return const SizedBox(); // or loader
                                        }

                                        final summary = data.performanceSummary;
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
                                                  icon: Icons.visibility,
                                                  color: Color(0xFFCCF656),
                                                  value:
                                                      summary.views.toString(),
                                                  label: "views",
                                                  percentText:
                                                      "${summary.viewsChange} this week",
                                                ),
                                                buildStatItem(
                                                  icon: Icons.currency_rupee,
                                                  color: Color(0xFFCCF656),
                                                  value: summary.revenue,
                                                  label: "Revenue",
                                                  percentText:
                                                      "${summary.revenueChange} this week",
                                                ),
                                                buildStatItem(
                                                  icon: Icons.drag_indicator,
                                                  color: Color(0xFFCCF656),
                                                  value: summary.avgEngagement,
                                                  label: "AvgEngagement",
                                                  percentText:
                                                      "${summary.engagementChange} this week",
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            AppSizedBox.height10,
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Golivescreen(),
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
                                      Text(
                                        "Go live / Shedule Live",
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
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xffd5ff4d),
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
                            ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(25),
                              ),
                              child: Stack(
                                children: [
                                  Image.asset('assets/images/thumnailimg.png'),
                                  Positioned(
                                    top: 50,
                                    left: 150,
                                    child: Image.asset(
                                      'assets/images/playicon.png',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppSizedBox.height10,
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Upcoming Live',
                                      style: TextStyle(
                                        color: Color(0xFF101727),
                                        fontSize: 15.18,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    AppSizedBox.height5,
                                    // Text(
                                    //   'Summer Dress, Casual Shirts & Sandals Green Color for women in blue pantdbdcsd',
                                    //   // maxLines: 2,
                                    //   overflow: TextOverflow.ellipsis,
                                    //   style: TextStyle(
                                    //     color: Colors.black,
                                    //     fontSize: 12,
                                    //     fontFamily: 'Inter',

                                    //     fontWeight: FontWeight.normal,
                                    //   ),
                                    // ),
                                    AppSizedBox.height5,
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.timer),
                                    Text('in'),
                                    AppSizedBox.width2,
                                    Text('14H 30M'),
                                    Icon(Icons.more_vert_outlined),
                                  ],
                                ),
                              ],
                            ),
                            AppSizedBox.height8,

                            const Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, size: 15),
                                AppSizedBox.width10,
                                Text(
                                  '12 Oct 2025 - 12.00 AM',
                                  style: TextStyle(
                                    color: AppColors.contentColorBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            AppSizedBox.height20,
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25),
                                ),
                                color: Colors.white,
                              ),
                              child: const Center(
                                child: Text(
                                  'Share Link',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSizedBox.height20,
                      const Text(
                        'Your Lives',
                        style: TextStyle(
                          color: Color(0xFF101727),
                          fontSize: 15.18,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSizedBox.height10,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Fashion Friday Sale',
                                  style: TextStyle(
                                    color: Color(0xFF101727),
                                    fontSize: 15.18,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.more_vert),
                              ],
                            ),
                            AppSizedBox.height8,
                            Text(
                              'Summer Dress, Casual Shirts & Sandals ',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontFamily: 'Inter',

                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            AppSizedBox.height10,
                            const Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, size: 15),
                                AppSizedBox.width10,
                                Text(
                                  '12 Oct 2025 - 12.00 AM',
                                  style: TextStyle(
                                    color: AppColors.contentColorBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            AppSizedBox.height10,
                            ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(25),
                              ),
                              child: Stack(
                                children: [
                                  Image.asset('assets/images/thumnailimg.png'),
                                  Positioned(
                                    top: 65,
                                    left: 160,
                                    child: Image.asset(
                                      'assets/images/playicon.png',
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: const BoxDecoration(
                                        // color: Colors.grey.shade800,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(25),
                                        ),
                                      ),
                                      child: const Text(
                                        '45 min',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                      '1247',
                                      style: TextStyle(
                                        color: Color(0xFF101727),
                                        fontSize: 16,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '156',
                                      style: TextStyle(
                                        color: Color(0xFF101727),
                                        fontSize: 16,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '23,500',
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text('Views'),
                                    Text('Peak'),
                                    Text('Sales'),
                                  ],
                                ),
                              ],
                            ),
                            AppSizedBox.height10,
                            AppSizedBox.height10,
                            SizedBox(
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
                                  "View",
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
                      AppSizedBox.height100,
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
}