class Zatch {
  final String? id;
  final String? description;
  final String name;
  final String seller;
  final String imageUrl;
  final bool active;
  final String status;
  final String quotePrice;
  final String sellerPrice;
  final int quantity;
  final String subTotal;
  final String date;
  final String? expiresIn;

  Zatch({
    this.id,
    this.description,
    required this.name,
    required this.seller,
    required this.imageUrl,
    required this.active,
    required this.status,
    required this.quotePrice,
    required this.sellerPrice,
    required this.quantity,
    required this.subTotal,
    required this.date,
    this.expiresIn,
  });
}
