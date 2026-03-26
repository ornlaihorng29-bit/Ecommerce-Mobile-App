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
    // ✅ All platforms use Railway
    return 'https://ecommerce-app-full-stack-production-d7a8.up.railway.app/api';
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
    // ✅ Check content type before decoding
    final contentType = response.headers['content-type'] ?? '';
    final isJson = contentType.contains('application/json');

    if (!isJson) {
      throw Exception(
        'Server error (${response.statusCode}). Please try again later.',
      );
    }

    final data = jsonDecode(response.body); // now safe to decode

    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    }
    if (response.statusCode == 403) {
      throw Exception('Access denied.');
    }
    if (response.statusCode == 503) {
      throw Exception('Service temporarily unavailable. Please try again.');
    }

    throw Exception(data['message'] ?? 'Something went wrong.');
  }
}

class ApiConfig {
  ApiConfig._();
  static String? overrideUrl;
}