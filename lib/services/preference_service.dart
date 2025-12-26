import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const _keyIsFirstLaunch = 'isFirstLaunch';
  static const _keyHasSelectedCategories = 'hasSelectedCategories';
  static const _keyAuthToken = 'authToken';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<bool> getIsFirstLaunch() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyIsFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchFalse() async {
    final prefs = await _prefs;
    await prefs.setBool(_keyIsFirstLaunch, false);
  }

  Future<bool> getHasSelectedCategories() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyHasSelectedCategories) ?? false;
  }

  Future<void> setHasSelectedCategories(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyHasSelectedCategories, value);
  }

  Future<String?> getAuthToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyAuthToken);
  }

  Future<void> setAuthToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_keyAuthToken, token);
  }

  Future<void> clearAuthToken() async {
    final prefs = await _prefs;
    await prefs.remove(_keyAuthToken);
  }

  Future<void> logoutAll() async {
    final prefs = await _prefs;
    await prefs.remove(_keyAuthToken);
    await prefs.setBool(_keyHasSelectedCategories, false);
  }
}
