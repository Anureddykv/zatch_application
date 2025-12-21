import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/model/product_response_seller.dart';
import 'package:zatch_app/sellersscreens/add_reel/controllers/add_reels_controller.dart';
import 'package:zatch_app/sellersscreens/add_reel/screens/ImagePreviewPage.dart';

class UploadBuyBitsScreen extends StatefulWidget {
  const UploadBuyBitsScreen({super.key});

  @override
  State<UploadBuyBitsScreen> createState() => _UploadBuyBitsScreenState();
}

class _UploadBuyBitsScreenState extends State<UploadBuyBitsScreen> {
  final AddReelsController controller = Get.put<AddReelsController>(
    AddReelsController(),
  );
  @override
  Widget build(BuildContext context) {
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
            title: const Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.contentColorWhite,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.contentColorBlack,
                      size: 16,
                    ),
                  ),
                  Text(
                    'Upload Buy Bits',
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

      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 24.0,
                    ),
                    child: BuybitsuploadStepper(
                      currentStep: controller.currentStep.value,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          child: Obx(() {
                            if (controller.currentStep.value == 0) {
                              return Buybitsstepone();
                            } else if (controller.currentStep.value == 1) {
                              return BuyBitsStepTwo();
                            } else {
                              return BuyBitsStepThree(
                                product: controller.selectedProducts,
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 150),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Obx(
                    () => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(right: 15, left: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
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
                        onPressed: () {
                          controller.currentStep--;
                          controller.currentStep.value == 0
                              ? Navigator.pop(context)
                              : SizedBox.shrink();
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
                            controller.currentStep.value == 0
                                ? const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                )
                                : const Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      right: 15,
                      left: 15,
                      bottom: 10,
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
                      // onPressed: () {
                      //   controller.nextStep();
                      //   log(controller.currentStep.value.toString());
                      //   controller.currentStep.value == 2
                      //       ? showModalBottomSheet(
                      //         context: context,
                      //         isScrollControlled: true,
                      //         backgroundColor: Colors.transparent,
                      //         builder: (context) {
                      //           return Padding(
                      //             padding: const EdgeInsets.all(12.0),
                      //             child: const BargainConfirmDialog(),
                      //           );
                      //         },
                      //       )
                      //       : SizedBox.shrink();
                      // },
                      onPressed: () {
                        log(controller.currentStep.value.toString());
                        controller.uploadbitsSteps();
                        controller.nextStep();
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
                      child: const Text(
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
    );
  }
}

class BargainConfirmDialog extends StatelessWidget {
  const BargainConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Are you sure ?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF030213),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Previous Bargain Settings will be\nupdated for this product.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF697282),
            ),
          ),

          const SizedBox(height: 25),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF030213), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFF030213),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => SuccesspageBuybits()),
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(163, 221, 0, 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Continue",
                style: TextStyle(
                  color: Color(0xFF030213),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HashtagInputWidget extends StatelessWidget {
  HashtagInputWidget({super.key});

  final AddReelsController controller = Get.find<AddReelsController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.tag, color: Colors.grey),
              const SizedBox(width: 10),

              Expanded(
                child: TextField(
                  controller: controller.hashtagController,
                  decoration: const InputDecoration(
                    hintText: "Enter Hashtags",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 13),
                  ),
                ),
              ),

              GestureDetector(
                onTap: controller.addHashtag,
                child: const Text(
                  "Add",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Obx(() {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                controller.hashtags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF9CC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFA3DD00),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF101727),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => controller.removeHashtag(tag),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF101727),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          );
        }),
      ],
    );
  }
}

class Buybitsstepone extends StatelessWidget {
  const Buybitsstepone({super.key});

  @override
  Widget build(BuildContext context) {
    final AddReelsController controller = Get.put<AddReelsController>(
      AddReelsController(),
    );
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buy Bits',
              style: TextStyle(
                color: Color(0xFF101727),
                fontSize: 15.18,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSizedBox.height8,
            const Text(
              "Short Promotional clip for your products",
              style: TextStyle(
                color: Color(0xFF2C2C2C),
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.36,
                wordSpacing: 1.6,
              ),
            ),
            AppSizedBox.height10,
            const Text(
              'Upload Video (15 sec - 2 min)',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            AppSizedBox.height10,
            Obx(() {
              return ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  children: [
                    // If NO video
                    controller.tempSelectedVideo.value == null
                        ? const SizedBox.shrink()
                        :
                        // If NOT playing → show thumbnail
                        (!controller.isVideoPlaying.value)
                        ? SizedBox(
                          width: double.infinity,
                          height: 200,
                          child:
                              controller.videoThumbnail.value == null
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : Image.memory(
                                    controller.videoThumbnail.value!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                        )
                        :
                        // If playing → show VideoPlayer
                        SizedBox(
                          width: double.infinity,
                          height: 200,
                          child:
                              controller.videoController.value == null
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : VideoPlayer(
                                    controller.videoController.value!,
                                  ),
                        ),

                    // Play Button (Only when NOT playing)
                    if (controller.tempSelectedVideo.value != null &&
                        !controller.isVideoPlaying.value)
                      Positioned.fill(
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              controller.isVideoPlaying.value = true;
                              controller.videoController.value?.play();
                            },
                            child: Image.asset(
                              'assets/images/playicon.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                      ),

                    // Close button
                    if (controller.tempSelectedVideo.value != null)
                      Positioned(
                        top: -15,
                        right: -1,
                        child: GestureDetector(
                          onTap: () {
                            controller.tempSelectedVideo.value = null;
                            controller.videoThumbnail.value = null;

                            controller.videoController.value?.pause();
                            controller.videoController.value?.dispose();
                            controller.videoController.value = null;

                            controller.isVideoPlaying.value = false;
                          },
                          child: const Material(
                            elevation: 10,
                            shape: CircleBorder(),
                            color: Colors.white,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                              child: Icon(Icons.close, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            AppSizedBox.height20,
            const Text(
              'Thumbnail Image',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            AppSizedBox.height10,

            Obx(() {
              if (controller.selectedImage.value == null) {
                return const SizedBox.shrink();
              }
              log(controller.selectedImage.value?.path ?? "NO IMAGE");

              return ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  children: [
                    Image.file(
                      controller.selectedImage.value!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    // Close Button
                    Positioned(
                      top: -10,
                      right: -10,
                      child: GestureDetector(
                        onTap: () {
                          controller.selectedImage.value = null;
                        },
                        child: const Material(
                          elevation: 10,
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.close, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            AppSizedBox.height10,
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  controller.selectedImage.value == null
                      ? GestureDetector(
                        onTap: () async {
                          bool allowed =
                              await controller.requestGalleryPermission();
                          if (!allowed) {
                            Get.snackbar(
                              "Permission",
                              "Gallery permission required",
                            );
                            return;
                          }

                          // Pick video
                          await controller.pickVideo(ImageSource.gallery);

                          // Navigate to preview page if video selected
                          // if (controller.tempSelectedVideo.value !=
                          //     null) {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder:
                          //           (context) => VideoPreviewPage(
                          //             videoFile:
                          //                 controller
                          //                     .tempSelectedVideo
                          //                     .value!,
                          //           ),
                          //     ),
                          //   );
                          // }
                        },
                        child: Container(
                          width: 150,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.play_circle_outline, size: 20),
                                SizedBox(height: 8),
                                Text(
                                  "Upload Video",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
                  controller.selectedImage.value == null
                      ? Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            'Or',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
                  controller.selectedImage.value == null
                      ? GestureDetector(
                        onTap: () async {
                          // Request permission
                          bool allowed =
                              await controller.requestGalleryPermission();
                          if (!allowed) {
                            Get.snackbar(
                              "Permission",
                              "Gallery permission required",
                            );
                            return;
                          }

                          // Pick image & update state
                          await controller.pickImage(ImageSource.gallery);

                          if (controller.tempSelectedImage.value != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ImagePreviewPage(
                                      imageProvider: FileImage(
                                        controller.tempSelectedImage.value!,
                                      ),
                                    ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 200,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(18.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.picture_in_picture, size: 20),
                                SizedBox(height: 8),
                                Text(
                                  "Upload From Gallery",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
                ],
              );
            }),
            AppSizedBox.height10,
            Text(
              'Title *',
              style: const TextStyle(
                color: Color(0xFF354152),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 7),
            TextFormField(
              controller: controller.titlecontroller,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Title is required";
                }
                return null;
              },
              maxLines: 1,
              keyboardType: TextInputType.text,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: 'Enter Title',
                hintStyle: const TextStyle(
                  color: Color(0xFF717182),
                  fontSize: 12.30,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0xFFA2DC00),
                  ),
                ),
              ),
            ),
            AppSizedBox.height10,
            Text(
              'Description',
              style: const TextStyle(
                color: Color(0xFF354152),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 7),
            TextFormField(
              maxLines: 4,
              controller: controller.descriptioncontroller,
              keyboardType: TextInputType.text,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: 'Enter Title',
                hintStyle: const TextStyle(
                  color: Color(0xFF717182),
                  fontSize: 12.30,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0xFFA2DC00),
                  ),
                ),
              ),
            ),
            AppSizedBox.height10,
            const Text(
              "Hashtags (Minimum 3)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            AppSizedBox.height10,
            HashtagInputWidget(),
          ],
        ),
      ),
    );
  }
}

class BuyBitsStepThree extends StatefulWidget {
  final RxList<ProductItem> product;
  const BuyBitsStepThree({super.key, required this.product});

  @override
  State<BuyBitsStepThree> createState() => _BuyBitsStepThreeState();
}

class _BuyBitsStepThreeState extends State<BuyBitsStepThree> {
  final AddReelsController controller = Get.put<AddReelsController>(
    AddReelsController(),
  );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Products',
                style: TextStyle(
                  color: Color(0xFF101727),
                  fontSize: 15.18,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Change',
                style: TextStyle(
                  color: Color(0xFFA2DC00),
                  fontSize: 15.18,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSizedBox.height10,
          Obx(() {
            final list = controller.bargainFilteredProducts;

            if (list.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "No matching products found",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildProductCard(list[index]),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductItem product) {
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),

                // child: Image.asset("assets/images/image_95.png", width: 70),
                child: Image.network(
                  product.images.isNotEmpty ? product.images.first.url : '',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/image_95.png",
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Color(0xFF101727),
                          fontSize: 15.18,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSizedBox.height5,
                      Text(
                        product.description,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductDetailRow(
                                label: 'Cost',
                                value: '${product.price}',
                              ),
                              const SizedBox(height: 4),
                              ProductDetailRow(label: 'SKU', value: '12345'),
                              const SizedBox(height: 4),
                              ProductDetailRow(
                                label: 'Stock',
                                value: '10 Units',
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.remove_red_eye,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  Text('${product.viewCount}'),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.star,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  Text('${product.averageRating}'),
                                ],
                              ),
                            ],
                          ),
                        ],
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

          //bargain settings card
          OnbargainSettingscard(product: product),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  ProductDetailRow({required String label, required String value}) {
    return Row(
      children: [
        Text(
          '$label -',
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Inter',
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: Color(0xFF272727),
          ),
        ),
      ],
    );
  }
}

class OnbargainSettingscard extends StatefulWidget {
  final ProductItem product;

  OnbargainSettingscard({super.key, required this.product});

  @override
  State<OnbargainSettingscard> createState() => _OnbargainSettingscardState();
}

class _OnbargainSettingscardState extends State<OnbargainSettingscard> {
  final AddReelsController controller = Get.put<AddReelsController>(
    AddReelsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final setting = controller.bargainSettings[widget.product.id];
      if (setting == null) {
        return const SizedBox();
      }
      final autoAcceptValue =
          widget.product.price * (1 - setting.autoAccept / 100);
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.percent, size: 20, color: Color(0xFF101727)),
                  SizedBox(width: 7),
                  Text(
                    'Bargain Settings',
                    style: TextStyle(
                      color: Color(0xFF101727),
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Transform.scale(
                scale: 0.6,
                child: Switch(
                  value: setting.isEnabled,
                  onChanged:
                      (v) => controller.updateBargain(
                        productId: widget.product.id,
                        enabled: v,
                      ), // handle the switch changes here
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF030213),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),

          if (setting.isEnabled) ...[
            const Row(
              children: [
                Icon(Icons.priority_high, color: Colors.green),
                Flexible(
                  child: Text(
                    "Optional and if added, is applicable to all the products",
                    style: TextStyle(color: Color(0xFF697282), fontSize: 13),
                  ),
                ),
              ],
            ),

            AppSizedBox.height10,
            _buildSlider(
              label: 'Auto-Accept Discount',
              value: setting.autoAccept,
              onChanged:
                  (v) => controller.updateBargain(
                    productId: widget.product.id,
                    autoAccept: v,
                  ),
              displayColor: const Color(0xFF016630),
              backgroundColor: const Color(0xFFECECF0),
              displayValue:
                  '${setting.autoAccept.toInt()}% (₹${autoAcceptValue.toInt()})',
              description:
                  'Orders at this discount or lower will be auto-accepted',
            ),
            AppSizedBox.height10,
            _buildSlider(
              label: 'Maximum Discount',
              value: setting.maxDiscount,
              onChanged:
                  (v) => controller.updateBargain(
                    productId: widget.product.id,
                    maxDiscount: v,
                  ),
              displayColor: const Color(0xFF9F2D00),
              backgroundColor: const Color(0xFFFFECD4),
              displayValue: '${setting.maxDiscount.toInt()}%',
            ),
            AppSizedBox.height10,
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 233, 234, 235),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Price Floor:",
                        style: TextStyle(
                          color: Color(0xFF030213),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Buyer will bargain till this price at the most",
                        style: TextStyle(
                          color: Color(0xFF697282),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "₹3000",
                    style: TextStyle(
                      color: Color(0xFF030213),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            AppSizedBox.height10,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: ShapeDecoration(
                    // color:
                    //     isSelected && p.isActive
                    //         ? const Color(0xFFA2DC00)
                    //         : const Color(0xFFF2F4F6),
                    color: const Color(0xFFF2F4F6),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        // color:
                        // isSelected && p.isActive
                        //     ? const Color(0xFFA2DC00)
                        //     : Colors.black.withOpacity(0.1),
                        color: Colors.black.withOpacity(0.1),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // child:
                  //     isSelected && p.isActive
                  //         ? const Icon(
                  //           Icons.check,
                  //           size: 14,
                  //           color: Colors.white,
                  //         )
                  //         : null,
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
                AppSizedBox.width10,
                const Text(
                  'Apply this settings to all Products',
                  style: TextStyle(
                    color: Color(0xFF354152),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required Color displayColor,
    required Color backgroundColor,
    required String displayValue,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF354152),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 1.75,
              ),
              decoration: ShapeDecoration(
                color: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.75),
                ),
              ),
              child: Text(
                displayValue,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: displayColor,
                  fontSize: 10.50,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 14.0,
              trackShape: const RoundedRectSliderTrackShape(),
              activeTrackColor: const Color(0xFF030213),
              inactiveTrackColor: const Color(0xFFECECF0),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 7.0,
                elevation: 2.0,
              ),
              thumbColor: Colors.white,
              overlayColor: Colors.transparent,
            ),
            child: Slider(value: value, min: 0, max: 100, onChanged: onChanged),
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF697282),
              fontSize: 10.50,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

class BuyBitsStepTwo extends StatefulWidget {
  BuyBitsStepTwo({super.key});

  @override
  State<BuyBitsStepTwo> createState() => _BuyBitsStepTwoState();
}

class _BuyBitsStepTwoState extends State<BuyBitsStepTwo> {
  final AddReelsController controller = Get.put<AddReelsController>(
    AddReelsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Products',
                style: TextStyle(
                  color: Color(0xFF101727),
                  fontSize: 15.18,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.add),
                  Text(
                    'Add New Products',
                    style: TextStyle(
                      color: Color(0xFF101727),
                      fontSize: 15.18,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSizedBox.height8,
          const Text(
            "Offer Name",
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.36,
              wordSpacing: 1.6,
            ),
          ),
          AppSizedBox.height10,
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
            child: const Row(
              children: [
                Icon(Icons.search, size: 20, color: Color(0xFF626262)),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Products or People...',
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
          AppSizedBox.height10,
          // SizedBox(
          //     height: 800,
          //     child: ListView.separated(
          //       itemCount: 5,
          //       shrinkWrap: true,
          //       physics: NeverScrollableScrollPhysics(),
          //       separatorBuilder: (_, __) => SizedBox(height: 12),
          //       itemBuilder: (context, index) {
          //         return GestureDetector(
          //           onTap: () => controller.toggleSelection(index),
          //           child: GoliveProductTile(
          //             isSelected: controller.selectedList[index],
          //             isActive: controller.activeList[index],
          //           ),
          //         );
          //       },
          //     ),
          //   ),
          SingleChildScrollView(child: _golivebody(context)),
        ],
      ),
    );
  }

  Widget? _golivebody(BuildContext context) {
    return Obx(() {
      if (controller.filteredProducts.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 40, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  "No matching products found",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.filteredProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = controller.filteredProducts[index];
              return _goliveproducttile(p);
            },
          ),
        ],
      );
    });
  }

  Widget _goliveproducttile(ProductItem p) {
    final isSelected = controller.selectedProducts.any(
      (prod) => prod.id == p.id,
    );
    final isActive = controller.isProductActive(p.id);

    Widget productTileContentGolive = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            (isSelected && isActive)
                ? const Color(0xFFFAFDF2)
                : const Color(0xFFF8FAFB),

        borderRadius: BorderRadius.circular(12.75),
        border: Border.all(
          color:
              (isSelected && isActive)
                  ? const Color(0xFFA2DC00)
                  : Colors.transparent,
          width: 1.5,
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 4),
            decoration: ShapeDecoration(
              color:
                  isSelected && isActive
                      ? const Color(0xFFA2DC00)
                      : const Color(0xFFF2F4F6),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color:
                      isSelected && isActive
                          ? const Color(0xFFA2DC00)
                          : Colors.black.withOpacity(0.1),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child:
                isSelected && isActive
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
          ),

          const SizedBox(width: 12),

          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(25),

            // child: Image.asset("assets/images/image_95.png", width: 70),
            child: Image.network(
              p.images.isNotEmpty ? p.images.first.url : '',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/images/image_95.png",
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.30,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF101727),
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  p.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF697282),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    Flexible(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(0.4),
                          1: FlexColumnWidth(0.4),
                          2: FlexColumnWidth(0.9),
                        },
                        children: [
                          TableRow(
                            children: [
                              const Text(
                                'Cost',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              const Text(
                                '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                '${p.discountedPrice}₹',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF272727),
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

                          const TableRow(
                            children: [
                              Text(
                                'SKU',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                '32',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF272727),
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

                          const TableRow(
                            children: [
                              Text(
                                'Stock',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                '16 Units',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF272727),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 1.75,
                              ),
                              decoration: ShapeDecoration(
                                color: Color(0xFFFFECD4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.75),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    '23KU Low Stock',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF9F2D00),
                                      fontSize: 8,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppSizedBox.height5,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye,
                                      size: 11,
                                      color: Color(0xFF697282),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      '${p.viewCount}',
                                      style: const TextStyle(
                                        color: Color(0xFF697282),
                                        fontSize: 10,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 11,
                                      color: Color(0xFF697282),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      '${p.averageRating}',
                                      style: TextStyle(
                                        color: Color(0xFF697282),
                                        fontSize: 10,
                                        fontFamily: 'Plus Jakarta Sans',
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          controller.toggleProductActive(p.id);

          if (isSelected) {
            controller.selectedProducts.removeWhere((prod) => prod.id == p.id);
          } else {
            controller.selectedProducts.add(p);
          }
        });
        log("the product id : ${p.id}");
      },
      // child: Stack(
      //   children: [
      //     ColorFiltered(
      //       colorFilter:
      //           !isActive
      //               ? greyscale
      //               : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
      //       child: productTileContentGolive,
      //     ),
      //   ],
      // ),
      child: productTileContentGolive,
    );
  }
}

class BuybitsuploadStepper extends StatelessWidget {
  final int currentStep;
  const BuybitsuploadStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final List<String> steps = ['Upload\nVideo', 'Select\nProduct', 'Bargain'];

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
