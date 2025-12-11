import 'package:flutter/material.dart';
import 'package:zatch_app/controller/live_follower_controller.dart';
import 'package:zatch_app/model/live_session_res.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/view/live_view/see_all_live_screen.dart';
import 'package:zatch_app/model/categories_response.dart';

import '../view/live_view/live_session_card.dart';

class LiveFollowersWidget extends StatefulWidget {
  final UserProfileResponse? userProfile;
  final Category? category;
  const LiveFollowersWidget({super.key, this.userProfile, this.category});

  @override
  State<LiveFollowersWidget> createState() => _LiveFollowersWidgetState();
}

class _LiveFollowersWidgetState extends State<LiveFollowersWidget> {
  final LiveFollowerController _controller = LiveFollowerController();

  List<Session> _liveSessions = [];
  bool _isLoading = true;
  String? _error;

  final double cardWidth = 131.0;
  final double cardHeight = 158.0;

  @override
  void initState() {
    super.initState();
    _loadLiveUsers();
  }

  @override
  void didUpdateWidget(LiveFollowersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category?.id != widget.category?.name) {
      _loadLiveUsers();
    }
  }

  Future<void> _loadLiveUsers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessions = await _controller.getLiveSessions();
      // Filter sessions if category is provided
      final filteredSessions = widget.category == null || widget.category!.name.toLowerCase() == 'explore all'
          ? sessions
          : sessions; // TODO: Implement filtering logic if Session has category info

      if (mounted) {
        setState(() {
          _liveSessions = filteredSessions;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _liveSessions = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double listHeight = 170;

    // Show a loading indicator for the horizontal list
    if (_isLoading) {
      return SizedBox(
        height: listHeight + 50, // Height for header + list
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFA3DD00)),
        ),
      );
    }

    if (_liveSessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Live from followers",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // --- CHANGE #1: Only show "See All" if there are more than 3 items ---
              if (_liveSessions.length > 1)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeeAllLiveScreen(
                          liveSessions: _liveSessions, // Pass the FULL list
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "See All",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _liveSessions.length > 5 ? 5 : _liveSessions.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              final liveSession = _liveSessions[index];
              return Padding(
                padding: EdgeInsets.only(
                    right: (index == _liveSessions.length - 1 || index == 4) ? 0 : 12),
                child: LiveSessionCard(
                  liveSession: liveSession,
                  width: cardWidth,
                  height: cardHeight,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
