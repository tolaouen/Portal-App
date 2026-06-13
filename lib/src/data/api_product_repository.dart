import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/product.dart';
import 'product_repository.dart';

class ApiProductRepository implements ProductRepository {
  ApiProductRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  @override
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .get(
            _uri(AppConfig.productPath),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw ProductException(
          'Unable to load products. Status ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const ProductException('Invalid product response.');
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Product.fromApiJson)
          .toList();
    } on TimeoutException {
      throw const ProductException(
        'Product server is taking too long to respond.',
      );
    } on SocketException {
      throw const ProductException(
        'No internet connection or product server is unreachable.',
      );
    } on http.ClientException {
      throw const ProductException('Unable to reach product server.');
    } on FormatException {
      throw const ProductException('Invalid product response.');
    }
  }
}

class ProductException implements Exception {
  const ProductException(this.message);

  final String message;

  @override
  String toString() => message;
}
