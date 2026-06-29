import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileStorage {
  String _keyFor(int userId) => 'profile_overrides_$userId';

  Future<Map<String, dynamic>?> readProfileOverrides(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(userId));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveProfileOverrides(
    int userId,
    Map<String, dynamic> profile,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFor(userId), jsonEncode(profile));
  }
}
