import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyCategorySelected = "category_selected";

  static const String _categorySelectedKey = "category_selected";
  static const String _selectedCategoriesKey = "selected_categories";
  static const String _readZatchesKey = "read_zatches";

  /// Save category selection status
  static Future<void> setCategorySelected(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCategorySelected, value);
  }

  /// Read category selection status
  static Future<bool> hasSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCategorySelected) ?? false;
  }
  /// ✅ Save selected category IDs
  static Future<void> setSelectedCategories(List<String> categoryIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectedCategoriesKey, categoryIds);
  }

  /// ✅ Get selected category IDs
  static Future<List<String>> getSelectedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_selectedCategoriesKey) ?? [];
  }

  /// ✅ Clear saved categories
  static Future<void> clearSelectedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedCategoriesKey);
    await prefs.setBool(_categorySelectedKey, false);
  }
  static const String _authTokenKey = 'auth_token';

  /// Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  /// Get saved token
  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  /// Clear saved token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  /// ✅ Save read zatch IDs
  static Future<void> setReadZatches(Set<String> zatchIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readZatchesKey, zatchIds.toList());
  }

  /// ✅ Get read zatch IDs
  static Future<Set<String>> getReadZatches() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_readZatchesKey) ?? [];
    return list.toSet();
  }
}
