import 'dart:convert';

import 'package:adv_basic/features/auth/services/auth_service.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../models/category_model.dart';

class CategoryService {
  final AuthService _authService = AuthService();

  Future<List<ExpenseCategory>> getCategories() async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/categories');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final List categoriesJson = data['categories'] as List;

    return categoriesJson
        .map((categoryJson) => ExpenseCategory.fromJson(categoryJson))
        .toList();
  }

  Future<ExpenseCategory> addCategory(String name) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/categories');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add category: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return ExpenseCategory.fromJson(data['category']);
  }
}
