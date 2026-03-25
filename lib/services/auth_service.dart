// lib/services/auth_service.dart

import 'dart:convert';
import 'package:ecommerce_mobile_app/models/register_model.dart';
import 'package:http/http.dart' as http;
import '../models/login_model.dart';

class AuthService {
  // ⚠️ On Android emulator use 10.0.2.2 instead of localhost
  static const String baseUrl = 'http://192.168.1.176:3000/api/auths';

  Future<LoginResponse> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/logins');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return LoginResponse.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Login failed. Please try again.');
    }
  }
  
  Future<RegisterResponse> register(RegisterRequest request) async {
    final url = Uri.parse('$baseUrl/registers');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': request.name,
        'gender' : request.gender,
        'email': request.email,
        'password': request.password,
        'password_confirmation': request.password_confirmation,
        'dob': request.dob,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return RegisterResponse.fromJson(data);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Registration failed. Please try again.');
    }
  }

}