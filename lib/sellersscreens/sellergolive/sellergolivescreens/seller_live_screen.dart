// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_instance/src/extension_instance.dart';
// import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
// import 'package:zatch_app/sellersscreens/sellergolive/sellergolivecontroller/sellergolivecontroller.dart';

// class SellerLiveScreen extends StatefulWidget {
//   const SellerLiveScreen({super.key});

//   @override
//   State<SellerLiveScreen> createState() => _SellerLiveScreenState();
// }

// class _SellerLiveScreenState extends State<SellerLiveScreen> {
//   final Sellergolivecontroller controller = Get.put<Sellergolivecontroller>(
//     Sellergolivecontroller(),
//   );
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Obx(() {
//         if (controller.engine == null) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return AgoraVideoView(
//           controller: VideoViewController(
//             rtcEngine: controller.engine!,
//             canvas: const VideoCanvas(uid: 0), // LOCAL CAMERA
//           ),
//         );
//       }),
//     );
//   }
// }
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergolivecontroller/sellergolivecontroller.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergoliveoverview/sellergoliveoverview.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergoliveoverview/sellergoliveoverviewcontroller.dart';

class SellerLiveScreen extends StatelessWidget {
  const SellerLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final yourLiveController = Get.find<Sellergolivecontroller>();

    final engine = yourLiveController.engine!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🎥 VIDEO VIEW
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: engine,
              canvas: VideoCanvas(uid: yourLiveController.agoraUid),
            ),
          ),

          /// 🔴 LIVE BADGE + VIEWER COUNT + END BUTTON
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _liveBadge(),
                Row(
                  children: [
                    _viewerCount(yourLiveController),
                    const SizedBox(width: 12),
                    _endLiveButton(engine, context),
                  ],
                ),
              ],
            ),
          ),

          /// 🎥 CAMERA CONTROLS
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                _iconButton(
                  icon: Icons.cameraswitch,
                  onTap: () => engine.switchCamera(),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _iconButton(
                    icon:
                        yourLiveController.isMuted.value
                            ? Icons.mic_off
                            : Icons.mic,
                    onTap: () async {
                      yourLiveController.isMuted.value =
                          !yourLiveController.isMuted.value;
                      await engine.muteLocalAudioStream(
                        yourLiveController.isMuted.value,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        
          _productBottomSheet(yourLiveController),
        ],
      ),
    );
  }
}

final detailscontroller = Get.put<Sellergoliveoverviewcontroller>(
  Sellergoliveoverviewcontroller(),
);
final yourLiveController = Get.find<Sellergolivecontroller>();
Widget _liveBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Text(
      "LIVE",
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _viewerCount(Sellergolivecontroller controller) {
  return Obx(
    () => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            "${controller.viewerCount.value}",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

Widget _endLiveButton(RtcEngine engine, BuildContext context) {
  return GestureDetector(
    onTap: () async {
      // Check if sessionId is not null or empty
      final sessionId = yourLiveController.sessionId.value;
      if (sessionId.isNotEmpty) {
        await detailscontroller.fetchLiveDetails(sessionId);
      } else {
        log("Session ID is null or empty");
      }

      await engine.leaveChannel();

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Sellergoliveoverview()),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('End Live', style: TextStyle(color: Colors.white)),
    ),
  );
}

/// 🎥 ICON BUTTON
Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
      radius: 24,
      backgroundColor: Colors.black54,
      child: Icon(icon, color: Colors.white),
    ),
  );
}

/// 🛒 PRODUCT PANEL
Widget _productBottomSheet(Sellergolivecontroller controller) {
  return DraggableScrollableSheet(
    initialChildSize: 0.15,
    minChildSize: 0.15,
    maxChildSize: 0.5,
    builder: (context, scrollController) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Products",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            /// PRODUCT LIST
            Expanded(
              child: Obx(
                () => ListView.builder(
                  controller: scrollController,
                  itemCount: controller.selectedProducts.length,
                  itemBuilder: (context, index) {
                    final product = controller.selectedProducts[index];
                    return _productTile(product);
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// 🧾 PRODUCT TILE
Widget _productTile(dynamic product) {
  return Card(
    child: ListTile(
      leading: Image.network(
        product.images[0].url,
        width: 50,
        fit: BoxFit.cover,
      ),
      title: Text(product.name),
      subtitle: Text("₹${product.discountedPrice}"),
    ),
  );
}
