import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.authBase}/register');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final responseData = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(responseData['message'] ?? 'Register failed');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.authBase}/login');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    final responseData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(responseData['message'] ?? 'Login failed');
    }

    final user = User.fromJson(responseData['user']);
    final token = responseData['token'] as String;

    return {'token': token, 'user': user};
  }

  Future<User> getMe(String token) async {
    final url = Uri.parse('${ApiConstants.authBase}/me');

    final response = await http
        .get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    final responseData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(responseData['message'] ?? 'Get user failed');
    }

    return User.fromJson(responseData['user']);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
