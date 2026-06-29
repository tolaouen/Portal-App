import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/customer_order.dart';
import '../models/order_item.dart';
import 'order_repository.dart';

class ApiOrderRepository implements OrderRepository {
  ApiOrderRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  @override
  Future<List<CustomerOrder>> fetchOrders() async {
    try {
      final responses = await Future.wait([
        _client.get(
          _uri(AppConfig.orderPath),
          headers: const {'Accept': 'application/json'},
        ),
        _client.get(
          _uri(AppConfig.orderItemPath),
          headers: const {'Accept': 'application/json'},
        ),
      ]).timeout(const Duration(seconds: 25));

      final orderResponse = responses[0];
      final itemResponse = responses[1];

      if (orderResponse.statusCode != 200) {
        throw OrderException(
          'Unable to load orders. Status ${orderResponse.statusCode}.',
        );
      }
      if (itemResponse.statusCode != 200) {
        throw OrderException(
          'Unable to load order items. Status ${itemResponse.statusCode}.',
        );
      }

      final decodedOrders = jsonDecode(orderResponse.body);
      if (decodedOrders is! List) {
        throw const OrderException('Invalid order response.');
      }

      final decodedItems = jsonDecode(itemResponse.body);
      if (decodedItems is! List) {
        throw const OrderException('Invalid order item response.');
      }

      final orderItems = decodedItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItemPayload.fromApiJson)
          .toList();

      return decodedOrders.whereType<Map<String, dynamic>>().map((json) {
        final order = CustomerOrder.fromApiJson(json);
        final orderId = int.tryParse(order.id);
        final productIds = orderItems
            .where((item) => item.orderId == orderId)
            .map((item) => item.productId?.toString())
            .whereType<String>()
            .toList();
        return order.copyWith(productIds: productIds);
      }).toList();
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

  @override
  Future<CustomerOrder> createOrder({
    required CustomerOrder order,
    required List<OrderItemPayload> items,
  }) async {
    try {
      final orderResponse = await _client
          .post(
            _uri(AppConfig.orderPath),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'user_id': order.userId == 0 ? null : order.userId,
              'status': _statusToApiValue(order.status),
              'total_amount': order.total,
              'payment_method': order.paymentMethod,
              'address': order.address,
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (orderResponse.statusCode != 200 && orderResponse.statusCode != 201) {
        throw OrderException(
          'Unable to create order. Status ${orderResponse.statusCode}.',
        );
      }

      final decodedOrder = jsonDecode(orderResponse.body);
      if (decodedOrder is! Map<String, dynamic>) {
        throw const OrderException('Invalid create order response.');
      }

      final createdOrder = CustomerOrder.fromApiJson(decodedOrder);
      final createdOrderId = int.tryParse(createdOrder.id);

      final createdItems = <OrderItemPayload>[];
      for (final item in items) {
        final payload = item.copyWith(orderId: createdOrderId).toJson();
        final response = await _postOrderItem(payload);

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw OrderException(
            'Unable to create order item. Status ${response.statusCode}.',
          );
        }

        final decodedItem = jsonDecode(response.body);
        if (decodedItem is List && decodedItem.isNotEmpty) {
          final firstItem = decodedItem.first;
          if (firstItem is Map<String, dynamic>) {
            createdItems.add(OrderItemPayload.fromApiJson(firstItem));
            continue;
          }
        }
        if (decodedItem is! Map<String, dynamic>) {
          throw const OrderException('Invalid order item response.');
        }

        createdItems.add(OrderItemPayload.fromApiJson(decodedItem));
      }

      final productIds = createdItems
          .map((item) => item.productId?.toString())
          .whereType<String>()
          .toList();

      return createdOrder.copyWith(productIds: productIds);
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

  Future<http.Response> _postOrderItem(Map<String, dynamic> payload) async {
    final headers = const {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final addCartResponse = await _client.post(
      _uri(AppConfig.addCartPath),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (addCartResponse.statusCode != 404) {
      return addCartResponse;
    }

    return _client.post(
      _uri(AppConfig.orderItemPath),
      headers: headers,
      body: jsonEncode(payload),
    );
  }

  String _statusToApiValue(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.shipped:
        return 'Process';
      case OrderStatus.delivered:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderException implements Exception {
  const OrderException(this.message);

  final String message;

  @override
  String toString() => message;
}
