class LiveDetailsResponse {
  final bool success;
  final LiveSessionDetails sessionDetails;

  LiveDetailsResponse({required this.success, required this.sessionDetails});

  factory LiveDetailsResponse.fromJson(Map<String, dynamic> json) {
    return LiveDetailsResponse(
      success: json['success'] ?? false,
      sessionDetails: LiveSessionDetails.fromJson(json['sessionDetails'] ?? {}),
    );
  }
}

class LiveSessionDetails {
  final String id;
  final String channelName;
  final String title;
  final String description;
  final LiveHostDetails host;
  final String status;
  final int viewersCount;
  final int peakViewers;
  final LiveThumbnail thumbnail;
  final bool isLive;
  final bool isHost;
  final int likeCount;
  final bool isLiked;
  final LiveStatsSummary statsSummary;
  final List<LiveProductDetails> products;
  final List<dynamic> comments;
  final List<dynamic> orders;

  LiveSessionDetails({
    required this.id,
    required this.channelName,
    required this.title,
    required this.description,
    required this.host,
    required this.status,
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
  });

  factory LiveSessionDetails.fromJson(Map<String, dynamic> json) {
    return LiveSessionDetails(
      id: json['_id'] ?? '',
      channelName: json['channelName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      host: LiveHostDetails.fromJson(json['host'] ?? {}),
      status: json['status'] ?? '',
      viewersCount: json['viewersCount'] ?? 0,
      peakViewers: json['peakViewers'] ?? 0,
      thumbnail: LiveThumbnail.fromJson(json['thumbnail'] ?? {}),
      isLive: json['isLive'] ?? false,
      isHost: json['isHost'] ?? false,
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      statsSummary: LiveStatsSummary.fromJson(json['statsSummary'] ?? {}),
      products:
          (json['products'] as List<dynamic>? ?? [])
              .map((e) => LiveProductDetails.fromJson(e))
              .toList(),
      comments: json['comments'] ?? [],
      orders: json['orders'] ?? [],
    );
  }
}

class LiveHostDetails {
  final String id;
  final String username;
  final String name;
  final LiveThumbnail profilePic;

  LiveHostDetails({
    required this.id,
    required this.username,
    required this.name,
    required this.profilePic,
  });

  factory LiveHostDetails.fromJson(Map<String, dynamic> json) {
    return LiveHostDetails(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      profilePic: LiveThumbnail.fromJson(json['profilePic'] ?? {}),
    );
  }
}

class LiveThumbnail {
  final String publicId;
  final String url;

  LiveThumbnail({required this.publicId, required this.url});

  factory LiveThumbnail.fromJson(Map<String, dynamic> json) {
    return LiveThumbnail(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class LiveStatsSummary {
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

  LiveStatsSummary({
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

  factory LiveStatsSummary.fromJson(Map<String, dynamic> json) {
    return LiveStatsSummary(
      views: json['views'] ?? 0,
      viewsChange: json['viewsChange'] ?? '',
      revenue: json['revenue'] ?? 0,
      revenueChange: json['revenueChange'] ?? '',
      avgEngagement: json['avgEngagement'] ?? 0,
      engagementChange: json['engagementChange'] ?? '',
      totalOrders: json['totalOrders'] ?? 0,
      ordersChange: json['ordersChange'] ?? '',
      addToCarts: json['addToCarts'] ?? 0,
      addToCartsChange: json['addToCartsChange'] ?? '',
      zatches: json['zatches'] ?? 0,
      zatchesChange: json['zatchesChange'] ?? '',
    );
  }
}

class LiveProductDetails {
  final String id;
  final String name;
  final int price;
  final int discountedPrice;
  final List<LiveThumbnail> images;
  final String category;
  final String subCategory;
  final List<LiveProductVariant> variants;
  final int stock;
  final LiveBargainSettings bargainSettings;

  LiveProductDetails({
    required this.id,
    required this.name,
    required this.price,
    required this.discountedPrice,
    required this.images,
    required this.category,
    required this.subCategory,
    required this.variants,
    required this.stock,
    required this.bargainSettings,
  });

  factory LiveProductDetails.fromJson(Map<String, dynamic> json) {
    return LiveProductDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      discountedPrice: json['discountedPrice'] ?? 0,
      images:
          (json['images'] as List<dynamic>? ?? [])
              .map((e) => LiveThumbnail.fromJson(e))
              .toList(),
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      variants:
          (json['variants'] as List<dynamic>? ?? [])
              .map((e) => LiveProductVariant.fromJson(e))
              .toList(),
      stock: json['stock'] ?? 0,
      bargainSettings: LiveBargainSettings.fromJson(
        json['bargainSettings'] ?? {},
      ),
    );
  }
}

class LiveProductVariant {
  final String color;
  final String sku;
  final int stock;
  final List<LiveThumbnail> images;

  LiveProductVariant({
    required this.color,
    required this.sku,
    required this.stock,
    required this.images,
  });

  factory LiveProductVariant.fromJson(Map<String, dynamic> json) {
    return LiveProductVariant(
      color: json['color'] ?? '',
      sku: json['SKU'] ?? '',
      stock: json['stock'] ?? 0,
      images:
          (json['images'] as List<dynamic>? ?? [])
              .map((e) => LiveThumbnail.fromJson(e))
              .toList(),
    );
  }
}

class LiveBargainSettings {
  final int autoAcceptDiscount;
  final int maximumDiscount;

  LiveBargainSettings({
    required this.autoAcceptDiscount,
    required this.maximumDiscount,
  });

  factory LiveBargainSettings.fromJson(Map<String, dynamic> json) {
    return LiveBargainSettings(
      autoAcceptDiscount: json['autoAcceptDiscount'] ?? 0,
      maximumDiscount: json['maximumDiscount'] ?? 0,
    );
  }
}
