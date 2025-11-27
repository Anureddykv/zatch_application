enum OrderStatus { accepted, inTransit, outForDelivery, delivered, canceled }


class OrderModel {
  final OrderStatus status;
  final String title;
  final String subtitle;
  final String qty;
  final String price;
  final String imageUrl;
  final String address;

  OrderModel({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.qty,
    required this.price,
    required this.imageUrl,
    required this.address,
  });
}