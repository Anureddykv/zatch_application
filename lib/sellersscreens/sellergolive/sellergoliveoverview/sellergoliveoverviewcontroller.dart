import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zatch_app/model/golivenowresponsemodel.dart';
import 'package:zatch_app/model/live_details_response.dart';
import 'package:zatch_app/services/api_service.dart';

class Sellergoliveoverviewcontroller extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void onInit() {
    tabController = TabController(length: 3, vsync: this);
    super.onInit();
    // fetchLiveDetails();
  }

  final TextEditingController commentcontroller = TextEditingController();

  final List<Comment> comments = [
    Comment(text: 'This live session was really helpful 👍'),
    Comment(text: 'Can you explain the pricing once again?'),
    Comment(text: 'Great content, learned a lot!'),
    Comment(text: 'Please share the recorded version'),
    Comment(text: 'Nice presentation 👏'),
    Comment(text: 'Audio was slightly unclear at first'),
    Comment(text: 'Looking forward to the next session'),
    Comment(text: 'Very informative, thanks!'),
    Comment(text: 'Can you cover this topic in detail next time?'),
    Comment(text: 'Excellent session 🔥'),
  ];
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // api integration part
  var isLoading = false.obs;
  var golivenowresponsemodel = Rx<GoLiveNowResponseModel?>(null);
  var livedetailsresponse = Rx<LiveDetailsResponse?>(null);
  final ApiService _apiService = ApiService();
  Future<void> fetchLiveDetails( String sessionId) async {
    try {
      isLoading.value = true;

      final response = await _apiService.fetchLiveNowDetails(
        sessionId,
      );

      if (!response.success) {
        throw Exception("Some error occured");
      }
      livedetailsresponse.value = response;
      isLoading.value = false;
    } catch (e) {
      log("Error fetching live overview: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class Comment {
  final String text;

  Comment({required this.text});
}
