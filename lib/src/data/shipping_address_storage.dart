import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShippingAddressStorage {
  static const _shippingAddressKey = 'shipping_address';

  Future<Map<String, String>?> readShippingAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_shippingAddressKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return {
      'label': (decoded['label'] as String? ?? '').trim(),
      'address': (decoded['address'] as String? ?? '').trim(),
    };
  }

  Future<void> saveShippingAddress({
    required String label,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _shippingAddressKey,
      jsonEncode({'label': label, 'address': address}),
    );
  }
}
