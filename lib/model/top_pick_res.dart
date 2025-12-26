
import 'package:zatch/model/product_response.dart';

class TopPicksResponse {
  final bool success;
  final String message;
  final List<Product> products;

  TopPicksResponse({
    required this.success,
    required this.message,
    required this.products,
  });

  factory TopPicksResponse.fromJson(Map<String, dynamic> json) {
    return TopPicksResponse(
      success: json['success'],
      message: json['message'],
      products: (json['products'] as List<dynamic>)
          .map((item) => Product.fromJson(item))
          .toList(),
    );
  }
}
