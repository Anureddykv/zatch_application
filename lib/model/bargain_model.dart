import 'product_response.dart';

class BargainDetailResponse {
  final bool success;
  final String? message;
  final BargainModel? bargain;

  BargainDetailResponse({required this.success, this.message, this.bargain});

  factory BargainDetailResponse.fromJson(Map<String, dynamic> json) => BargainDetailResponse(
        success: json["success"] ?? false,
        message: json["message"],
        bargain: json["bargain"] != null ? BargainModel.fromJson(json["bargain"]) : null,
      );
}

class BargainListResponse {
  final bool success;
  final List<BargainModel> bargains;

  BargainListResponse({required this.success, required this.bargains});

  factory BargainListResponse.fromJson(Map<String, dynamic> json) => BargainListResponse(
        success: json["success"] ?? false,
        bargains: json["bargains"] != null
            ? (json["bargains"] as List).map((x) => BargainModel.fromJson(x)).toList()
            : [],
      );
}

class CreateBargainResponse {
  final bool success;
  final String message;
  final BargainModel? bargain;
  final double? priceFloor;
  final double? maxDiscount;
  final String? yourDiscount;

  CreateBargainResponse({
    required this.success,
    required this.message,
    this.bargain,
    this.priceFloor,
    this.maxDiscount,
    this.yourDiscount,
  });

  factory CreateBargainResponse.fromJson(Map<String, dynamic> json) => CreateBargainResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        bargain: json["bargain"] != null ? BargainModel.fromJson(json["bargain"]) : null,
        priceFloor: (json["priceFloor"] as num?)?.toDouble(),
        maxDiscount: (json["maxDiscount"] as num?)?.toDouble(),
        yourDiscount: json["yourDiscount"],
      );
}

class BargainModel {
  final String id;
  final BargainOffer? buyerCounter;
  final BargainOffer? counterOffer;
  final BargainVariant? variant;
  final dynamic productId; // Can be String ID or BargainProduct object
  final dynamic buyerId; // Can be String ID or BargainUser object
  final dynamic sellerId; // Can be String ID or BargainSeller object
  final double originalPrice;
  final double offeredPrice;
  final double currentPrice;
  final double? discountPercentage;
  final String status;
  final int quantity;
  final String? buyerNote;
  final String? sellerNote;
  final DateTime? expiresAt;
  final bool autoAccepted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? respondedAt;

  BargainModel({
    required this.id,
    this.buyerCounter,
    this.counterOffer,
    this.variant,
    this.productId,
    this.buyerId,
    this.sellerId,
    required this.originalPrice,
    required this.offeredPrice,
    required this.currentPrice,
    this.discountPercentage,
    required this.status,
    required this.quantity,
    this.buyerNote,
    this.sellerNote,
    this.expiresAt,
    this.autoAccepted = false,
    this.createdAt,
    this.updatedAt,
    this.respondedAt,
  });

  factory BargainModel.fromJson(Map<String, dynamic> json) => BargainModel(
        id: json["_id"] ?? "",
        buyerCounter: json["buyerCounter"] != null ? BargainOffer.fromJson(json["buyerCounter"]) : null,
        counterOffer: json["counterOffer"] != null ? BargainOffer.fromJson(json["counterOffer"]) : null,
        variant: json["variant"] != null ? BargainVariant.fromJson(json["variant"]) : null,
        productId: json["productId"], 
        buyerId: json["buyerId"],
        sellerId: json["sellerId"],
        originalPrice: (json["originalPrice"] as num?)?.toDouble() ?? 0.0,
        offeredPrice: (json["offeredPrice"] as num?)?.toDouble() ?? 0.0,
        currentPrice: (json["currentPrice"] as num?)?.toDouble() ?? 0.0,
        discountPercentage: (json["discountPercentage"] as num?)?.toDouble(),
        status: json["status"] ?? "",
        quantity: (json["quantity"] as num?)?.toInt() ?? 1,
        buyerNote: json["buyerNote"],
        sellerNote: json["sellerNote"],
        expiresAt: json["expiresAt"] != null ? DateTime.parse(json["expiresAt"]) : null,
        autoAccepted: json["autoAccepted"] ?? false,
        createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
        updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
        respondedAt: json["respondedAt"] != null ? DateTime.parse(json["respondedAt"]) : null,
      );

  // Helper getters for populated fields
  BargainProduct? get product => productId is Map<String, dynamic> ? BargainProduct.fromJson(productId) : null;
  BargainUser? get buyer => buyerId is Map<String, dynamic> ? BargainUser.fromJson(buyerId) : null;
  BargainSeller? get seller => sellerId is Map<String, dynamic> ? BargainSeller.fromJson(sellerId) : null;
}

class BargainOffer {
  final double price;
  final String? message;
  final DateTime? offeredAt;

  BargainOffer({required this.price, this.message, this.offeredAt});

  factory BargainOffer.fromJson(Map<String, dynamic> json) => BargainOffer(
        price: (json["price"] as num?)?.toDouble() ?? 0.0,
        message: json["message"],
        offeredAt: json["offeredAt"] != null ? DateTime.parse(json["offeredAt"]) : null,
      );
}

class BargainVariant {
  final String? color;
  final String? size;

  BargainVariant({this.color, this.size});

  factory BargainVariant.fromJson(Map<String, dynamic> json) => BargainVariant(
        color: json["color"],
        size: json["size"],
      );
}

class BargainProduct {
  final String id;
  final String name;
  final double price;
  final double? discountedPrice;
  final List<ProductImage> images;
  final String? productCategory;
  final BargainSettings? bargainSettings;

  BargainProduct({
    required this.id,
    required this.name,
    required this.price,
    this.discountedPrice,
    required this.images,
    this.productCategory,
    this.bargainSettings,
  });

  factory BargainProduct.fromJson(Map<String, dynamic> json) => BargainProduct(
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
        price: (json["price"] as num?)?.toDouble() ?? 0.0,
        discountedPrice: (json["discountedPrice"] as num?)?.toDouble(),
        images: (json["images"] as List? ?? []).map((x) => ProductImage.fromJson(x)).toList(),
        productCategory: json["productCategory"],
        bargainSettings: json["bargainSettings"] != null ? BargainSettings.fromJson(json["bargainSettings"]) : null,
      );
}

class BargainUser {
  final String id;
  final String username;
  final String? phone;
  final ProfilePic? profilePic;

  BargainUser({required this.id, required this.username, this.phone, this.profilePic});

  factory BargainUser.fromJson(Map<String, dynamic> json) => BargainUser(
        id: json["_id"] ?? "",
        username: json["username"] ?? "",
        phone: json["phone"],
        profilePic: json["profilePic"] != null ? ProfilePic.fromJson(json["profilePic"]) : null,
      );
}

class BargainSeller {
  final String id;
  final String username;
  final String? phone;
  final ProfilePic? profilePic;
  final Map<String, dynamic>? sellerProfile;

  BargainSeller({required this.id, required this.username, this.phone, this.profilePic, this.sellerProfile});

  factory BargainSeller.fromJson(Map<String, dynamic> json) => BargainSeller(
        id: json["_id"] ?? "",
        username: json["username"] ?? "",
        phone: json["phone"],
        profilePic: json["profilePic"] != null ? ProfilePic.fromJson(json["profilePic"]) : null,
        sellerProfile: json["sellerProfile"],
      );
}
