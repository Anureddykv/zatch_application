import 'package:zatch_app/model/categories_response.dart';

import 'ExploreApiRes.dart';
// import 'ExploreApiRes.dart'; // Unused based on provided JSON, remove if not needed

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

    // Case 1: Response contains a list of products (e.g., /list)
    if (json['products'] != null) {
      parsedProducts = (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e))
          .toList();
    }
    // Case 2: Response contains a single product (e.g., /details)
    // We wrap it in a list to maintain consistency for the UI
    else if (json['product'] != null) {
      parsedProducts = [Product.fromJson(json['product'])];
    }

    return ProductResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      products: parsedProducts,
    );
  }
}

class ProductVariant {
  final String shade;
  final String sku;
  final int stock;
  final String? size; // Kept as nullable in case other products have size
  final List<ProductImage> images;

  ProductVariant({
    required this.shade,
    required this.sku,
    required this.stock,
    this.size,
    this.images = const [],
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      shade: json['shade'] ?? '',
      sku: json['SKU'] ?? '', // Note: API sends 'SKU' (uppercase)
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      size: json['size'],
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ProductImage.fromJson(e))
          .toList(),
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
  final Category? category;
  final SubCategory? subCategory; // Added based on JSON
  final int? totalStock;
  final List<ProductVariant> variants;
  final bool? isTopPick;
  final int? saveCount;
  final int? likeCount;
  final int? viewCount;
  final Seller? seller;
  final List<Review> reviews;
  final List<Comment>? comments;
  final int? commentCount;
  final double? averageRating;

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
    this.totalStock,
    required this.variants,
    this.isTopPick,
    this.saveCount,
    this.likeCount,
    this.viewCount,
    this.seller,
    this.commentCount,
    this.comments,
    this.averageRating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse Category (Can be String ID or Object based on API endpoint)
    Category? parsedCategory;
    final categoryData = json['category'];
    if (categoryData != null) {
      if (categoryData is Map<String, dynamic>) {
        // If name is missing in map, provide default
        if (categoryData['name'] == null && categoryData['name'] == "") {
          categoryData['name'] = "Unknown Category";
        }
        parsedCategory = Category.fromJson(categoryData);
      } else if (categoryData is String) {
        parsedCategory = Category(id: categoryData, name: categoryData);
      }
    }

    // Parse SubCategory
    SubCategory? parsedSubCategory;
    if (json['subCategory'] != null && json['subCategory'] is Map<String, dynamic>) {
      parsedSubCategory = SubCategory.fromJson(json['subCategory']);
    }

    // Parse Seller
    Seller? parsedSeller;
    final sellerData = json['seller'] ?? json['sellerId'];
    if (sellerData != null) {
      if (sellerData is Map<String, dynamic>) {
        parsedSeller = Seller.fromJson(sellerData);
      } else if (sellerData is String) {
        parsedSeller = Seller(
            id: sellerData,
            username: 'Unknown',
            profilePic: ProfilePic(publicId: '', url: ''));
      }
    }

    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ProductImage.fromJson(e))
          .toList(),
      category: parsedCategory,
      subCategory: parsedSubCategory,
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((e) => ProductVariant.fromJson(e))
          .toList(),
      totalStock: json['totalStock'] ?? json['stock'],
      isTopPick: json['isTopPick'] ?? false,
      saveCount: json['saveCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),
      commentCount: json['commentCount'] ?? 0,
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((e) => Comment.fromJson(e))
          .toList(),
      seller: parsedSeller,
    );
  }
}

class SubCategory {
  final String id;
  final String name;
  final String slug;

  SubCategory({required this.id, required this.name, required this.slug});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
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

/*class Comment {
  final String id;
  final String text;
  final DateTime createdAt;
  final Reviewer? user; // Assuming structure
  final int likes;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    this.user,
    this.likes = 0,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      user: json['user'] != null ? Reviewer.fromJson(json['user']) : null,
      likes: json['likes'] ?? 0,
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((e) => Comment.fromJson(e))
          .toList(),
    );
  }
}*/
