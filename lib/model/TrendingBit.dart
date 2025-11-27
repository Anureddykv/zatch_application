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
  });

  factory TrendingBit.fromJson(Map<String, dynamic> json) {
    String getUrl(String key) {
      if (json.containsKey(key) && json[key] is Map) {
        return json[key]['url'] ?? '';
      }
      return '';
    }

    return TrendingBit(
      id: json['_id'] as String,
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      videoUrl: getUrl('video'),
      thumbnailUrl: getUrl('thumbnail'),
      badge: json['badge'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      shareLink: json['shareLink'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isLive: json['isLive'] ?? false,
    );
  }
}
