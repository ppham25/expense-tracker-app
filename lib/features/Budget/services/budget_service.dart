import 'dart:convert';

import 'package:adv_basic/features/auth/services/auth_service.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../models/budget.dart';

class BudgetService {
  final AuthService _authService = AuthService();

  Future<List<Budget>> getBudgets({
    required int month,
    required int year,
  }) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/api/budgets?month=$month&year=$year',
    );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load : ${response.body}');
    }

    final data = jsonDecode(response.body);
    final List budgetsJson = data['budgets'] as List;

    return budgetsJson
        .map((budgetJson) => Budget.fromJson(budgetJson))
        .toList();
  }

  Future<void> addBudget({
    required int categoryId,
    required double limitAmount,
    required int month,
    required int year,
  }) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/api/budgets');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'category_id': categoryId,
        'limitAmount': limitAmount,
        'month': month,
        'year': year,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add budget: ${response.body}');
    }
  }

  Future<void> updateBudget({
    required int id,
    required double limitAmount,
  }) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/budgets/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'limitAmount': limitAmount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update budget: ${response.body}');
    }
  }

  Future<void> deleteBudget(int id) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/budgets/$id');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete budget: ${response.body}');
    }
  }
}
