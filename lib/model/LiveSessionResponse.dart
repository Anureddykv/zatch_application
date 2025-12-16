import 'package:zatch_app/model/product_response.dart';

import 'ExploreApiRes.dart';
import 'live_comment.dart';

class LiveSessionDetailsResponse {
  final bool success;
  final SessionDetails sessionDetails;

  LiveSessionDetailsResponse({
    required this.success,
    required this.sessionDetails,
  });

  factory LiveSessionDetailsResponse.fromJson(Map<String, dynamic> json) {
    return LiveSessionDetailsResponse(
      success: json['success'] as bool? ?? false,
      sessionDetails: SessionDetails.fromJson(json['sessionDetails'] ?? {}),
    );
  }
}

class SessionDetails {
  final String id;
  final String channelName;
  final String title;
  final String description;
  final Host host;
  final String status;
  final DateTime startTime;
  final int viewersCount;
  final int peakViewers;
  final Thumbnail thumbnail;
  final bool isLive;
  final bool isHost;

  final int likeCount;
  final bool isLiked;

  final StatsSummary statsSummary;
  final List<Product> products;
  final List<LiveComment> comments;
  final List<dynamic> orders;
  final String? shareLink;

  SessionDetails({
    required this.id,
    required this.channelName,
    required this.title,
    required this.description,
    required this.host,
    required this.status,
    required this.startTime,
    required this.viewersCount,
    required this.peakViewers,
    required this.thumbnail,
    required this.isLive,
    required this.isHost,
    required this.likeCount,
    required this.isLiked,
    required this.statsSummary,
    required this.products,
    required this.comments,
    required this.orders,
    this.shareLink,
  });

  factory SessionDetails.fromJson(Map<String, dynamic> json) {
    return SessionDetails(
      id: json['_id'] as String? ?? '',
      channelName: json['channelName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      host: Host.fromJson(json['host'] ?? {}),
      status: json['status'] as String? ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      viewersCount: (json['viewersCount'] as num?)?.toInt() ?? 0,
      peakViewers: (json['peakViewers'] as num?)?.toInt() ?? 0,
      thumbnail: Thumbnail.fromJson(json['thumbnail'] ?? {}),
      isLive: json['isLive'] as bool? ?? false,
      isHost: json['isHost'] as bool? ?? false,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0, // Parsed
      isLiked: json['isLiked'] as bool? ?? false,           // Parsed
      statsSummary: StatsSummary.fromJson(json['statsSummary'] ?? {}),
      products: (json['products'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((e) => LiveComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      orders: json['orders'] as List<dynamic>? ?? [],
      shareLink: json['shareLink'] as String?,
    );
  }
}

class Host {
  final String id;
  final String username;
  final String name;
  final ProfilePic profilePic;

  Host({
    required this.id,
    required this.username,
    required this.name,
    required this.profilePic,
  });

  factory Host.fromJson(Map<String, dynamic> json) {
    return Host(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      profilePic: ProfilePic.fromJson(json['profilePic'] ?? {}),
    );
  }
}

class StatsSummary {
  final int views;
  final String viewsChange;
  final int revenue;
  final String revenueChange;
  final int avgEngagement;
  final String engagementChange;
  final int totalOrders;
  final String ordersChange;
  final int addToCarts;
  final String addToCartsChange;
  final int zatches;
  final String zatchesChange;

  StatsSummary({
    required this.views,
    required this.viewsChange,
    required this.revenue,
    required this.revenueChange,
    required this.avgEngagement,
    required this.engagementChange,
    required this.totalOrders,
    required this.ordersChange,
    required this.addToCarts,
    required this.addToCartsChange,
    required this.zatches,
    required this.zatchesChange,
  });

  factory StatsSummary.fromJson(Map<String, dynamic> json) {
    return StatsSummary(
      views: json['views'] as int? ?? 0,
      viewsChange: json['viewsChange'] as String? ?? '',
      revenue: json['revenue'] as int? ?? 0,
      revenueChange: json['revenueChange'] as String? ?? '',
      avgEngagement: json['avgEngagement'] as int? ?? 0,
      engagementChange: json['engagementChange'] as String? ?? '',
      totalOrders: json['totalOrders'] as int? ?? 0,
      ordersChange: json['ordersChange'] as String? ?? '',
      addToCarts: json['addToCarts'] as int? ?? 0,
      addToCartsChange: json['addToCartsChange'] as String? ?? '',
      zatches: json['zatches'] as int? ?? 0,
      zatchesChange: json['zatchesChange'] as String? ?? '',
    );
  }
}

class CommentUser {
  final String id;
  final String username;
  final ProfilePic profilePic;

  CommentUser({
    required this.id,
    required this.username,
    required this.profilePic,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['_id'] ?? '',
      username: json['username'] ?? 'Unknown',
      profilePic: ProfilePic.fromJson(json['profilePic'] ?? {}),
    );
  }
}
class JoinLiveSessionResponse {
  final bool success;
  final JoinSession session;

  JoinLiveSessionResponse({
    required this.success,
    required this.session,
  });

  factory JoinLiveSessionResponse.fromJson(Map<String, dynamic> json) {
    return JoinLiveSessionResponse(
      success: json['success'] ?? false,
      session: JoinSession.fromJson(json['session'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'session': session.toJson(),
    };
  }
}

class JoinSession {
  final String channelName;
  final String title;
  final String description;
  final String hostId;
  final String token;
  final int uid;
  final String appId;
  final int expiresAt;
  final int expiresIn;
  final Stats stats;

  JoinSession({
    required this.channelName,
    required this.title,
    required this.description,
    required this.hostId,
    required this.token,
    required this.uid,
    required this.appId,
    required this.expiresAt,
    required this.expiresIn,
    required this.stats,
  });

  factory JoinSession.fromJson(Map<String, dynamic> json) {
    return JoinSession(
      channelName: json['channelName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      hostId: json['hostId'] ?? '',
      token: json['token'] ?? '',
      uid: json['uid'] ?? 0,
      appId: json['appId'] ?? '',
      expiresAt: json['expiresAt'] ?? 0,
      expiresIn: json['expiresIn'] ?? 0,
      stats: Stats.fromJson(json['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channelName': channelName,
      'title': title,
      'description': description,
      'hostId': hostId,
      'token': token,
      'uid': uid,
      'appId': appId,
      'expiresAt': expiresAt,
      'expiresIn': expiresIn,
      'stats': stats.toJson(),
    };
  }
}

class Stats {
  final int currentViewers;
  final int totalViews;
  final int peakViewers;

  Stats({
    required this.currentViewers,
    required this.totalViews,
    required this.peakViewers,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      currentViewers: json['currentViewers'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      peakViewers: json['peakViewers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentViewers': currentViewers,
      'totalViews': totalViews,
      'peakViewers': peakViewers,
    };
  }
}
