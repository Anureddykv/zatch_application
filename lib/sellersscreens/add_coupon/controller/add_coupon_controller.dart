import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zatch_app/model/coupondasboard.dart';
import 'package:zatch_app/services/api_service.dart';

class AddCouponController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final selectedValue = "this_week".obs;
  late TabController tabController;
  var isLoading = false.obs;
  final ApiService _apiService = ApiService();
  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
    getcoupondashboard("This Week");
  }

  var coupondashboardresponse = Rx<CouponDashboardResponse?>(null);
  Future<void> getcoupondashboard(String value) async {
    try {
      isLoading.value = true;

      final result = await _apiService.couponDashboardservice(value);

      coupondashboardresponse.value = result;

      isLoading.value = false;
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
