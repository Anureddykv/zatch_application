import '../model/video_item_model.dart';

class VideoController {
  List<VideoItem> videoItems = [
    VideoItem('Tutorial Video 1', 'assets/images/vid1.mp4'),
    VideoItem('Tutorial Video 2', 'assets/images/vid2.mp4'),
    VideoItem('Demo Video', 'assets/images/vid3.mp4'),
  ];

  void togglePlaying(int index) {
    videoItems[index].isPlaying = !videoItems[index].isPlaying;
  }

  void addVideoItem(VideoItem videoItem) {
    videoItems.add(videoItem);
  }
}