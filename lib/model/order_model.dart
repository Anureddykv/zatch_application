import 'package:intl/intl.dart';

class OrderModel {
  final String id;
  final String orderId;
  final String status;
  final List<OrderItem> items;
  final OrderPricing pricing;
  final DeliveryAddress deliveryAddress;
  final DateTime createdAt;
  final DateTime? expectedDelivery;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.status,
    required this.items,
    required this.pricing,
    required this.deliveryAddress,
    required this.createdAt,
    this.expectedDelivery,
    required this.paymentMethod,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? 'Unknown',
      status: json['status'] ?? 'pending',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ??
          [],
      pricing: OrderPricing.fromJson(json['pricing'] ?? {}),
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      expectedDelivery:
      (json['dates'] != null && json['dates']['expectedDelivery'] != null)
          ? DateTime.parse(json['dates']['expectedDelivery'])
          : null,
      paymentMethod: json['payment']?['method'] ?? 'COD',
    );
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String name;
  final String image;
  final int qty;
  final num price;
  final num total;
  final ItemVariant? variant;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.qty,
    required this.price,
    required this.total,
    this.variant,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'] ?? '',
      productId: json['product'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      image: json['image'] ?? 'https://placehold.co/150', // Fallback image
      qty: json['qty'] ?? 1,
      price: json['price'] ?? 0,
      total: json['total'] ?? 0,
      variant: json['variant'] != null
          ? ItemVariant.fromJson(json['variant'])
          : null,
    );
  }
}

class ItemVariant {
  final String? color;
  final String? size;

  ItemVariant({this.color, this.size});

  factory ItemVariant.fromJson(Map<String, dynamic> json) {
    return ItemVariant(
      color: json['color'],
      size: json['size'],
    );
  }
}

class OrderPricing {
  final num subtotal;
  final num discount;
  final num shipping;
  final num tax;
  final num total;

  OrderPricing({
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
  });

  factory OrderPricing.fromJson(Map<String, dynamic> json) {
    return OrderPricing(
      subtotal: json['subtotal'] ?? 0,
      discount: json['discount'] ?? 0,
      shipping: json['shipping'] ?? 0,
      tax: json['tax'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class DeliveryAddress {
  final String label; // <-- ADDED THIS FIELD
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final String phone;

  DeliveryAddress({
    required this.label, // <-- ADDED THIS
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      label: json['label'] ?? 'Address', // <-- ADDED THIS with a fallback
      line1: json['line1'] ?? '',
      line2: json['line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  // Helper to display full address
  @override
  String toString() {
    return "$line1${line2 != null ? ', $line2' : ''}, $city, $state - $pincode";
  }
}
