// lib/services/category_service.dart

import '../models/category_model.dart';
import 'api_service.dart';

class CategoryService {
  /// GET /categories/client-view
  Future<List<Category>> getCategories() async {
    final response = await ApiService.get('/categories/client-view');

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}