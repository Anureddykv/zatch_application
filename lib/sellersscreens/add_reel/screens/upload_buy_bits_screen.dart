import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
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
                              return BuyBitsStepThree();
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
  const BuyBitsStepThree({super.key});

  @override
  State<BuyBitsStepThree> createState() => _BuyBitsStepThreeState();
}

class _BuyBitsStepThreeState extends State<BuyBitsStepThree> {
  bool _isBargainEnabled = true;
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
        ],
      ),
    );
  }
}

Widget _sectionHeader(String title, String badgeText) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFF030213),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEEDD5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          badgeText,
          style: const TextStyle(
            color: Color(0xFFDC7E00),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}

class BuyBitsStepTwo extends StatelessWidget {
  const BuyBitsStepTwo({super.key});

  @override
  Widget build(BuildContext context) {
    final AddReelsController controller = Get.put<AddReelsController>(
      AddReelsController(),
    );
    return Padding(
      padding: EdgeInsets.all(20),
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
          Text(
            "Offer Name",
            style: TextStyle(
              color: const Color(0xFF2C2C2C),
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
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: Color(0xFF626262)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
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
          // BuyBitsProductTile(isActive: false, isSelected: false),
          // AppSizedBox.height10,
          // BuyBitsProductTile(isActive: true, isSelected: true),
          // AppSizedBox.height10,
          // BuyBitsProductTile(isActive: true, isSelected: true),
          // AppSizedBox.height10,
          // BuyBitsProductTile(isActive: false, isSelected: false),
          AppSizedBox.height10,
          SizedBox(
            height: 800,
            child: ListView.separated(
              itemCount: 5,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => controller.toggleSelection(index),
                  child: GoliveProductTile(
                    isSelected: controller.selectedList[index],
                    isActive: controller.activeList[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GoliveProductTile extends StatelessWidget {
  final bool isSelected;
  final bool isActive;
  const GoliveProductTile({
    super.key,
    required this.isSelected,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder booleans for styling
    // final bool isSelected = true;
    // final bool isActive = true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            isSelected && isActive
                ? const Color(0xFFFAFDF2)
                : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12.75),
        border: Border.all(
          color:
              isSelected && isActive
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
            borderRadius: BorderRadius.circular(8.75),
            child: Image.asset(
              'assets/images/thumnailimg.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sample Product Title',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.3,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF101727),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sample Product Subtitle',
                  style: TextStyle(
                    color: Color(0xFF697282),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ProductDetailRow(label: 'Cost', value: '\$25'),
                        SizedBox(height: 4),
                        ProductDetailRow(label: 'SKU', value: '12345'),
                        SizedBox(height: 4),
                        ProductDetailRow(label: 'Stock', value: '10 Units'),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 15,
                              color: Colors.grey,
                            ),
                            Text('1200'),
                            SizedBox(width: 5),
                            Icon(Icons.star, size: 15, color: Colors.grey),
                            Text('5'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class ProductDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const ProductDetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF697282),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF101727),
          ),
        ),
      ],
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
