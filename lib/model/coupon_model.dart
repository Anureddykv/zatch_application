class Coupon {
  final String id;
  final String name;
  final String code;
  final String discountText; // e.g., "20% Off" or "₹200 Off"
  final String discountType; // "fixed" or "percentage"
  final double discountValue;
  final double minSpend;
  final double? maxDiscount;

  Coupon({
    required this.id,
    required this.name,
    required this.code,
    required this.discountText,
    required this.discountType,
    required this.discountValue,
    required this.minSpend,
    this.maxDiscount,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      discountText: json['discountText'] ?? '',
      discountType: json['discountType'] ?? 'percentage',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      minSpend: (json['minSpend'] as num?)?.toDouble() ?? 0.0,
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
    );
  }
}
