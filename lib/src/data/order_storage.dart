import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer_order.dart';

class OrderStorage {
  static const String _ordersKey = 'local_orders';

  Future<List<CustomerOrder>> readOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ordersKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CustomerOrder.fromJson)
        .toList();
  }

  Future<void> saveOrders(List<CustomerOrder> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(orders.map((order) => order.toJson()).toList());
    await prefs.setString(_ordersKey, raw);
  }
}
