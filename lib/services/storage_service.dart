// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey  = 'access_token';
  static const _idKey     = 'user_id';
  static const _nameKey   = 'user_name';
  static const _emailKey  = 'user_email';
  static const _roleKey   = 'user_role';
  static const _genderKey = 'user_gender';
  static const _dobKey    = 'user_dob';

  // ── Save ───────────────────────────────────────────────────────────────────

  static Future<void> saveLoginData({
    required String token,
    required int userId,
    required String name,
    required String email,
    required String role,
    String? gender,
    String? dob,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_idKey, userId);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_roleKey, role);
    if (gender != null) await prefs.setString(_genderKey, gender);
    if (dob != null)    await prefs.setString(_dobKey, dob);
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<String?> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_genderKey);
  }

  static Future<String?> getDob() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dobKey);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_idKey);
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return null;
    return {
      'id':     prefs.getInt(_idKey),
      'name':   prefs.getString(_nameKey),
      'email':  prefs.getString(_emailKey),
      'role':   prefs.getString(_roleKey),
      'gender': prefs.getString(_genderKey),
      'dob':    prefs.getString(_dobKey),
    };
  }

  // ── Auth state ─────────────────────────────────────────────────────────────

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Update name locally after profile edit ─────────────────────────────────

  static Future<void> updateName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  static Future<void> updateProfile({
    String? name,
    String? email,
    String? gender,
    String? dob,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null)   await prefs.setString(_nameKey, name);
    if (email != null)  await prefs.setString(_emailKey, email);
    if (gender != null) await prefs.setString(_genderKey, gender);
    if (dob != null)    await prefs.setString(_dobKey, dob);
  }

  // ── Clear ──────────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}