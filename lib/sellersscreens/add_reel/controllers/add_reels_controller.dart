import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:zatch_app/model/product_response_seller.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergolivecontroller/seller_go_live_class.dart';
import 'package:zatch_app/services/api_service.dart';

class AddReelsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);

    super.onInit();
    fetchProducts();
    filteredProducts.assignAll(products);
    searchCtrl.addListener(() {
      filterProducts(searchCtrl.text);
    });
    ever(selectedProducts, (_) {
      resetFilteredSearch();
    });
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      filteredProducts.assignAll(products);
      return;
    }

    final q = query.toLowerCase();

    filteredProducts.assignAll(
      products.where(
        (p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q),
      ),
    );
  }

  bool get hasMediaSelected =>
      tempSelectedVideo.value != null && selectedImage.value != null;

  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  TextEditingController searchCtrl = TextEditingController();

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
    if (currentStep.value == 1) {
      resetFilteredSearch();
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

  //product display
  RxList<ProductItem> products = <ProductItem>[].obs;
  RxList<ProductItem> filteredProducts = <ProductItem>[].obs;
  RxList<ProductItem> selectedProducts = <ProductItem>[].obs;
  RxMap<String, bool> activeStatus = <String, bool>{}.obs;
  RxList<ProductItem> bargainFilteredProducts = <ProductItem>[].obs;

  late RxList<ProductItem> allProducts;
  final RxMap<String, BargainSetting> bargainSettings =
      <String, BargainSetting>{}.obs;
  void initProducts(RxList<ProductItem> products) {
    allProducts = products;
    bargainFilteredProducts.assignAll(products);

    for (final p in products) {
      bargainSettings[p.id] = BargainSetting(
        isEnabled: true,
        autoAccept: 5,
        maxDiscount: 30,
      );
    }
  }

  void updateBargain({
    required String productId,
    bool? enabled,
    double? autoAccept,
    double? maxDiscount,
  }) {
    final setting = bargainSettings[productId];
    if (setting == null) return;

    bargainSettings[productId] = setting.copyWith(
      isEnabled: enabled,
      autoAccept: autoAccept,
      maxDiscount: maxDiscount,
    );
  }

  bool isProductActive(String productId) {
    return activeStatus[productId] ?? false;
  }

  void toggleProductActive(String productId) {
    activeStatus[productId] = !(activeStatus[productId] ?? false);
    update();
  }

  var isLoading = false.obs;
  final ApiService _apiService = ApiService();
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;

      final list = await _apiService.getProductgolive();

      log("FINAL PRODUCT LIST: ${list.length}");

      products.assignAll(list);
      filteredProducts.assignAll(list);
      bargainSettings.clear();
      for (final p in list) {
        bargainSettings[p.id] = BargainSetting(
          isEnabled: false,
          autoAccept: 5,
          maxDiscount: 30,
        );
      }
    } catch (e) {
      log("Error fetching products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilteredSearch() {
    filteredProducts.assignAll(selectedProducts);
  }

  void resetBargainSearch() {
    bargainFilteredProducts.assignAll(selectedProducts);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  TextEditingController bargainsearchCtrl = TextEditingController();
  void searchBargainProducts(String query) {
    if (query.isEmpty) {
      bargainFilteredProducts.assignAll(selectedProducts);
      return;
    }

    bargainFilteredProducts.assignAll(
      selectedProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase());
      }).toList(),
    );
  }
}
