class LiveSummaryModel {
  final bool success;
  final String message;
  final PerformanceSummary performanceSummary;
  final List<LiveItem> upcomingLives;
  final List<LiveItem> pastLives;

  LiveSummaryModel({
    required this.success,
    required this.message,
    required this.performanceSummary,
    required this.upcomingLives,
    required this.pastLives,
  });

  factory LiveSummaryModel.fromJson(Map<String, dynamic> json) {
    return LiveSummaryModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      performanceSummary: PerformanceSummary.fromJson(
        json['performanceSummary'] ?? {},
      ),
      upcomingLives:
          (json['upcomingLives'] as List? ?? [])
              .map((e) => LiveItem.fromJson(e))
              .toList(),
      pastLives:
          (json['pastLives'] as List? ?? [])
              .map((e) => LiveItem.fromJson(e))
              .toList(),
    );
  }
}

class PerformanceSummary {
  final int views;
  final String viewsChange;
  final String revenue;
  final String revenueChange;
  final String avgEngagement;
  final String engagementChange;
  final int totalDuration;
  final String totalDurationFormatted;

  PerformanceSummary({
    required this.views,
    required this.viewsChange,
    required this.revenue,
    required this.revenueChange,
    required this.avgEngagement,
    required this.engagementChange,
    required this.totalDuration,
    required this.totalDurationFormatted,
  });

  factory PerformanceSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceSummary(
      views: json['views'] ?? 0,
      viewsChange: json['viewsChange'] ?? '0%',
      revenue: json['revenue'] ?? '₹0.00',
      revenueChange: json['revenueChange'] ?? '0%',
      avgEngagement: json['avgEngagement'] ?? '0%',
      engagementChange: json['engagementChange'] ?? '0%',
      totalDuration: json['totalDuration'] ?? 0,
      totalDurationFormatted: json['totalDurationFormatted'] ?? '0s',
    );
  }
}

class LiveItem {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledStartTime;
  final Thumbnail thumbnail;
  final int queuePosition;
  final String status;
  final int productsCount;
  final String shareLink;
  final List<String> actions;

  LiveItem({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledStartTime,
    required this.thumbnail,
    required this.queuePosition,
    required this.status,
    required this.productsCount,
    required this.shareLink,
    required this.actions,
  });

  factory LiveItem.fromJson(Map<String, dynamic> json) {
    return LiveItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      scheduledStartTime:
          DateTime.tryParse(json['scheduledStartTime'] ?? '') ?? DateTime.now(),
      thumbnail: Thumbnail.fromJson(json['thumbnail'] ?? {}),
      queuePosition: json['queuePosition'] ?? 0,
      status: json['status'] ?? '',
      productsCount: json['productsCount'] ?? 0,
      shareLink: json['shareLink'] ?? '',
      actions: List<String>.from(json['actions'] ?? []),
    );
  }
}
class Thumbnail {
  final String publicId;
  final String url;

  Thumbnail({required this.publicId, required this.url});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(publicId: json['public_id'] ?? '', url: json['url'] ?? '');
  }
}
