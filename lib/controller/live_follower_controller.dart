import 'package:zatch/model/live_session_res.dart'; // Ensure this path is correct and contains LiveSessionsResponse, Session, Host
import 'package:zatch/services/api_service.dart';   // Ensure this path is correct

class LiveFollowerController {
  final ApiService _apiService = ApiService();

  Future<List<Session>> getLiveSessions() async {
    try {
      final liveSessionsResponse = await _apiService.getLiveSessions();

      if (liveSessionsResponse.success) {
        return liveSessionsResponse.sessions;
      } else {
        throw Exception('Failed to fetch live sessions: Server indicated not successful.');
      }
    } on Exception catch (e) {
      print('Error fetching live sessions in LiveFollowerController: $e');
      throw Exception('Could not load live sessions. Please check your connection and try again.');
    }
  }
}

