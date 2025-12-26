class ReelsVideo {
  final String title;
  final String videoAsset;
  bool isLiked;
  bool isPlaying;

  ReelsVideo(this.title, this.videoAsset, {this.isLiked = false, this.isPlaying = false});

  static fromJson(e) {}
}