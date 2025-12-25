import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zatch_app/model/order_response_model.dart';
import 'package:zatch_app/sellersscreens/seller_order/seller_order_details_screens/seller_order_details_screens.dart';
import 'package:zatch_app/services/api_service.dart';

class Sellerorderscreencontroller extends GetxController
    with GetSingleTickerProviderStateMixin {
  final selectedValue = "this_week".obs;
  TextEditingController searchCtrl = TextEditingController();
  late TabController tabController;
  RxInt selectedTabIndex = 0.obs;
  @override
  void onInit() {
    tabController = TabController(length: 3, vsync: this);
    getsellerOrderstatics("This Week");
    tabController.addListener(() {
      selectedTabIndex.value = tabController.index;
    });
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  //seller order dashboard api
  var isLoading = false.obs;
  final ApiService _apiService = ApiService();
  var orderresponse = Rx<OrderScreenResponse?>(null);
  Future<void> getsellerOrderstatics(String value) async {
    try {
      isLoading.value = true;

      final result = await _apiService.getOrderStatics(value);
      log(result.message);
      orderresponse.value = result;

      isLoading.value = false;
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String formatDueDate(DateTime date) {
    final day = date.day;
    final suffix = _daySuffix(day);
    final month = DateFormat('MMMM').format(date);

    return '$day$suffix $month';
  }

  String _daySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String formatCreatedAt(DateTime date) {
    final datePart = DateFormat('dd MMM yyyy').format(date);
    final timePart = DateFormat('hh.mm a').format(date);

    return '$datePart - $timePart';
  }

  RxInt currentStep = 0.obs;

  /// Go to next step
  void goToNextStep(BuildContext context, ThemeData themeData) {
    if (currentStep.value == 1) {
      showMarkAsShippedBottomSheet(context, themeData);
    } else if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

 
  /// Go to previous step
  void goToPreviousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Jump to a specific step (optional)
  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      currentStep.value = step;
    }
  }
}
