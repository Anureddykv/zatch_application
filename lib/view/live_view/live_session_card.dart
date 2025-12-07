import 'package:flutter/material.dart';
import 'package:zatch_app/controller/live_stream_controller.dart';
import 'package:zatch_app/model/live_session_res.dart';
import 'package:zatch_app/view/LiveDetailsScreen.dart';

class LiveSessionCard extends StatelessWidget {
  final Session liveSession;
  final double? width;
  final double? height;

  const LiveSessionCard({
    super.key,
    required this.liveSession,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // --- Data Handling with Fallbacks ---
    final String hostName = liveSession.host?.username ?? 'Live Event';
    final String sessionTopic = liveSession.title ?? "General";
    final String hostAvatarUrl = liveSession.host?.profilePicUrl ??
        'https://placehold.co/40x40/777777/ffffff?text=${hostName.isNotEmpty ? hostName[0].toUpperCase() : 'L'}';
    final String sessionBackgroundUrl = liveSession.thumbnail.url;
    return GestureDetector(
      onTap: () {
        final liveController = LiveStreamController(session: liveSession);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LiveStreamScreen(
                controller: liveController, username: liveSession.host?.username),
          ),
        );
      },
      child: SizedBox(
        width: width ?? 131,
        height: height ?? 158,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // --- Background Image ---
              Image.network(
                sessionBackgroundUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.person_off_outlined, color: Colors.grey[400]),
                ),
              ),

              // --- Gradient Overlay ---
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(0.5, -0.0),
                    end: const Alignment(0.5, -0.0),
                    colors: [
                      const Color(0x4C000000),
                      const Color(0x35000000),
                      const Color(0x00000000),
                      const Color(0x00000000),
                      const Color(0x51000000),
                      const Color(0x99000000),
                    ],
                  ),
                ),
              ),

              // --- "LIVE" Badge ---
              if (liveSession.status.toLowerCase() == 'live')
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    height: 17,
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBBF711),
                      borderRadius: BorderRadius.circular(48),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Live',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                            fontFamily: 'Encode Sans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${liveSession.viewersCount}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                            fontFamily: 'Encode Sans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // --- Host Info ---
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (liveSession.host != null)
                      ClipOval(
                        child: Image.network(
                          hostAvatarUrl,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                            width: 20,
                            height: 20,
                            color: Colors.grey[400],
                            child: const Icon(Icons.person, size: 12, color: Colors.white70),
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hostName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            sessionTopic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
