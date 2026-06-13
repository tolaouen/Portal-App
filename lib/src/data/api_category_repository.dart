import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/store_category.dart';
import 'category_repository.dart';

class ApiCategoryRepository implements CategoryRepository {
  ApiCategoryRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  @override
  Future<List<StoreCategory>> fetchCategories() async {
    try {
      final response = await _client
          .get(
            _uri(AppConfig.categoryPath),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw CategoryException(
          'Unable to load categories. Status ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const CategoryException('Invalid category response.');
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(StoreCategory.fromApiJson)
          .toList();
    } on TimeoutException {
      throw const CategoryException(
        'Category server is taking too long to respond.',
      );
    } on SocketException {
      throw const CategoryException(
        'No internet connection or category server is unreachable.',
      );
    } on http.ClientException {
      throw const CategoryException('Unable to reach category server.');
    } on FormatException {
      throw const CategoryException('Invalid category response.');
    }
  }
}

class CategoryException implements Exception {
  const CategoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
