class CartApiResponse {
  final bool success;
  final CartModel? cart;

  CartApiResponse({required this.success, this.cart});

  factory CartApiResponse.fromJson(Map<String, dynamic> json) =>
      CartApiResponse(
        success: json["success"],
        cart: json["cart"] != null ? CartModel.fromJson(json["cart"]) : null,
      );
}
class CartModel {
  final List<CartItemModel> items;
  final int totalItems;
  final int totalUniqueProducts;
  final int subtotal;
  final int discount;
  final int total;
  final dynamic coupon;

  CartModel({
    required this.items,
    required this.totalItems,
    required this.totalUniqueProducts,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.coupon,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    items: List<CartItemModel>.from(
        json["items"].map((x) => CartItemModel.fromJson(x))),
    totalItems: json["totalItems"],
    totalUniqueProducts: json["totalUniqueProducts"],
    subtotal: json["subtotal"],
    discount: json["discount"],
    total: json["total"],
    coupon: json["coupon"],
  );
}
class CartItemModel {
  final String id;
  final String productId;
  final String? sellerId;
  final String name;
  final String description;
  final double price;
  final double discountedPrice;
  final String image;
  final List<ImageModel> images;
  final VariantModel variant;
  final Map<String, dynamic>? selectedVariant;
  int quantity;
  final String? category;
  final String? subCategory;
  final String? productCategory;
  final int lineTotal;

  CartItemModel({
    required this.id,
    required this.productId,
     this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.image,
    required this.images,
    required this.variant,
    required this.selectedVariant,
    required this.quantity,
    this.category,
    this.subCategory,
     this.productCategory,
    required this.lineTotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json["_id"],
    productId: json["productId"],
    sellerId: json["sellerId"],
    name: json["name"],
    description: json["description"] ?? "",
    price: (json["price"] as num).toDouble(),
    discountedPrice: (json["discountedPrice"] as num).toDouble(),
    image: json["image"],
    images: List<ImageModel>.from(
        json["images"].map((x) => ImageModel.fromJson(x))),
    variant: VariantModel.fromJson(json["variant"]),
    selectedVariant: json["selectedVariant"],
    quantity: json["quantity"],
    category: json["category"] as String?,
    subCategory: json["subCategory"] as String?,
    productCategory: json["productCategory"],
    lineTotal: json["lineTotal"],
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
  final String? SKU;
  final String? color;
  final String? size;
  final String? shade;
  final int? stock;
  final String? image;

  VariantModel({
    this.SKU,
    this.color,
    this.size,
    this.shade,
    this.stock,
    this.image,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) => VariantModel(
    SKU: json["SKU"],
    color: json["color"],
    size: json["size"],
    shade: json["shade"],
    stock: json["stock"],
    image: json["image"],
  );
}
