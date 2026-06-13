import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/customer_order.dart';
import 'order_repository.dart';

class ApiOrderRepository implements OrderRepository {
  ApiOrderRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  @override
  Future<List<CustomerOrder>> fetchOrders() async {
    try {
      final response = await _client
          .get(
            _uri(AppConfig.orderPath),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw OrderException(
          'Unable to load orders. Status ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const OrderException('Invalid order response.');
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CustomerOrder.fromApiJson)
          .toList();
    } on TimeoutException {
      throw const OrderException('Order server is taking too long to respond.');
    } on SocketException {
      throw const OrderException(
        'No internet connection or order server is unreachable.',
      );
    } on http.ClientException {
      throw const OrderException('Unable to reach order server.');
    } on FormatException {
      throw const OrderException('Invalid order response.');
    }
  }
}

class OrderException implements Exception {
  const OrderException(this.message);

  final String message;

  @override
  String toString() => message;
}
