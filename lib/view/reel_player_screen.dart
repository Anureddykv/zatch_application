import 'package:flutter/material.dart';
import 'package:zatch_app/controller/live_stream_controller.dart';
import 'package:zatch_app/view/ReelDetailsScreen.dart';

class ReelPlayerScreen extends StatelessWidget {
  final List<String> bitIds;
  final int initialIndex;

  const ReelPlayerScreen({
    super.key,
    required this.bitIds,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: initialIndex);

    return Scaffold(
      body: PageView.builder(
        controller: controller,
        scrollDirection: Axis.vertical,
        itemCount: bitIds.length,
        itemBuilder: (context, index) {
          return ReelDetailsScreen(
            key: ValueKey(bitIds[index]),
            bitId: bitIds[index],
            controller: LiveStreamController(),
          );
        },
      ),
    );
  }
}
