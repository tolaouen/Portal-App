import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'payment_repository.dart';

class ApiPaymentRepository implements PaymentRepository {
  ApiPaymentRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  @override
  Future<void> createPayment({
    required int orderId,
    required double amount,
    required String paymentMethod,
    required String paymentStatus,
    required String paymentDate,
  }) async {
    try {
      final response = await _client
          .post(
            _uri(AppConfig.paymentPath),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'order_id': orderId,
              'amount': amount,
              'payment_method': paymentMethod,
              'payment_status': paymentStatus,
              'payment_date': paymentDate,
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw PaymentException(_extractMessage(response));
      }
    } on TimeoutException {
      throw const PaymentException(
        'Payment server is taking too long to respond.',
      );
    } on SocketException {
      throw const PaymentException(
        'No internet connection or payment server is unreachable.',
      );
    } on http.ClientException {
      throw const PaymentException('Unable to reach payment server.');
    } on FormatException {
      throw const PaymentException('Invalid payment response.');
    }
  }

  String _extractMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
        final detail = decoded['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }
        if (detail is List && detail.isNotEmpty) {
          final firstDetail = detail.first;
          if (firstDetail is Map<String, dynamic>) {
            final detailMessage = firstDetail['msg'];
            if (detailMessage is String && detailMessage.trim().isNotEmpty) {
              return detailMessage;
            }
          }
        }
      }
    } catch (_) {}
    return 'Unable to create payment. Status ${response.statusCode}.';
  }
}

class PaymentException implements Exception {
  const PaymentException(this.message);

  final String message;

  @override
  String toString() => message;
}
