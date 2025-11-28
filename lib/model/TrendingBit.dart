class TrendingBit {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String badge;
   int likeCount;
  final int viewCount;
  final int shareCount;
  final String shareLink;
  final DateTime createdAt;
  final bool isLive;
  final double price; // Assuming 0 for now as it's not in the API
  final double rating; // Assuming 0 for now as it's not in the API
  final bool isLiked;
  final String creatorId;
  final String creatorUsername;

  TrendingBit({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.badge,
    required this.likeCount,
    required this.viewCount,
    required this.shareCount,
    required this.shareLink,
    required this.createdAt,
    this.isLive = false,
    required this.price,
    required this.rating,
    required this.isLiked,
    required this.creatorId,
    required this.creatorUsername,
  });

  factory TrendingBit.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'bit';
    final bool isLive = type == 'live';
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final creator = (json['creator'] ?? json['host']) as Map<String, dynamic>? ?? {};

    return TrendingBit(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      // The new API provides direct URLs, not nested objects.
      videoUrl: json['video'] as String? ?? '',
      thumbnailUrl: json['thumbnail'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
      isLive: isLive,

      // Extract counts from the nested 'stats' object.
      likeCount: stats['likes'] as int? ?? 0,
      viewCount: (isLive ? stats['currentViewers'] : stats['views']) as int? ?? 0,
      shareCount: stats['shares'] as int? ?? 0,

      // This field is missing in the new API, so provide a default.
      shareLink: json['shareLink'] as String? ?? '',

      // Use DateTime.tryParse for crash-proof date handling.
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),

      // --- FIX 3: HANDLE MISSING DATA GRACEFULLY ---
      // Since the API doesn't provide these, we default them to 0.
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isLiked: json['isLiked'] as bool? ?? false, // API needs to send this
      creatorId: creator['_id'] as String? ?? '',
      creatorUsername: creator['username'] as String? ?? 'Unknown',

    );
  }
}
