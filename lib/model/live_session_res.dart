// Removed unnecessary import 'dart:ffi';

import 'dart:convert';

class LiveSessionsResponse {
  final bool success;
  final List<Session> sessions;

  LiveSessionsResponse({
    required this.success,
    required this.sessions,
  });

  factory LiveSessionsResponse.fromJson(Map<String, dynamic> json) {
    return LiveSessionsResponse(
      success: json['success'] ?? false,
      sessions: (json['sessions'] as List<dynamic>?)
          ?.map((e) => Session.fromJson(e as Map<String, dynamic>)) // Added type cast
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'sessions': sessions.map((e) => e.toJson()).toList(),
    };
  }
}

class Session {
  final String id;
  final String title;
  final String? description;
  final String status;
   int viewersCount;
  final String? startTime; // for live/upcoming
  final String? scheduledStartTime; // for scheduled
  final String? channelName;
  final Host? host;
  final String? thumbnail;

  Session({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.viewersCount,
    this.startTime,
    this.scheduledStartTime,
    this.channelName,
    this.host,
    this.thumbnail,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      viewersCount: json['viewersCount'] ?? 0,
      startTime: json['startTime'],
      scheduledStartTime: json['scheduledStartTime'],
      channelName: json['channelName'],
      host: json['hostId'] != null && json['hostId'] is Map<String, dynamic>
          ? Host.fromJson(json['hostId'])
          : null,
      thumbnail: json['thumbnail'] is String ? json['thumbnail'] : null,    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'status': status,
      'viewersCount': viewersCount,
      'startTime': startTime,
      'scheduledStartTime': scheduledStartTime,
      'channelName': channelName,
      'host': host?.toJson(),
      'thumbnail': thumbnail,
    };
  }
}

class Host {
  final String id;
  final String username;
  final String? profilePicUrl;
  final dynamic rating;

  Host({
    required this.id,
    required this.username,
    this.profilePicUrl,
    this.rating,
  });

  factory Host.fromJson(Map<String, dynamic> json) {
    // Safely get profile picture URL, assuming it could be in a nested object.
    String? picUrl;
    if (json['profilePic'] is Map) {
      picUrl = json['profilePic']['url'];
    } else if (json['profilePicUrl'] is String) {
      picUrl = json['profilePicUrl'];
    }

    return Host(
      id: json['_id'] as String? ?? '',
      username: json['username'] as String? ?? 'Unknown',
      profilePicUrl: picUrl,
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'profilePicUrl': profilePicUrl,
      'rating': rating,
    };
  }
}

SessionDetails sessionDetailsFromApiResponse(String str) {
  final jsonData = json.decode(str);
  if (jsonData['success'] == true && jsonData['sessionDetails'] != null) {
    return SessionDetails.fromJson(jsonData['sessionDetails']);
  } else {
    throw Exception("Failed to parse session details from API response or success was false.");
  }
}

class SessionDetails {
  final String id;
  final String channelName;
  final String title;
  final String description;
  final Host host;
  final String status;
  final DateTime scheduledStartTime;
  final int viewersCount;
  final int peakViewers;
  final List<String> products;
  final String? thumbnail;
  final bool isLive;
  final bool isHost;
  final String shareLink;

  SessionDetails({
    required this.id,
    required this.channelName,
    required this.title,
    required this.description,
    required this.host,
    required this.status,
    required this.scheduledStartTime,
    required this.viewersCount,
    required this.peakViewers,
    required this.products,
    this.thumbnail,
    required this.isLive,
    required this.isHost,
    required this.shareLink,
  });

  factory SessionDetails.fromJson(Map<String, dynamic> json) {
    return SessionDetails(
      id: json["_id"],
      channelName: json["channelName"],
      title: json["title"],
      description: json["description"],
      host: Host.fromJson(json["host"]),
      status: json["status"],
      scheduledStartTime: DateTime.parse(json["scheduledStartTime"]),
      viewersCount: json["viewersCount"],
      peakViewers: json["peakViewers"],
      // Safely parse the list of product strings
      products: List<String>.from(json["products"].map((x) => x)),
      thumbnail: json["thumbnail"],
      isLive: json["isLive"],
      isHost: json["isHost"],
      shareLink: json["shareLink"],
    );
  }
}

