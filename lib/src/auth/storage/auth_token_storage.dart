import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_token.dart';

class AuthTokenStorage {
  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(AuthToken token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, jsonEncode(token.toJson()));
  }

  Future<AuthToken?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tokenKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return AuthToken.fromJson(json);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
