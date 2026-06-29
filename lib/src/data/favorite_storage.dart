import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FavoriteStorage {
  String _keyForUser(int userId) => 'favorite_products_$userId';

  Future<Set<String>> readFavorites(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <String>{};
    }
    return decoded.whereType<String>().toSet();
  }

  Future<void> saveFavorites(int userId, Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyForUser(userId), jsonEncode(favorites.toList()));
  }
}
