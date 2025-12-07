class ProductResponseSeller {
  final bool success;
  final String message;
  final List<ProductItem> products;

  ProductResponseSeller({
    required this.success,
    required this.message,
    required this.products,
  });

  factory ProductResponseSeller.fromJson(Map<String, dynamic> json) {
    return ProductResponseSeller(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => ProductItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ProductItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final int discountedPrice;
  final List<ProductImage> images;
  final bool isTopPick;
  final int saveCount;
  final int likeCount;
  final int viewCount;
  final CategoryModel category;
  final SubCategory subCategory;
  final int commentCount;
  final double averageRating;

  ProductItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.images,
    required this.isTopPick,
    required this.saveCount,
    required this.likeCount,
    required this.viewCount,
    required this.category,
    required this.subCategory,
    required this.commentCount,
    required this.averageRating,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      discountedPrice: json['discountedPrice'] ?? 0,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e))
              .toList() ??
          [],
      isTopPick: json['isTopPick'] ?? false,
      saveCount: json['saveCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      category: CategoryModel.fromJson(json['category'] ?? {}),
      subCategory: SubCategory.fromJson(json['subCategory'] ?? {}),
      commentCount: json['commentCount'] ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ProductImage {
  final String publicId;
  final String url;
  final String id;

  ProductImage({required this.publicId, required this.url, required this.id});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final CategoryImage image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: CategoryImage.fromJson(json['image'] ?? {}),
    );
  }
}

class SubCategory {
  final String id;
  final String name;
  final String slug;
  final CategoryImage image;

  SubCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: CategoryImage.fromJson(json['image'] ?? {}),
    );
  }
}

class CategoryImage {
  final String publicId;
  final String url;

  CategoryImage({required this.publicId, required this.url});

  factory CategoryImage.fromJson(Map<String, dynamic> json) {
    return CategoryImage(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
