import 'dart:convert';

import 'CartApiResponse.dart';

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

class UpdatedCartModel {
  final List<CartItemModel> items; // Reuses CartItemModel from above
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
