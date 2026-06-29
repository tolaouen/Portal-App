import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/product.dart';
import 'product_repository.dart';

class ApiProductRepository implements ProductRepository {
  ApiProductRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _requestTimeout = Duration(seconds: 60);

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  @override
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _sendRequest();

      if (response.statusCode != 200) {
        throw ProductException(
          'Unable to load products. Status ${response.statusCode}.',
        );
      }

      return compute(_parseProducts, response.body);
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

  Future<http.Response> _sendRequest() async {
    try {
      return await _client
          .get(
            _uri(AppConfig.productPath),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      return _client
          .get(
            _uri(AppConfig.productPath),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(_requestTimeout);
    }
  }
}

List<Product> _parseProducts(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! List) {
    throw const ProductException('Invalid product response.');
  }

  return decoded
      .whereType<Map<String, dynamic>>()
      .map(Product.fromApiJson)
      .toList();
}

class ProductException implements Exception {
  const ProductException(this.message);

  final String message;

  @override
  String toString() => message;
}
