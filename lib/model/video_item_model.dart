class VideoItem {
  final String title;
  final String videoAsset;
  bool isPlaying;

  VideoItem(this.title, this.videoAsset, {this.isPlaying = false});
}