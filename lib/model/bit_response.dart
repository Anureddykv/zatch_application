class BitsResponse {
  final bool success;
  final String message;
  final List<Bit> bits;

  BitsResponse({
    required this.success,
    required this.message,
    required this.bits,
  });

  factory BitsResponse.fromJson(Map<String, dynamic> json) {
    return BitsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      bits: (json['bits'] as List<dynamic>?)
          ?.map((e) => Bit.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class Bit {
  final String id;
  final String? image;
  final String? video;
  final String? title;
  final String? category;
  final String? price;
  final String? rating;
  final bool? isLive;

  Bit({
    required this.id,
    this.image,
    this.video,
    this.title,
    this.category,
    this.price,
    this.rating,
    this.isLive,
  });

  factory Bit.fromJson(Map<String, dynamic> json) => Bit(
    id: json['_id'],
    image: json['image'],
    video: json['video'],
    title: json['title'],
    category: json['category'],
    price: json['price'],
    rating: json['rating'],
    isLive: json['isLive'] ?? false,
  );
  String get mediaPath => video ?? image ?? '';
  bool get isVideo => video != null && video!.isNotEmpty;
  String get displayTitle => title ?? '';
  String get displayCategory => category ?? '';
  String get displayPrice => price ?? '';
  String get displayRating => rating ?? '0';
  bool get liveStatus => isLive ?? false;
}

