// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'storage_service.dart';

class ApiService {
  static String get baseUrl {
    if (ApiConfig.overrideUrl != null) return ApiConfig.overrideUrl!;
    if (kDebugMode) {
      if (kIsWeb)             return 'http://localhost:3000/api';
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
      if (Platform.isIOS)     return 'http://127.0.0.1:3000/api';
    }
    return 'http://192.168.1.247:3000/api';
  }

  // ── JSON headers (Content-Type: application/json) ──────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Multipart headers — NO Content-Type, let http package set it ───────────
  // ⚠️ Never set Content-Type manually for multipart — the boundary won't match
  static Future<Map<String, String>> _multipartHeaders() async {
    final token = await StorageService.getToken();
    return {
      // ✅ Only Accept + Authorization — http.MultipartRequest sets Content-Type
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── JSON methods ───────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> patch(
      String endpoint, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders(),
    );
    return _handleResponse(response);
  }

  // ── Multipart upload — web-safe ────────────────────────────────────────────

  static Future<Map<String, dynamic>> uploadXFile({
    required String endpoint,
    required String fieldName,
    required XFile file,
    String method = 'POST',
    Map<String, String> fields = const {},
  }) async {
    final uri     = Uri.parse('$baseUrl$endpoint');
    final headers = await _multipartHeaders(); // ← no Content-Type override
    final bytes   = await file.readAsBytes();
    final filename = file.name.isNotEmpty ? file.name : 'upload.jpg';

    final request = http.MultipartRequest(method, uri)
      ..headers.addAll(headers)   // only Accept + Authorization
      ..fields.addAll(fields)
      ..files.add(http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
      ));

    final streamed  = await request.send();
    final response  = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  // ── Response handler ───────────────────────────────────────────────────────

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) return data;
    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    }
    if (response.statusCode == 403) {
      throw Exception('Access denied.');
    }
    throw Exception(data['message'] ?? 'Something went wrong.');
  }
}

class ApiConfig {
  ApiConfig._();
  static String? overrideUrl;
}