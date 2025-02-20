import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const String _baseUrl = 'https://sudoku-auth.onrender.com';

  // Register user
  static Future<bool> registerUser(String email, String password) async {
    final url = Uri.parse('$_baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  // Login user
  static Future<String?> loginUser(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Login failed');
    }
  }
}
