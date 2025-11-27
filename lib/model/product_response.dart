import 'package:zatch_app/model/categories_response.dart';

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
    return ProductResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      products: (json['products'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<ProductImage> images;
  final Category? category;
  final int? stock;
  final String? condition;
  final String? color;
  final String? size;
  final String? info1;
  final String? info2;
  final bool? isTopPick;
  final int? saveCount;
  int? likeCount;
  final int? viewCount;
  final String? sellerId;
  final List<Review> reviews;
  final List<Comment>? comments;
  final int? commentCount;
  final double? averageRating;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.reviews,
    this.category,
    this.stock,
    this.condition,
    this.color,
    this.size,
    this.info1,
    this.info2,
    this.isTopPick,
    this.saveCount,
    this.likeCount,
    this.viewCount,
    this.sellerId,
    this.commentCount,
    this.comments,
    this.averageRating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      // Handles both int and double for price
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ProductImage.fromJson(e))
          .toList(),
      category: json['category'] != null
          ? (json['category'] is Map
          ? Category.fromJson(json['category'])
          : null)
          : null,
      stock: json['stock'],
      condition: json['condition'],
      color: json['color'],
      size: json['size'],
      info1: json['info1'],
      info2: json['info2'],
      isTopPick: json['isTopPick'] ?? false,
      saveCount: json['saveCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      sellerId: json['sellerId'],
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),
      commentCount: json['commentCount'] ?? 0,
      // The JSON has an empty 'comments' array, so we parse it.
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((e) => Comment.fromJson(e))
          .toList(),
    );
  }

  /// Returns a list of available colors (for compatibility with UI)
  List<String> get availableColors {
    return color != null ? [color!] : ['Black', 'Grey', 'Blue'];
  }

  /// Returns a list of available sizes (for compatibility with UI)
  List<String> get availableSizes {
    return size != null ? [size!] : ['S', 'M', 'L', 'XL'];
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

class Review {
  final String id;
  final Reviewer reviewerId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reviewerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      reviewerId: Reviewer.fromJson(json['reviewerId'] ?? {}),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class Reviewer {
  final ProfilePic profilePic;
  final String id;
  final String username;

  Reviewer({
    required this.profilePic,
    required this.id,
    required this.username,
  });

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(
      profilePic: ProfilePic.fromJson(json['profilePic'] ?? {}),
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
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
