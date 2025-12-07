import 'dart:developer';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zatch_app/model/CartApiResponse.dart';
import 'package:zatch_app/model/livesummarymodel.dart';
import 'package:zatch_app/model/product_response_seller.dart';

import 'package:zatch_app/services/api_service.dart';

class Sellergolivecontroller extends GetxController
    with GetSingleTickerProviderStateMixin {
  //in seller live shedule time
  final selectedValue = "this_week".obs;
  var liveSummaryModel = Rx<LiveSummaryModel?>(null);
  var isLoading = false.obs;
  final ApiService _apiService = ApiService();
  //get live details api
  Future<void> getLiveSummaryData(String value) async {
    isLoading.value = true;

    final result = await _apiService.getLiveSummary(value);
    log(result.message);
    liveSummaryModel.value = result;

    isLoading.value = false;
  }

  late TabController tabController;
  RxInt selectedTab = 0.obs;
  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      selectedTab.value = tabController.index;
    });
    getLiveSummaryData("This Week");
    super.onInit();
  }

  RxInt currentStep = 0.obs;
  bool isBargainEnabled = false;
  double autoAcceptDiscount = 5.0;
  double maxDiscount = 15.0;

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  final RxList<ProductItem> selectedProducts = <ProductItem>[].obs;
  final RxList<ProductItem> selectedProductsList = <ProductItem>[].obs;
  final salePriceController = TextEditingController();
  late final double salePrice =
      double.tryParse(salePriceController.text) ?? 0.0;
  // upload image
  final ImagePicker _picker = ImagePicker();
  Rx<File?> selectedImage = Rx<File?>(null);
  var tempSelectedImage = Rxn<File>();
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

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
