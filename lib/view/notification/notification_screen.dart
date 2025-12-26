import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zatch/model/notification_model.dart';
import 'package:zatch/services/api_service.dart';
import 'package:zatch/utils/snackbar_utils.dart';
import 'package:zatch/view/home_page.dart';
import 'package:zatch/view/order_view/order_screen.dart';
import 'package:zatch/view/setting_view/change_password_screen.dart';
import 'package:zatch/view/zatching_details_screen.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ApiService _apiService = ApiService();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await _apiService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = response.notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarUtils.showTopSnackBar(context, "Failed to load notifications: $e", isError: true);
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final success = await _apiService.markAllNotificationsAsRead();
      if (success && mounted) {
        _fetchNotifications();
        SnackBarUtils.showTopSnackBar(context, "All marked as read");
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showTopSnackBar(context, "Failed to mark as read: $e", isError: true);
      }
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      final success = await _apiService.deleteNotification(id);
      if (success && mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.id == id);
        });
        SnackBarUtils.showTopSnackBar(context, "Notification deleted");
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showTopSnackBar(context, "Failed to delete: $e", isError: true);
      }
    }
  }

  void _onBackTap(BuildContext context) {
    if (homePageKey.currentState != null && homePageKey.currentState!.hasSubScreen) {
      homePageKey.currentState!.closeSubScreen();
    } else {
      Navigator.pop(context);
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    Widget? targetScreen;

    // 1. Determine target screen based on referenceModel or type
    if (notification.referenceModel == 'Bargain' || (notification.type?.contains('bargain') ?? false)) {
      if (notification.referenceId != null && notification.referenceId!.isNotEmpty) {
        targetScreen = ZatchingDetailsScreen(bargainId: notification.referenceId!);
      }
    } else if (notification.referenceModel == 'Order' || 
               (notification.type?.contains('order') ?? false) || 
               (notification.type?.contains('delivery') ?? false)) {
      targetScreen = const OrdersScreen();
    } else if (notification.type == 'password_changed') {
      targetScreen = const ChangePasswordScreen();
    }

    // 2. Navigate if a target was found
    if (targetScreen != null) {
      if (homePageKey.currentState != null) {
        homePageKey.currentState!.navigateToSubScreen(targetScreen);
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen!));
      }
    } else {
      debugPrint("No target screen defined for notification type: ${notification.type}");
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} mins ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'order_placed':
      case 'order_success':
        return Icons.check_circle;
      case 'order_cancelled':
        return Icons.cancel;
      case 'bargain_sent':
      case 'bargain_countered':
        return Icons.sync;
      case 'password_changed':
        return Icons.lock_outline;
      case 'announcement':
        return Icons.announcement;
      case 'promotion':
        return Icons.card_giftcard;
      case 'delivery':
        return Icons.local_shipping;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColorForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'order_placed':
      case 'order_success':
        return Colors.green;
      case 'order_cancelled':
      case 'announcement':
      case 'promotion':
      case 'delivery':
        return Colors.red;
      case 'bargain_sent':
      case 'bargain_countered':
        return Colors.teal;
      case 'password_changed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.black),
              onPressed: _markAllAsRead,
              tooltip: "Mark all as read",
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _notifications.isEmpty
              ? RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      const Center(
                        child: Text(
                          "No notifications yet",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  color: Colors.black,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteNotification(item.id),
                        child: Column(
                          children: [
                            Divider(height: 1, color: Colors.grey.shade300),
                            ListTile(
                              onTap: () => _handleNotificationTap(item),
                              tileColor: item.isRead ? Colors.transparent : Colors.blue.withOpacity(0.05),
                              leading: CircleAvatar(
                                backgroundColor: _getIconColorForType(item.type).withOpacity(0.15),
                                child: Icon(_getIconForType(item.type), color: _getIconColorForType(item.type)),
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                item.message,
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                _formatTime(item.createdAt),
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                            if (index == _notifications.length - 1) Divider(height: 1, color: Colors.grey.shade300)
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
