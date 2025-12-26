class Bit {
  final String id;
  final String title;
  final String description;
  final String videoUrl;

  Bit({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
  });

  factory Bit.fromJson(Map<String, dynamic> json) {
    return Bit(
      id: json['_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video'] != null ? json['video']['url'] : '',
    );
  }
}
