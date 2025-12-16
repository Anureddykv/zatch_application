class OrderModel {
  final String id;
  final String orderId;
  final String status; // "pending" | "confirmed" | "shipped" | "delivered" | "cancelled"
  final OrderPricing pricing;
  final List<OrderItem> items;
  final DateTime? expectedDelivery;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.status,
    required this.pricing,
    required this.items,
    this.expectedDelivery,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? 'pending',
      pricing: OrderPricing.fromJson(json['pricing'] ?? {}),
      items: (json['items'] as List?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ??
          [],
      expectedDelivery: json['dates']?['expectedDelivery'] != null
          ? DateTime.parse(json['dates']['expectedDelivery'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class OrderPricing {
  final num subtotal;
  final num shipping;
  final num tax;
  final num total;

  OrderPricing({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
  });

  factory OrderPricing.fromJson(Map<String, dynamic> json) {
    return OrderPricing(
      subtotal: json['subtotal'] ?? 0,
      shipping: json['shipping'] ?? 0,
      tax: json['tax'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class OrderItem {
  final String name;
  final String image;
  final int qty;
  final num price;
  final num total;
  final String? bitId;

  OrderItem({
    required this.name,
    required this.image,
    required this.qty,
    required this.price,
    required this.total,
    this.bitId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] ?? 'Unknown Item',
      image: json['image'] ?? '',
      qty: json['qty'] ?? 1,
      price: json['price'] ?? 0,
      total: json['total'] ?? 0,
      bitId: json['bitId'],
    );
  }
}
