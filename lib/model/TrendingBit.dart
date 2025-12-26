import 'product_response.dart';

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
  final double price;
  final double rating;
  final bool isLiked;
  final String creatorId;
  final String creatorUsername;
  final String? category;
  final List<Product> products; // Added products list

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
    this.category,
    this.products = const [],
  });

  factory TrendingBit.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'bit';
    final bool isLive = type == 'live';
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final creator = (json['creator'] ?? json['host']) as Map<String, dynamic>? ?? {};

    // Extract Category
    String? category;
    if (json['category'] != null) {
      if (json['category'] is String) {
        category = json['category'];
      } else if (json['category'] is Map) {
        category = json['category']['name'] ?? json['category']['_id'] ?? json['category']['slug'];
      }
    }

    // Parse Products
    List<Product> products = [];
    if (json['products'] != null && json['products'] is List) {
      products = (json['products'] as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Fallback for category: check products if top-level category is missing
    if (category == null && products.isNotEmpty) {
      category = products.first.category;
    }

    return TrendingBit(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      videoUrl: json['video'] as String? ?? '',
      thumbnailUrl: json['thumbnail'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
      isLive: isLive,
      likeCount: stats['likes'] as int? ?? 0,
      viewCount: (isLive ? stats['currentViewers'] : stats['views']) as int? ?? 0,
      shareCount: stats['shares'] as int? ?? 0,
      shareLink: json['shareLink'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isLiked: json['isLiked'] as bool? ?? false,
      creatorId: creator['_id'] as String? ?? '',
      creatorUsername: creator['username'] as String? ?? 'Unknown',
      category: category,
      products: products,
    );
  }
}
