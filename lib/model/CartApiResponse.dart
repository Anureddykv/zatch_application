import 'dart:convert';

// Helper function to decode JSON string
CartApiResponse cartApiResponseFromJson(String str) =>
    CartApiResponse.fromJson(json.decode(str));

class CartApiResponse {
  final bool success;
  final CartModel? cart;

  CartApiResponse({
    required this.success,
    this.cart,
  });

  factory CartApiResponse.fromJson(Map<String, dynamic> json) =>
      CartApiResponse(
        success: json["success"],
        cart: json["cart"] != null ? CartModel.fromJson(json["cart"]) : null,
      );
}

class CartModel {
  final String id;
  final String user;
  final List<CartItemModel> items;
  final dynamic coupon; // Can be null or an object, so dynamic is safer
  final int discount;
  final int totalItems;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.user,
    required this.items,
    this.coupon,
    required this.discount,
    required this.totalItems,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    int calculatedTotalItems = 0;
    double calculatedTotalPrice = 0.0;
    if (json["items"] != null) {
      for (var item in json["items"]) {
        int qty = item['qty'] ?? 0;
        double price = (item['product']?['discountedPrice'] ?? item['product']?['price'] ?? 0).toDouble();
        calculatedTotalItems += qty;
        calculatedTotalPrice += qty * price;
      }
    }

    return CartModel(
      id: json["_id"] ?? '', // Added null check for safety
      user: json["user"] ?? '', // Added null check for safety
      items: json["items"] != null
          ? List<CartItemModel>.from(
          json["items"].map((x) => CartItemModel.fromJson(x)))
          : [],
      coupon: json["coupon"],
      discount: json["discount"] ?? 0, // Added null check for safety
      totalItems: calculatedTotalItems,
      totalPrice: calculatedTotalPrice,

      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(), // Use current time as a fallback
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : DateTime.now(), // Use current time as a fallback
    );
  }
}

class CartItemModel {
  final VariantModel variant;
  final ProductModel product;
  final int qty;
  final String id;

  CartItemModel({
    required this.variant,
    required this.product,
    required this.qty,
    required this.id,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    variant: VariantModel.fromJson(json["variant"]),
    product: ProductModel.fromJson(json["product"]),
    qty: json["qty"],
    id: json["_id"],
  );
}

class ProductModel {
  final ProductType productType;
  final String id;
  final String name;
  final double price;
  final double discountedPrice;
  final List<ImageModel> images;
  final List<VariantModel>? variants; // As seen in the GET response

  ProductModel({
    required this.productType,
    required this.id,
    required this.name,
    required this.price,
    required this.discountedPrice,
    required this.images,
    this.variants,
  });

  // A getter for easier access to the primary image
  String get primaryImageUrl => images.isNotEmpty ? images.first.url : '';

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    productType: ProductType.fromJson(json["productType"]),
    id: json["_id"],
    name: json["name"],
    price: (json["price"] as num).toDouble(),
    discountedPrice: (json["discountedPrice"] as num).toDouble(),
    images: List<ImageModel>.from(
        json["images"].map((x) => ImageModel.fromJson(x))),
    variants: json["variants"] != null
        ? List<VariantModel>.from(
        json["variants"].map((x) => VariantModel.fromJson(x)))
        : null,
  );
}

class ImageModel {
  final String publicId;
  final String url;
  final String id;

  ImageModel({
    required this.publicId,
    required this.url,
    required this.id,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
    publicId: json["public_id"],
    url: json["url"],
    id: json["_id"],
  );
}

class ProductType {
  final bool hasSize;
  final bool hasColor;

  ProductType({
    required this.hasSize,
    required this.hasColor,
  });

  factory ProductType.fromJson(Map<String, dynamic> json) => ProductType(
    hasSize: json["hasSize"],
    hasColor: json["hasColor"],
  );
}

class VariantModel {
  final String? color;
  final int? stock; // As seen in the GET response
  final String? id; // As seen in the GET response

  VariantModel({
    this.color,
    this.stock,
    this.id,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) => VariantModel(
    color: json["color"],
    stock: json["stock"],
    id: json["_id"],
  );
}
