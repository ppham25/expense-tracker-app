import 'dart:convert';

import 'package:adv_basic/features/auth/services/auth_service.dart';
import 'package:http/http.dart' as http;

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
}
