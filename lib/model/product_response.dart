import 'ExploreApiRes.dart';

class ProductResponse {
  final bool success;
  final String message;
  final List<Product> products;

  ProductResponse({
    required this.success,
    required this.message,
    required this.products,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    List<Product> parsedProducts = [];

    if (json['products'] != null) {
      // List of products
      parsedProducts = (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e))
          .toList();
    } else if (json['product'] != null) {
      // Single product
      parsedProducts = [Product.fromJson(json['product'])];
    }

    return ProductResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      products: parsedProducts,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final List<ProductImage> images;
  final String? category;
  final String? subCategory;
  final String? productCategory;
  final List<ProductVariant> variants;
  final bool isTopPick;
  final int saveCount;
  final int likeCount;
  final int viewCount;
  final int commentCount;
  final double averageRating;
  final int totalStock;
  final Seller? seller;
  final List<Review> reviews;
  final List<Comment> comments;
  final bool isSaved;
  final bool isLiked;
  final BargainSettings? bargainSettings;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.images,
    required this.reviews,
     this.category,
     this.subCategory,
     this.productCategory,
    required this.variants,
    required this.isTopPick,
    required this.saveCount,
    required this.likeCount,
    required this.viewCount,
    required this.commentCount,
    required this.averageRating,
    required this.totalStock,
    this.seller,
    this.comments = const [],
    this.isSaved = false,
    this.isLiked = false,
    this.bargainSettings,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ProductImage.fromJson(e))
          .toList(),
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      productCategory: json['productCategory'] ?? '',
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((e) => ProductVariant.fromJson(e))
          .toList(),
      isTopPick: json['isTopPick'] ?? false,
      saveCount: json['saveCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),
      commentCount: json['commentCount'] ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalStock: json['totalStock'] ?? 0,
      seller: json['seller'] != null ? Seller.fromJson(json['seller']) : null,
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((e) => Comment.fromJson(e))
          .toList(),
      isSaved: json['isSaved'] ?? false,
      isLiked: json['isLiked'] ?? false,
      bargainSettings: json['bargainSettings'] != null
          ? BargainSettings.fromJson(json['bargainSettings'])
          : null,
    );
  }
}

class ProductVariant {
  final String? color;
  final String? shade;
  final String? size;
  final String sku;
  final int stock;
  final List<ProductImage> images;

  ProductVariant({
    this.color,
    this.shade,
    this.size,
    required this.sku,
    required this.stock,
    required this.images,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      color: json['color'],
      shade: json['shade'],
      size: json['size'],
      sku: json['SKU'] ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ProductImage.fromJson(e))
          .toList(),
    );
  }
}

class ProductImage {
  final String publicId;
  final String url;
  final String id;

  ProductImage({
    required this.publicId,
    required this.url,
    required this.id,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}

class Seller {
  final String id;
  final String username;
  final ProfilePic profilePic;

  Seller({
    required this.id,
    required this.username,
    required this.profilePic,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      profilePic: ProfilePic.fromJson(json['profilePic'] ?? {}),
    );
  }
}

class ProfilePic {
  final String publicId;
  final String url;

  ProfilePic({
    required this.publicId,
    required this.url,
  });

  factory ProfilePic.fromJson(Map<String, dynamic> json) {
    return ProfilePic(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class BargainSettings {
  final double autoAcceptDiscount;
  final double maximumDiscount;

  BargainSettings({
    required this.autoAcceptDiscount,
    required this.maximumDiscount,
  });

  factory BargainSettings.fromJson(Map<String, dynamic> json) {
    return BargainSettings(
      autoAcceptDiscount: (json['autoAcceptDiscount'] as num?)?.toDouble() ?? 0,
      maximumDiscount: (json['maximumDiscount'] as num?)?.toDouble() ?? 0,
    );
  }
}
