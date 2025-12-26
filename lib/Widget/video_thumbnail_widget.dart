import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;

  const VideoThumbnailWidget({super.key, required this.videoUrl});

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Future<String?>? _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    // Start generating the thumbnail as soon as the widget is created
    _thumbnailFuture = _generateThumbnail(widget.videoUrl);
  }

  Future<String?> _generateThumbnail(String url) async {
    // video_thumbnail package returns the file path of the generated thumbnail
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP, // WEBP is efficient
      maxHeight: 250, // Limit the size for performance
      quality: 75,
    );
    return thumbnailPath;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        // --- While waiting for the thumbnail ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey[800], // Dark placeholder
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white54),
              ),
            ),
          );
        }

        // --- If thumbnail generation failed ---
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: Icon(Icons.error_outline, color: Colors.white54, size: 40),
            ),
          );
        }

        // --- On success, display the thumbnail file ---
        final thumbnailFile = File(snapshot.data!);
        return Image.file(
          thumbnailFile,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }
}
