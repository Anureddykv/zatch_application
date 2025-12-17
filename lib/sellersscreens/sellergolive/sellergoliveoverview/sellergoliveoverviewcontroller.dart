import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Sellergoliveoverviewcontroller extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void onInit() {
    tabController = TabController(length: 3, vsync: this);
    super.onInit();
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
}
class Comment {
  final String text;

  Comment({required this.text});
}
