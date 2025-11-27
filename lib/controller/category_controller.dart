import 'package:flutter/material.dart';
import 'package:zatch_app/model/categories_response.dart';
import 'package:zatch_app/services/api_service.dart';

class CategoryController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Category> categories = [];
  bool isLoading = true;
  String? errorMessage;

  /// Fetch categories from API
  Future<void> fetchCategories() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final fetchedCategories = await _apiService.getCategories();
      categories = fetchedCategories;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
