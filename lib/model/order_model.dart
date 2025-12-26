import 'package:intl/intl.dart';

class OrderModel {
  final String id;
  final String orderId;
  final String status;
  final String? buyerId;
  final OrderSeller? seller;
  final String? liveSessionId;
  final List<OrderItem> items;
  final OrderPricing pricing;
  final DeliveryAddress? deliveryAddress;
  final DateTime createdAt;
  final DateTime? expectedDelivery;
  final DateTime? orderPlaced;
  final OrderPayment payment;
  final CancellationInfo? cancellation;
  final List<StatusHistoryItem> statusHistory;
  final String? orderType;
  final String? deliveryType;
  final String? location;
  final String? buyerNote;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.status,
    this.buyerId,
    this.seller,
    this.liveSessionId,
    required this.items,
    required this.pricing,
    this.deliveryAddress,
    required this.createdAt,
    this.expectedDelivery,
    this.orderPlaced,
    required this.payment,
    this.cancellation,
    this.statusHistory = const [],
    this.orderType,
    this.deliveryType,
    this.location,
    this.buyerNote,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? 'Unknown',
      status: json['status'] ?? 'pending',
      buyerId: json['buyerId'],
      seller: json['sellerId'] != null && json['sellerId'] is Map<String, dynamic>
          ? OrderSeller.fromJson(json['sellerId'])
          : null,
      liveSessionId: json['liveSessionId'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ??
          [],
      pricing: OrderPricing.fromJson(json['pricing'] ?? {}),
      deliveryAddress: json['deliveryAddress'] != null 
          ? DeliveryAddress.fromJson(json['deliveryAddress']) 
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      expectedDelivery:
      (json['dates'] != null && json['dates']['expectedDelivery'] != null)
          ? DateTime.parse(json['dates']['expectedDelivery'])
          : null,
      orderPlaced:
      (json['dates'] != null && json['dates']['orderPlaced'] != null)
          ? DateTime.parse(json['dates']['orderPlaced'])
          : null,
      payment: OrderPayment.fromJson(json['payment'] ?? {}),
      cancellation: json['cancellation'] != null 
          ? CancellationInfo.fromJson(json['cancellation']) 
          : null,
      statusHistory: (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => StatusHistoryItem.fromJson(e))
          .toList() ?? [],
      orderType: json['orderType'],
      deliveryType: json['deliveryType'],
      location: json['location'],
      buyerNote: json['buyerNote'],
    );
  }
}

class OrderSeller {
  final String id;
  final String username;
  final String? profilePic;

  OrderSeller({required this.id, required this.username, this.profilePic});

  factory OrderSeller.fromJson(Map<String, dynamic> json) {
    return OrderSeller(
      id: json['_id'] ?? '',
      username: json['username'] ?? 'Unknown',
      profilePic: json['profilePic'] != null ? json['profilePic']['url'] : null,
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
  final String? bitId;
  final String? sellerId;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.qty,
    required this.price,
    required this.total,
    this.variant,
    this.bitId,
    this.sellerId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'] ?? '',
      productId: json['product'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      image: json['image'] ?? 'https://placehold.co/150',
      qty: json['qty'] ?? 1,
      price: json['price'] ?? 0,
      total: json['total'] ?? 0,
      variant: json['variant'] != null
          ? ItemVariant.fromJson(json['variant'])
          : null,
      bitId: json['bitId'],
      sellerId: json['sellerId'],
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

class OrderPayment {
  final String method;
  final String status;

  OrderPayment({required this.method, required this.status});

  factory OrderPayment.fromJson(Map<String, dynamic> json) {
    return OrderPayment(
      method: json['method'] ?? 'cod',
      status: json['status'] ?? 'pending',
    );
  }
}

class CancellationInfo {
  final String? reason;
  final String? cancelledBy;
  final DateTime? cancelledAt;

  CancellationInfo({this.reason, this.cancelledBy, this.cancelledAt});

  factory CancellationInfo.fromJson(Map<String, dynamic> json) {
    return CancellationInfo(
      reason: json['reason'],
      cancelledBy: json['cancelledBy'],
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt']) 
          : null,
    );
  }
}

class StatusHistoryItem {
  final String status;
  final DateTime timestamp;
  final String? note;

  StatusHistoryItem({required this.status, required this.timestamp, this.note});

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      note: json['note'],
    );
  }
}

class DeliveryAddress {
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final String phone;

  DeliveryAddress({
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      label: json['label'] ?? 'Address',
      line1: json['line1'] ?? '',
      line2: json['line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  @override
  String toString() {
    return "$line1${line2 != null ? ', $line2' : ''}, $city, $state - $pincode";
  }
}
