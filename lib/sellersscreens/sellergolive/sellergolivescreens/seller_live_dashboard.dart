import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/model/livesummarymodel.dart';
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
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25)),
        ),
        child: Column(
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
                            "Your Live's ",
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
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
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
                                                    const Padding(
                                                      padding: EdgeInsets.all(
                                                        18.0,
                                                      ),
                                                      child: Text(
                                                        "This Week",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.all(
                                                        18.0,
                                                      ),
                                                      child: Text(
                                                        "Last 15 Days",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.all(
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
                                        if (yourlivesscreenscontroller
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
                                            yourlivesscreenscontroller
                                                .liveSummaryModel
                                                .value;

                                        if (data == null) {
                                          return SizedBox.shrink();
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
                                                  color: const Color(
                                                    0xFFCCF656,
                                                  ),
                                                  value:
                                                      summary.views.toString(),
                                                  label: "views",
                                                  percentText:
                                                      "${summary.viewsChange} this week",
                                                ),
                                                buildStatItem(
                                                  icon: Icons.currency_rupee,
                                                  color: const Color(
                                                    0xFFCCF656,
                                                  ),
                                                  value: summary.revenue,
                                                  label: "Revenue",
                                                  percentText:
                                                      "${summary.revenueChange} this week",
                                                ),
                                                buildStatItem(
                                                  icon: Icons.drag_indicator,
                                                  color: const Color(
                                                    0xFFCCF656,
                                                  ),
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
                                  color: const Color(
                                    0xFFCCF656,
                                  ).withOpacity(0.4),
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
                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AppSizedBox.height20,
                      const Text(
                        'Up Coming Lives',
                        style: TextStyle(
                          color: Color(0xFF101727),
                          fontSize: 15.18,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSizedBox.height10,
                      Obx(() {
                        if (yourlivesscreenscontroller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final data =
                            yourlivesscreenscontroller.liveSummaryModel.value;

                        if (data == null || data.upcomingLives.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.upcomingLives.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 25),
                          itemBuilder: (context, index) {
                            final live = data.upcomingLives[index];
                            return Upcominglivecard(live: live);
                          },
                        );
                      }),
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
                      Obx(() {
                        if (yourlivesscreenscontroller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final data =
                            yourlivesscreenscontroller.liveSummaryModel.value;

                        if (data == null || data.upcomingLives.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.pastLives.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 25),
                          itemBuilder: (context, index) {
                            final live = data.pastLives[index];
                            return PastLivesDetails(live: live);
                          },
                        );
                      }),

                      // PastLivesDetails(live: ,),
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

class PastLivesDetails extends StatelessWidget {
  final PastLiveItem live;
  const PastLivesDetails({super.key, required this.live});

  @override
  Widget build(BuildContext context) {
    String formatEndTime(DateTime dateTime) {
      return DateFormat('dd MMM yyyy - hh.mm a').format(dateTime);
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                live.title,
                style: const TextStyle(
                  color: Color(0xFF101727),
                  fontSize: 15.18,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),

              // IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'View') {
                    // navigate to summary
                  }
                },
                itemBuilder:
                    (context) => const [
                      PopupMenuItem(value: 'View', child: Text('View')),
                    ],
              ),
            ],
          ),
          AppSizedBox.height8,
          Text(
            live.description,
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
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 15),
              AppSizedBox.width10,
              Text(
                formatEndTime(live.endTime),
                style: const TextStyle(
                  color: AppColors.contentColorBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          AppSizedBox.height10,
          // ClipRRect(
          //   borderRadius: const BorderRadius.all(Radius.circular(25)),
          //   child: Stack(
          //     children: [
          //       Image.asset('assets/images/thumnailimg.png'),
          //       Positioned(
          //         top: 65,
          //         left: 160,
          //         child: Image.asset('assets/images/playicon.png'),
          //       ),
          //       Positioned(
          //         right: 10,
          //         top: 10,
          //         child: Container(
          //           padding: const EdgeInsets.all(15),
          //           decoration: const BoxDecoration(
          //             color: Colors.grey,
          //             borderRadius: BorderRadius.all(Radius.circular(25)),
          //           ),
          //           child: const Text(
          //             '45 min',
          //             style: TextStyle(color: Colors.white, fontSize: 12),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            child: Stack(
              children: [
                (live.thumbnail.url.isNotEmpty)
                    ? Image.network(
                      live.thumbnail.url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Image.asset(
                          'assets/images/thumnailimg.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                    : Image.asset(
                      'assets/images/thumnailimg.png',
                      fit: BoxFit.cover,
                    ),

                /// Play icon
                Positioned(
                  bottom: 65,
                  right: 160,
                  child: Image.asset('assets/images/playicon.png', height: 40),
                ),

                /// Duration badge (from backend)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.20),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Text(
                      live.durationFormatted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
          Column(
            children: [
              Row(
                children: [
                  _StatValue(value: live.views.toString()),
                  _StatValue(value: live.peak.toString()),
                  _StatValue(value: live.sales),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  _StatLabel(label: 'Views'),
                  _StatLabel(label: 'Peak'),
                  _StatLabel(label: 'Sales'),
                ],
              ),
            ],
          ),

          AppSizedBox.height10,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1),
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Upcominglivecard extends StatelessWidget {
  final LiveItem live;

  const Upcominglivecard({super.key, required this.live});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                live.thumbnail.url.isNotEmpty
                    ? Image.network(live.thumbnail.url, fit: BoxFit.cover)
                    : Image.asset('assets/images/thumnailimg.png'),
                Image.asset('assets/images/playicon.png'),
              ],
            ),
          ),

          AppSizedBox.height10,
          // const Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Column(
          //       children: [
          //         Text(
          //           'Upcoming Live',
          //           style: TextStyle(
          //             color: Color(0xFF101727),
          //             fontSize: 15.18,
          //             fontFamily: 'Plus Jakarta Sans',
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         AppSizedBox.height5,
          //         // Text(
          //         //   'Summer Dress, Casual Shirts & Sandals Green Color for women in blue pantdbdcsd',
          //         //   // maxLines: 2,
          //         //   overflow: TextOverflow.ellipsis,
          //         //   style: TextStyle(
          //         //     color: Colors.black,
          //         //     fontSize: 12,
          //         //     fontFamily: 'Inter',

          //         //     fontWeight: FontWeight.normal,
          //         //   ),
          //         // ),
          //         AppSizedBox.height5,
          //       ],
          //     ),
          //     Row(
          //       children: [
          //         Icon(Icons.timer),
          //         Text('in'),
          //         AppSizedBox.width2,
          //         Text('14H 30M'),
          //         Icon(Icons.more_vert_outlined),
          //       ],
          //     ),
          //   ],
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      live.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSizedBox.height5,
                    Text(
                      live.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 4),
                  Text(_getRemainingTime(live.scheduledStartTime)),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      _handleUpcomingLiveAction(context, live, value);
                    },
                    itemBuilder: (context) {
                      return live.actions.map((action) {
                        return PopupMenuItem<String>(
                          value: action,
                          child: Text(action),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ],
          ),
          AppSizedBox.height8,

          // const Row(
          //   children: [
          //     Icon(Icons.calendar_month_rounded, size: 15),
          //     AppSizedBox.width10,
          //     Text(
          //       '12 Oct 2025 - 12.00 AM',
          //       style: TextStyle(
          //         color: AppColors.contentColorBlack,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 12,
          //       ),
          //     ),
          //   ],
          // ),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 15),
              AppSizedBox.width10,
              Text(
                _formatDate(live.scheduledStartTime),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSizedBox.height20,
          if (live.actions.contains('Share'))
            GestureDetector(
              onTap: () {
                Share.share(live.shareLink);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    'Share Link',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getRemainingTime(DateTime time) {
    final diff = time.difference(DateTime.now());

    if (diff.isNegative) return 'Live';

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    return '${hours}H ${minutes}M';
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

void _handleUpcomingLiveAction(
  BuildContext context,
  LiveItem live,
  String action,
) {
  switch (action) {
    case 'Edit':
      // navigate to edit screen
      break;

    case 'Cancel':
      // show cancel confirmation
      break;

    case 'Reschedule':
      // open date & time picker
      break;

    case 'Share':
      // share live.shareLink
      break;

    case 'End Live':
      // end live stream
      break;
  }
}

class _StatValue extends StatelessWidget {
  final String value;

  const _StatValue({required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            color: Color(0xFF101727),
            fontSize: 16,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  final String label;

  const _StatLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8A8A), // 👈 description grey
            fontSize: 12,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
