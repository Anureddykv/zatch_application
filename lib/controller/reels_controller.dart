import '../model/reels_video_model.dart';

class ReelsController {
  List<ReelsVideo> reelsVideos = [
    ReelsVideo('Reels 1', 'assets/video1.mp4'),
    ReelsVideo('Reels 2', 'assets/video2.mp4'),
    ReelsVideo('Reels 3', 'assets/video3.mp4'),
  ];

  void toggleLike(int index) {
    reelsVideos[index].isLiked = !reelsVideos[index].isLiked;
  }

  void togglePlaying(int index) {
    reelsVideos[index].isPlaying = !reelsVideos[index].isPlaying;
  }

  void addReelsVideo(ReelsVideo video) {
    reelsVideos.add(video);
  }
}