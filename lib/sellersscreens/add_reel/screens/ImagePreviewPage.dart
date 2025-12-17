import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/sellersscreens/add_reel/controllers/add_reels_controller.dart';
import 'package:zatch_app/sellersscreens/add_reel/screens/upload_buy_bits_screen.dart';

class ImagePreviewPage extends StatelessWidget {
  final ImageProvider imageProvider;

  const ImagePreviewPage({super.key, required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
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
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    CircleAvatar(
                      backgroundColor: AppColors.contentColorWhite,
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.contentColorBlack,
                        size: 16,
                      ),
                    ),
                    Text(
                      'Edit cover',
                      style: TextStyle(
                        color: Color(0xFF101727),
                        fontSize: 15.18,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
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
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AppSizedBox.height50,

                    Text(
                      'Select Thumbnail image',
                      style: TextStyle(
                        color: Color(0xFF101727),
                        fontSize: 15.18,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSizedBox.height5,
                    Text(
                      'Select image from the video uploaded',
                      style: TextStyle(
                        color: const Color(0xFF2C2C2C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.36,
                        wordSpacing: 1.6,
                      ),
                    ),
                    AppSizedBox.height20,
                    AppSizedBox.height10,
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                        bottom: 50,
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 3.0,
                            child: Image(
                              image: imageProvider,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppSizedBox.height100,

                    AppSizedBox.height100,
                    // SeatSelectionPage(),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(right: 30, left: 30, top: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: OutlinedButton(
                        onPressed: () {},
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
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        right: 30,
                        left: 30,
                        bottom: 30,
                        top: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
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
                        onPressed: () {
                          final controller = Get.find<AddReelsController>();
                          controller.selectedImage.value =
                              controller.tempSelectedImage.value;
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => UploadBuyBitsScreen(),
                          //   ),
                          // );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(163, 221, 0, 1),
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 50,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          'Continue',
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
            ],
          ),
        ),
      ),
    );
  }
}

class SeatSelectionPage extends StatefulWidget {
  @override
  _SeatSelectionPageState createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  double indicatorPosition = 0;

  @override
  Widget build(BuildContext context) {
    int rowCount = 10;
    List<String> columns = ['A', 'B', 'C', 'D', "E", "D"];
    return Scaffold(
      appBar: AppBar(title: Text('Select Your Seat')),
      body: Stack(
        children: [
          // 🔹 Scrollable seat list
          ListView.builder(
            padding: const EdgeInsets.only(top: 250, left: 16, right: 16),
            itemCount: rowCount + 1, // +1 for header row
            itemBuilder: (context, rowIndex) {
              // Header row
              if (rowIndex == 0) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AppSizedBox.width30,
                      ...columns.map(
                        (col) => Container(
                          width: 60,
                          alignment: Alignment.center,
                          child: Text(
                            col,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Seat rows
              int actualRow = rowIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      actualRow.toString(), // Row number
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...columns.map((col) {
                      String seatLabel = '$actualRow$col';
                      return Container(
                        width: 50,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text(seatLabel)),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),

          // Positioned(
          //   top: 10,
          //   left: 16,
          //   right: 16,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.blue.shade100,
          //     ),
          //     child: Stack(
          //       children: [
          //         // Flight path (just a dashed line or bar to simulate track)
          //         Image.asset(
          //           'assets/images/flight skelten.png',
          //         ),
          //         // Moving plane icon
          //         Positioned(
          //           left: indicatorPosition.clamp(110, maxWidth - 100),
          //           top: 80,
          //           child: Container(
          //             height: 50,
          //             width: 40,
          //             decoration: BoxDecoration(
          //               color: Colors.red.shade200,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
