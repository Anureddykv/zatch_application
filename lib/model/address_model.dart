import 'package:flutter/material.dart';

class Address {
  final String id;
  final String label;
  final String type;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.type,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      label: json['label'],
      type: json['type'],
      line1: json['line1'],
      line2: json['line2'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      phone: json['phone'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'label': label,
      'type': type,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'phone': phone,
      'isDefault': isDefault,
    };
  }
   String get fullAddress {
    return [line1, line2, city, state, pincode]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
  }

  // Helper to get an icon based on the type
  IconData get icon {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'office':
        return Icons.apartment_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }
}
