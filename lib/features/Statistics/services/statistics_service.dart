import 'dart:convert';
import 'dart:io';

import 'package:adv_basic/features/auth/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/spending_trend.dart';
import '../../../core/constants/api_constants.dart';
import '../models/statistics_data.dart';

class StatisticsService {
  final AuthService _authService = AuthService();

  Future<StatisticsData> getMonthlyStatistics({
    required int month,
    required int year,
  }) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/api/statistics?month=$month&year=$year',
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load statistics (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    return StatisticsData.fromJson(data);
  }

  Future<SpendingTrend> getSpendingTrend({
    required int month,
    required int year,
    int months = 6,
  }) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/api/statistics/trend?month=$month&year=$year&months=$months',
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load spending trend (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    return SpendingTrend.fromJson(data);
  }

  Future<String> exportMonthlyReport({
    required int month,
    required int year,
  }) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/api/statistics/export?month=$month&year=$year',
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to export report (${response.statusCode}): ${response.body}',
      );
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'expense_report_${month}_$year.csv';
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(response.bodyBytes);

    return file.path;
  }
}
