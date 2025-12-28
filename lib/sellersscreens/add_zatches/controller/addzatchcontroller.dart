import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Addzatchcontroller extends GetxController
    with GetSingleTickerProviderStateMixin {
  final selectedValue = "this_week".obs;
  late TabController tabController;
  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
    
  }
}
