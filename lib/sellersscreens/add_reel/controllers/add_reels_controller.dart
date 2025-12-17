import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AddReelsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }

  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();

  RxInt currentStep = 0.obs;
  Rx<File?> tempSelectedVideo = Rx<File?>(null);
  var isVideoPlaying = false.obs;
  var videoThumbnail = Rx<Uint8List?>(null);
  var videoController = Rx<VideoPlayerController?>(null);
  Rx<File?> selectedImage = Rx<File?>(null);
  Future<bool> requestGalleryPermission() async {
    var status = await Permission.photos.request();

    if (status.isGranted) return true;

    // Android 12 and below
    if (await Permission.storage.request().isGranted) return true;

    return false;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source);

      if (picked != null) {
        File imageFile = File(picked.path);

        // Optional: compress here if needed

        // selectedImage.value =
        //     imageFile; // Thumbnail will be replaced automatically
        tempSelectedImage.value = imageFile;
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  RxBool isVideoUploaded = false.obs;
  var tempSelectedImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();
  Future<void> pickVideo(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickVideo(source: source);
      if (picked == null) return;

      File videoFile = File(picked.path);

      //----------------------------------------
      // 1️⃣ CHECK FILE SIZE (optional)
      //----------------------------------------
      int fileSize = await videoFile.length(); // bytes
      int maxSize = 50 * 1024 * 1024; // 50MB (you can change)

      if (fileSize > maxSize) {
        Get.snackbar(
          "Video too large",
          "Please select a video less than 50 MB",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      //----------------------------------------
      // 2️⃣ CHECK VIDEO DURATION (15 sec - 2 min)
      //----------------------------------------
      VideoPlayerController tempController = VideoPlayerController.file(
        videoFile,
      );

      await tempController.initialize();
      Duration duration = tempController.value.duration;

      if (duration.inSeconds < 15 || duration.inMinutes > 2) {
        Get.snackbar(
          "Invalid Duration",
          "Video must be between 15 seconds and 2 minutes",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        tempController.dispose();
        return;
      }

      //----------------------------------------
      // 3️⃣ ACCEPT THE VIDEO
      //----------------------------------------
      tempSelectedVideo.value = videoFile;

      // Generate thumbnail
      Uint8List? thumb = await VideoThumbnail.thumbnailData(
        video: videoFile.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 200,
        quality: 75,
      );
      videoThumbnail.value = thumb;

      // Set controller (but don't autoplay)
      videoController.value = VideoPlayerController.file(videoFile)
        ..initialize().then((_) {
          videoController.refresh();
        });

      isVideoUploaded.value = true;
    } catch (e) {
      print("Error picking video: $e");
    }
  }

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  RxList<bool> selectedList = List.generate(5, (_) => false).obs;
  RxList<bool> activeList = List.generate(5, (_) => true).obs;
  void toggleSelection(int index) {
    // Make only one item selected at a time
    for (int i = 0; i < selectedList.length; i++) {
      selectedList[i] = i == index ? !selectedList[i] : false;
    }
    update();
  }

  // Future<FormData> buildStepsPayloadForBuybits(String sessionId) async {
  //   return FormData.fromMap({
  //     "title": titlecontroller.text,
  //     "description": descriptioncontroller.text,
  //     // "sheduledStartTime": buildScheduledTime(),
  //     "hasttags":
  //     "GoLiveNow": true,
  //     // "thumbnail": await MultipartFile.fromFile(
  //     //   selectedImage.value!.path,
  //     //   filename: selectedImage.value!.path.split('/').last,
  //     // ),
  //   });
  // }
  final TextEditingController hashtagController = TextEditingController();

  RxList<String> hashtags = <String>[].obs;

  /// Add hashtag
  void addHashtag() {
    final tag = hashtagController.text.trim();

    if (tag.isEmpty) return;

    // Optional: auto add #
    final formattedTag = tag.startsWith('#') ? tag : '#$tag';

    if (!hashtags.contains(formattedTag)) {
      hashtags.add(formattedTag);
    }

    hashtagController.clear();
  }

  /// Remove hashtag
  void removeHashtag(String tag) {
    hashtags.remove(tag);
  }

  /// For API if backend expects TEXT
  String get hashtagsAsText {
    return hashtags.join(','); // "#sale,#offer,#new"
  }

  /// For API if backend expects LIST
  List<String> get hashtagsAsList {
    return hashtags;
  }

  final formKey = GlobalKey<FormState>();

  bool uploadbitsSteps() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return false;

    if (hashtags.length < 3) {
      Get.snackbar("Error", "Minimum 3 hashtags required");
      return false;
    }

    if (tempSelectedVideo.value == null) {
      Get.snackbar("Error", "Please upload a video");
      return false;
    }

    if (selectedImage.value == null) {
      Get.snackbar("Error", "Please upload a thumbnail image");
      return false;
    }

    currentStep.value = 1;
    return true;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
