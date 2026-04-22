import 'dart:convert';

import 'package:adv_basic/features/auth/services/auth_service.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../models/expense.dart';

class ExpenseService {
  final AuthService _authService = AuthService();

  Future<List<Expense>?> getExpenses() async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/expenses');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load expenses');
    }

    final data = jsonDecode(response.body);
    final List expensesJson = data['expenses'];

    return expensesJson
        .map((expenseJson) => Expense.fromJson(expenseJson))
        .toList();
  }

  Future<Expense> addExpense({
    required String title,
    required double amount,
    required DateTime date,
    required Category category,
  }) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/api/expenses');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'amount': amount,
        'expense_date': date.toIso8601String().split('T').first,
        'category': category.name,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add expense');
    }
    final data = jsonDecode(response.body);

    final newExpense = Expense.fromJson(data['expense']);
    return newExpense;
  }

  Future<void> deleteExpense(String id) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/api/expenses/$id');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense');
    }
  }
}
