import 'package:flutter/material.dart';

import 'product.dart';

class StoreCategory {
  const StoreCategory({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.icon,
    this.products = const [],
  });

  final String id;
  final String name;
  final int itemCount;
  final IconData icon;
  final List<Product> products;

  factory StoreCategory.fromApiJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Unnamed Category';
    final description = json['description'] as String? ?? '';
    final rawId = json['id'];
    final categoryId = rawId?.toString() ?? _slugify(name);
    final products = (json['products'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (productJson) =>
              Product.fromApiJson(productJson, overrideCategoryId: categoryId),
        )
        .toList();
    return StoreCategory(
      id: categoryId,
      name: name,
      itemCount: (json['item_count'] as num?)?.toInt() ?? products.length,
      icon: _pickIcon(name, description),
      products: products,
    );
  }

  static IconData _pickIcon(String name, String description) {
    final source = '${name.toLowerCase()} ${description.toLowerCase()}';
    if (source.contains('motor') || source.contains('machine')) {
      return Icons.precision_manufacturing_rounded;
    }
    if (source.contains('electric') || source.contains('power')) {
      return Icons.power_rounded;
    }
    if (source.contains('safety')) {
      return Icons.health_and_safety_rounded;
    }
    if (source.contains('measure')) {
      return Icons.straighten_rounded;
    }
    if (source.contains('concrete')) {
      return Icons.foundation_rounded;
    }
    if (source.contains('hand')) {
      return Icons.handyman_rounded;
    }
    return Icons.category_rounded;
  }

  static String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
