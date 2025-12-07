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
      upcomingLives: (json['upcomingLives'] as List? ?? [])
          .map((e) => LiveItem.fromJson(e))
          .toList(),
      pastLives: (json['pastLives'] as List? ?? [])
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
  final String dateTime;
  final String thumbnail;
  final int expectedViews;

  LiveItem({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.thumbnail,
    required this.expectedViews,
  });

  factory LiveItem.fromJson(Map<String, dynamic> json) {
    return LiveItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      dateTime: json['dateTime'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      expectedViews: json['expectedViews'] ?? 0,
    );
  }
}
