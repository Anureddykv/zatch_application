import 'dart:async';

class FollowEventBus {
  // Singleton pattern
  static final FollowEventBus _instance = FollowEventBus._internal();
  factory FollowEventBus() => _instance;
  FollowEventBus._internal();

  // Stream controller to broadcast updates
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  // Get the stream to listen to
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  // Method to trigger an update
  void emitStatusChange(String userId, bool isFollowing) {
    _controller.sink.add({
      'userId': userId,
      'isFollowing': isFollowing,
    });
  }

  void dispose() {
    _controller.close();
  }
}
