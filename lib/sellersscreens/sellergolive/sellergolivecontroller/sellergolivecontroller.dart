import 'dart:developer';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:zatch_app/model/livesummarymodel.dart';
import 'package:zatch_app/model/product_response_seller.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergolivecontroller/seller_go_live_step_two_controller.dart';
import 'package:dio/dio.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergolivescreens/golivesuccess_screen.dart';

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
    fetchProducts();
    getLiveSummaryData("This Week");
    filteredProducts.assignAll(products);
    searchCtrl.addListener(() {
      filterProducts(searchCtrl.text);
    });
    super.onInit();
    ever(selectedProducts, (_) {
      resetZatchSearch();
    });
  }

  RxInt currentStep = 0.obs;

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;

      if (currentStep.value == 1) {
        resetZatchSearch();
      }
    }
  }

  void onBackPressed(BuildContext context) {
    if (currentStep.value > 0) {
      currentStep.value--;

      // ✅ If we reached Step 1, clear selections
      if (currentStep.value == 0) {
        clearSelectedProducts();
      }
    } else {
      // Step 0 → Exit screen
      Navigator.pop(context);
    }
  }

  void clearSelectedProducts() {
    selectedProducts.clear();
    zatchFilteredProducts.clear();
    activeStatus.clear();
    searchCtrl.clear();
  }

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

  //product display
  RxList<ProductItem> products = <ProductItem>[].obs;
  RxList<ProductItem> filteredProducts = <ProductItem>[].obs;
  RxList<ProductItem> selectedProducts = <ProductItem>[].obs;

  // zatch search
  RxList<ProductItem> zatchFilteredProducts = <ProductItem>[].obs;
  //for step 1
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

  RxMap<String, bool> activeStatus = <String, bool>{}.obs;

  bool isProductActive(String productId) {
    return activeStatus[productId] ?? false;
  }

  void toggleProductActive(String productId) {
    activeStatus[productId] = !(activeStatus[productId] ?? false);
    update();
  }

  //search
  TextEditingController searchCtrl = TextEditingController();
  TextEditingController zatchsearchCtrl = TextEditingController();
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

  /// 🔍 Step-2 Search Function
  void searchZatchProducts(String query) {
    if (query.isEmpty) {
      zatchFilteredProducts.assignAll(selectedProducts);
      return;
    }

    zatchFilteredProducts.assignAll(
      selectedProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase());
      }).toList(),
    );
  }

  /// 🔄 Reset Search
  void resetZatchSearch() {
    zatchFilteredProducts.assignAll(selectedProducts);
  }

  Map<String, dynamic> buildStepOnePayload() {
    return {
      "step": "1",
      "products":
          selectedProducts.map((p) {
            return {"productId": p.id};
          }).toList(),
    };
  }

  Map<String, dynamic> buildStepTwoPayload(String sessionId) {
    return {
      "step": "2",
      "sessionId": sessionId,
      "products":
          selectedProducts.map((product) {
            final setting = bargainSettings[product.id]!;

            return {
              "productId": product.id,
              "bargainEnabled": setting.isEnabled,
              "autoAcceptDiscount": setting.autoAccept.toInt(),
              "maximumDiscount": setting.maxDiscount.toInt(),
            };
          }).toList(),
    };
  }

  Future<FormData> buildStepThreePayload(String sessionId) async {
    return FormData.fromMap({
      "step": "3",
      "sessionId": sessionId,
      "title": titlecontroller.text,
      "description": descriptioncontroller.text,
      "sheduledStartTime": buildScheduledTime(),
      // "thumbnail": await MultipartFile.fromFile(
      //   selectedImage.value! as String,
      //   // filename: selectedImage.value!.split('/').last,
      // ),
    });
  }

  Future<void> goLiveSteps(BuildContext context) async {
    try {
      // ------------------------------
      // STEP 1
      // ------------------------------
      if (currentStep.value == 0) {
        final step1Payload = buildStepOnePayload();
        log("Step 1 Payload: $step1Payload");

        final response1 = await ApiService().goLiveStepOne(
          payload: step1Payload,
        );

        if (response1 != null) {
          log("STEP 1 Success: ${response1.message}");
          sessionId.value = response1.sessionId ?? "";
          currentStep.value = 1;
        }
        return;
      }

      // ------------------------------
      // STEP 2
      // ------------------------------
      if (currentStep.value == 1) {
        final step2Payload = buildStepTwoPayload(sessionId.value);
        log("STEP 2 Payload: $step2Payload");

        final response2 = await ApiService().goLiveStepTwo(
          payload: step2Payload,
        );

        if (response2 != null) {
          log("STEP 2 Success: ${response2.message}");
          currentStep.value = 2;
        }
        return;
      }

      // ------------------------------
      // STEP 3 (FORM DATA)
      // ------------------------------
      if (currentStep.value == 2) {
        try {
          // Build Payload
          final step3Payload = await buildStepThreePayload(sessionId.value);
          log("STEP 3 Payload => ${step3Payload.toString()}");

          // API Call
          final response3 = await ApiService().goLiveStepThree(
            payload: step3Payload,
          );

          // Validate Response
          if (response3 != null && response3.success == true) {
            log("STEP 3 Success: ${response3.message}");
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => GoliveAddedSuccessScreen(data: response3),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            log("STEP 3 Failed: Response empty or success=false");
          }
        } catch (e, s) {
          log("STEP 3 Error: $e");
          log("$s");
        }

        return; // Important → stops further execution
      }
    } catch (e) {
      log("Error in goLiveSteps: $e");
    }
  }

  // Future<void> goLiveSteps() async {
  //   try {
  //     // STEP 1
  //     if (currentStep.value == 0) {
  //       final step1Payload = buildStepOnePayload();
  //       log("Step 1 Payload: ${step1Payload.toString()}");

  //       final response1 = await ApiService().goLiveStepOne(
  //         payload: step1Payload,
  //       );

  //       if (response1 != null) {
  //         log("STEP 1 Success: ${response1.message}");
  //         log("STEP 1 sessionId: ${response1.sessionId}");
  //       }
  //     }

  //     // STEP 2
  //     if (currentStep.value == 1) {
  //       final step1Payload = buildStepOnePayload();

  //       final response1 = await ApiService().goLiveStepOne(
  //         payload: step1Payload,
  //       );
  //       final step2Payload = buildStepTwoPayload(response1!.sessionId);

  //       log("STEP 2 Payload: $step2Payload");

  //       final response2 = await ApiService().goLiveStepTwo(
  //         payload: step2Payload,
  //       );

  //       if (response2 != null) {
  //         log("STEP 2 Success: ${response2.message}");
  //         currentStep.value = 2; // completed
  //         log("STEP 2 sessionId: ${response2.sessionId}");
  //       }
  //     }
  //     if (currentStep.value == 2) {
  //       //
  //       final step1Payload = buildStepOnePayload();

  //       final response1 = await ApiService().goLiveStepOne(
  //         payload: step1Payload,
  //       );
  //       final step2Payload = buildStepTwoPayload(response1!.sessionId);

  //       final response2 = await ApiService().goLiveStepTwo(
  //         payload: step2Payload,
  //       );
  //       final step3payload = buildStepThreePayload(response2!.sessionId);
  //       log("Step 3 Payload: ${step3payload.toString()}");
  //       final response3 = await ApiService().goLiveStepTwo(
  //         payload: step3payload,
  //       );
  //       if (response3 != null) {
  //         log("STEP 3 Success: ${response3.message}");
  //         currentStep.value = 2; // completed
  //       }
  //     }
  //   } catch (e) {
  //     log("Error in goLiveSteps: $e");
  //   }
  // }

  late RxList<ProductItem> allProducts;
  final RxMap<String, BargainSetting> bargainSettings =
      <String, BargainSetting>{}.obs;
  void initProducts(RxList<ProductItem> products) {
    allProducts = products;
    zatchFilteredProducts.assignAll(products);

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

  //step 3
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();

  RxString selectedDay = "".obs;
  RxString selectedMonth = "".obs;
  RxString selectedYear = "".obs;

  RxString selectedHour = "".obs;
  RxString selectedMinute = "".obs;

  // Other fields
  RxString title = "".obs;
  RxString description = "".obs;
  RxString thumbnailImg = "".obs;
  RxString sessionId = "".obs;
  String buildScheduledTime() {
    final dt = DateTime.utc(
      int.parse(selectedYear.value),
      int.parse(selectedMonth.value),
      int.parse(selectedDay.value),
      int.parse(selectedHour.value),
      int.parse(selectedMinute.value),
    );

    return "${dt.toIso8601String().split('.').first}Z";
  }

  final formKey = GlobalKey<FormState>();
  bool validateStep3() {
    // Validate form fields
    if (!formKey.currentState!.validate()) {
      return false;
    }

    // Validate image
    if (tempSelectedImage.value == null) {
      Get.snackbar("Error", "Thumbnail Image is required");
      return false;
    }

    // Validate schedule fields only if tab=1
    if (selectedTab.value == 1) {
      if (selectedDay.value.isEmpty ||
          selectedMonth.value.isEmpty ||
          selectedYear.value.isEmpty) {
        Get.snackbar("Error", "Please select a valid date");
        return false;
      }

      if (selectedHour.value.isEmpty || selectedMinute.value.isEmpty) {
        Get.snackbar("Error", "Please select a valid time");
        return false;
      }
    }

    return true;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void clearGoLiveData() {
    currentStep.value = 0;
    sessionId.value = '';
    titlecontroller.clear();
    descriptioncontroller.clear();
    tempSelectedImage.value = null;
    selectedDay.value = '';
    selectedMonth.value = '';
    selectedYear.value = '';
    selectedHour.value = '';
    selectedMinute.value = '';
    zatchFilteredProducts.clear();
    tabController.index = 0; // reset tab if using TabController
  }
}
