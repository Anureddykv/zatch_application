class BargainPick {
  final String id;
  final String title;
  final String subtitle;
  final String videoAsset;
  final String productTitle;
  final String productPrice;
  final String thumbnail; // new field

  BargainPick({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.videoAsset,
    required this.productTitle,
    required this.productPrice,
    required this.thumbnail,
  });
}
