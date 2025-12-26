class NotificationResponse {
  final bool success;
  final List<AppNotification> notifications;
  final int unreadCount;
  final Pagination? pagination;

  NotificationResponse({
    required this.success,
    required this.notifications,
    required this.unreadCount,
    this.pagination,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      notifications: (json['notifications'] as List? ?? [])
          .map((e) => AppNotification.fromJson(e))
          .toList(),
      unreadCount: json['unreadCount'] ?? 0,
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String? type;
  final bool isRead;
  final DateTime createdAt;
  final String? actionUrl;
  final String? actionLabel;
  final String? referenceId;
  final String? referenceModel;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    required this.isRead,
    required this.createdAt,
    this.actionUrl,
    this.actionLabel,
    this.referenceId,
    this.referenceModel,
    this.metadata,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      actionUrl: json['actionUrl'],
      actionLabel: json['actionLabel'],
      referenceId: json['referenceId'],
      referenceModel: json['referenceModel'],
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}
