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
  // Added coordinate fields
  final double? lat;
  final double? lng;

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
    this.lat,
    this.lng,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    // API returns coordinates as a nested object: "coordinates": {"lat": ..., "lng": ...}
    final coords = json['coordinates'] as Map<String, dynamic>?;

    return Address(
      id: json['_id'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? '',
      line1: json['line1'] ?? '',
      line2: json['line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      phone: json['phone'] ?? '',
      isDefault: json['isDefault'] ?? false,
      lat: coords != null ? (coords['lat'] as num?)?.toDouble() : null,
      lng: coords != null ? (coords['lng'] as num?)?.toDouble() : null,
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
      'coordinates': {
        'lat': lat,
        'lng': lng,
      }
    };
  }

  String get fullAddress {
    return [line1, line2, city, state, pincode]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
  }

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'home': return Icons.home_outlined;
      case 'office': return Icons.apartment_outlined;
      default: return Icons.location_on_outlined;
    }
  }
}
