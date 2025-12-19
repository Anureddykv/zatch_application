import 'package:flutter/material.dart';
import 'package:zatch_app/view/home_page.dart'; // Import this for homePageKey

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  void _onBackTap(BuildContext context) {
    if (homePageKey.currentState != null) {
      homePageKey.currentState!.closeSubScreen();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "icon": Icons.check_circle,
        "iconColor": Colors.green,
        "title": "Zatch Placed",
        "subtitle": "Your Zatch for order ID-1232134212 is placed successfully",
        "time": "2 days ago"
      },
      {
        "icon": Icons.flash_on,
        "iconColor": Colors.green,
        "title": "Zatch Successful",
        "subtitle": "Today’s the day. Your culinary adventure is almost there.",
        "time": "6 days ago"
      },
      {
        "icon": Icons.cancel,
        "iconColor": Colors.red,
        "title": "Zatch Not Approved",
        "subtitle": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque",
        "time": "11 days ago"
      },
      {
        "icon": Icons.sync,
        "iconColor": Colors.teal,
        "title": "Zatch countered",
        "subtitle": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque",
        "time": "13 days ago"
      },
      {
        "icon": Icons.announcement,
        "iconColor": Colors.red,
        "title": "Announcements",
        "subtitle": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque",
        "time": "9 days ago"
      },
      {
        "icon": Icons.fastfood,
        "iconColor": Colors.orange,
        "title": "Fresh Flavors Unveiled!",
        "subtitle": "New menu items are in! What will you try next?",
        "time": "4 days ago"
      },
      {
        "icon": Icons.card_giftcard,
        "iconColor": Colors.red,
        "title": "Weekend Bonus!",
        "subtitle": "Get 10% off on a surprise side for your next order.",
        "time": "11 days ago"
      },
      {
        "icon": Icons.local_shipping,
        "iconColor": Colors.red,
        "title": "Delivery Day!",
        "subtitle": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque",
        "time": "2 weeks ago"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _onBackTap(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Column(
            children: [
              Divider(height: 1, color: Colors.grey.shade300),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: (item["iconColor"] as Color).withOpacity(0.15),
                  child: Icon(item["icon"] as IconData?, color: item["iconColor"] as Color),
                ),
                title: Text(
                  item["title"] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  item["subtitle"] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                trailing: Text(
                  item["time"] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              if (index == notifications.length - 1) Divider(height: 1, color: Colors.grey.shade300) ],
          );
        },
      )
    );
  }
}
