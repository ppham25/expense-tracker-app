import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../models/user.dart';

class AuthService {
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.authBase}/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

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

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(responseData['message'] ?? 'Login failed');
    }

    final user = User.fromJson(responseData['user']);
    final token = responseData['token'];

    return {'token': token, 'user': user};
  }

  Future<User> getMe(String token) async {
    final url = Uri.parse('${ApiConstants.authBase}/me');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(responseData['message'] ?? 'Get user failed');
    }

    return User.fromJson(responseData['user']);
  }
}
