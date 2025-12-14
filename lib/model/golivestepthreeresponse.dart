// GoLiveSuccessResponseModel.dart

class GoLiveSuccessResponseModel {
  final bool success;
  final String message;
  final LiveSession session;
  final AgoraCredentials? agoraCredentials;

  GoLiveSuccessResponseModel({
    required this.success,
    required this.message,
    required this.session,
    required this.agoraCredentials,
  });

  factory GoLiveSuccessResponseModel.fromJson(Map<String, dynamic> json) {
    return GoLiveSuccessResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      session: LiveSession.fromJson(json['session']),

      // FIX: Handle null agoraCredentials
      agoraCredentials:
          json['agoraCredentials'] == null
              ? null
              : AgoraCredentials.fromJson(json['agoraCredentials']),
    );
  }
}

// ---------------------------------------------
// Live Session
// ---------------------------------------------
class LiveSession {
  final String id;
  final String channelName;
  final String hostId;
  final String title;
  final String description;
  final String scheduledStartTime;
  final String? startTime;
  final String status;
  final int queuePosition;
  final List<String> hashtags;
  final Thumbnail thumbnail;
  final List<LiveProduct> products;
  final List<String> productSequence;
  final int viewersCount;
  final bool isActive;

  LiveSession({
    required this.id,
    required this.channelName,
    required this.hostId,
    required this.title,
    required this.description,
    required this.scheduledStartTime,
    required this.startTime,
    required this.status,
    required this.queuePosition,
    required this.hashtags,
    required this.thumbnail,
    required this.products,
    required this.productSequence,
    required this.viewersCount,
    required this.isActive,
  });

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      id: json['_id'] ?? "",
      channelName: json['channelName'] ?? "",
      hostId: json['hostId'] ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      scheduledStartTime: json['scheduledStartTime'] ?? "",

      // FIXED: missing in API
      startTime: json['startTime'],

      status: json['status'] ?? "",
      queuePosition: json['queuePosition'] ?? 0,
      hashtags: List<String>.from(json['hashtags'] ?? []),
      thumbnail: Thumbnail.fromJson(json['thumbnail'] ?? {}),

      products:
          (json['products'] as List? ?? [])
              .map((e) => LiveProduct.fromJson(e))
              .toList(),

      productSequence: List<String>.from(json['productSequence'] ?? []),

      viewersCount: json['viewersCount'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }
}

// ---------------------------------------------
// Thumbnail
// ---------------------------------------------
class Thumbnail {
  final String? publicId;
  final String? url;

  Thumbnail({required this.publicId, required this.url});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      publicId: json['public_id'],
      url:
          (json['url'] != null && json['url'].toString().isNotEmpty)
              ? json['url']
              : null, // FIX prevents image:// error
    );
  }
}

// ---------------------------------------------
// Product
// ---------------------------------------------
class LiveProduct {
  final String id;
  final BargainSettings bargainSettings;
  final String productCategory;
  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final String name;
  final String description;
  final int price;
  final int discountedPrice;
  final String category;
  final String subCategory;

  LiveProduct({
    required this.id,
    required this.bargainSettings,
    required this.productCategory,
    required this.images,
    required this.variants,
    required this.name,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.category,
    required this.subCategory,
  });

  factory LiveProduct.fromJson(Map<String, dynamic> json) {
    return LiveProduct(
      id: json['_id'],
      bargainSettings: BargainSettings.fromJson(json['bargainSettings']),
      productCategory: json['productCategory'],
      images:
          (json['images'] as List)
              .map((e) => ProductImage.fromJson(e))
              .toList(),
      variants:
          (json['variants'] as List)
              .map((e) => ProductVariant.fromJson(e))
              .toList(),
      name: json['name'],
      description: json['description'],
      price: json['price'],
      discountedPrice: json['discountedPrice'],
      category: json['category'],
      subCategory: json['subCategory'],
    );
  }
}

// Bargain Settings
class BargainSettings {
  final int autoAcceptDiscount;
  final int maximumDiscount;

  BargainSettings({
    required this.autoAcceptDiscount,
    required this.maximumDiscount,
  });

  factory BargainSettings.fromJson(Map<String, dynamic> json) {
    return BargainSettings(
      autoAcceptDiscount: json['autoAcceptDiscount'],
      maximumDiscount: json['maximumDiscount'],
    );
  }
}

// Product Image
class ProductImage {
  final String? publicId;
  final String? url;
  final String id;
  ProductImage({this.publicId, this.url, required this.id});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      publicId: json['public_id'],
      url:
          (json['url'] != null && json['url'].toString().isNotEmpty)
              ? json['url']
              : null,
      id: json['_id'],
    );
  }
}

// Product Variant
class ProductVariant {
  final String color;
  final String sku;
  final int stock;
  final List<ProductImage> images;

  ProductVariant({
    required this.color,
    required this.sku,
    required this.stock,
    required this.images,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      color: json['color'],
      sku: json['SKU'],
      stock: json['stock'],
      images:
          (json['images'] as List)
              .map((e) => ProductImage.fromJson(e))
              .toList(),
    );
  }
}

// ---------------------------------------------
// Agora Credentials
// ---------------------------------------------
class AgoraCredentials {
  final String token;
  final String channelName;
  final String appId;
  final int uid;
  final int expiresAt;
  final int expiresIn;

  AgoraCredentials({
    required this.token,
    required this.channelName,
    required this.appId,
    required this.uid,
    required this.expiresAt,
    required this.expiresIn,
  });

  factory AgoraCredentials.fromJson(Map<String, dynamic> json) {
    return AgoraCredentials(
      token: json['token'],
      channelName: json['channelName'],
      appId: json['appId'],
      uid: json['uid'],
      expiresAt: json['expiresAt'],
      expiresIn: json['expiresIn'],
    );
  }
}
