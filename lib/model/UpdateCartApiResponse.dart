import 'dart:convert';

UpdateCartApiResponse updateCartApiResponseFromJson(String str) =>
    UpdateCartApiResponse.fromJson(json.decode(str));

class UpdateCartApiResponse {
  final bool success;
  final String message;
  final UpdatedCartModel cart;

  UpdateCartApiResponse({
    required this.success,
    required this.message,
    required this.cart,
  });

  factory UpdateCartApiResponse.fromJson(Map<String, dynamic> json) =>
      UpdateCartApiResponse(
        success: json["success"],
        message: json["message"],
        cart: UpdatedCartModel.fromJson(json["cart"]),
      );
}

// -------------------- CART MODEL --------------------

class UpdatedCartModel {
  final List<CartItemModel> items;
  final int totalItems;
  final double totalPrice;

  UpdatedCartModel({
    required this.items,
    required this.totalItems,
    required this.totalPrice,
  });

  factory UpdatedCartModel.fromJson(Map<String, dynamic> json) =>
      UpdatedCartModel(
        items: List<CartItemModel>.from(
            json["items"].map((x) => CartItemModel.fromJson(x))),
        totalItems: json["totalItems"],
        totalPrice: (json["totalPrice"] as num).toDouble(),
      );
}

// -------------------- CART ITEM --------------------
class CartItemModel {
  final String id;
  final int qty;
  final ProductModel product;
  final VariantModel? variant;

  CartItemModel({
    required this.id,
    required this.qty,
    required this.product,
    required this.variant,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json["_id"],
    qty: json["qty"],
    product: ProductModel.fromJson(json["product"]),
    variant:
    json["variant"] != null ? VariantModel.fromJson(json["variant"]) : null,
  );
}
class ProductModel {
  final String id;
  final String name;
  final double price;
  final double discountedPrice;
  final List<ImageModel> images;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.discountedPrice,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json["_id"],
    name: json["name"],
    price: (json["price"] as num).toDouble(),
    discountedPrice: (json["discountedPrice"] as num).toDouble(),
    images: List<ImageModel>.from(
        json["images"].map((x) => ImageModel.fromJson(x))),
  );
}


// -------------------- PRODUCT VARIANT --------------------

class VariantModel {
  final String? sku; // nullable now
  final String? color;
  final String? shade;
  final String? size;

  VariantModel({
    this.sku,
    this.color,
    this.shade,
    this.size,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) => VariantModel(
    sku: json["sku"] ?? "",
    color: json["color"]?? "",
    shade: json["shade"]?? "",
    size: json["size"]?? "",
  );

}


// -------------------- IMAGE --------------------

class ImageModel {
  final String url;
  final String publicId;

  ImageModel({
    required this.url,
    required this.publicId,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
    url: json["url"] ?? "",         // add null safety
    publicId: json["publicId"] ?? "",
  );
}

