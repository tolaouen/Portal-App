import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.icon,
    required this.color,
    this.image,
    this.isFeatured = false,
  });

  final String id;
  final String categoryId;
  final String name;
  final double price;
  final double rating;
  final int reviews;
  final String description;
  final IconData icon;
  final Color color;
  final String? image;
  final bool isFeatured;

  factory Product.fromApiJson(
    Map<String, dynamic> json, {
    String? overrideCategoryId,
  }) {
    final name = json['name'] as String? ?? 'Unnamed Product';
    final description = json['description'] as String? ?? '';
    final categoryId = json['category_id'];
    final price = json['price'];
    final image = json['image'] as String?;

    return Product(
      id: (json['id'] ?? name).toString(),
      categoryId: overrideCategoryId ?? categoryId?.toString() ?? 'unknown',
      name: name,
      price: price is num ? price.toDouble() : 0,
      rating: 4.5,
      reviews: 0,
      description: description.isEmpty
          ? 'No description available.'
          : description,
      icon: _pickIcon(name, description),
      color: _pickColor(name, image),
      image: image,
      isFeatured: false,
    );
  }

  static IconData _pickIcon(String name, String description) {
    final source = '${name.toLowerCase()} ${description.toLowerCase()}';
    if (source.contains('drill')) {
      return Icons.carpenter_rounded;
    }
    if (source.contains('grinder') || source.contains('motor')) {
      return Icons.settings_input_component_rounded;
    }
    if (source.contains('hammer')) {
      return Icons.construction_rounded;
    }
    if (source.contains('tape') || source.contains('measure')) {
      return Icons.straighten_rounded;
    }
    if (source.contains('helmet') || source.contains('safety')) {
      return Icons.health_and_safety_rounded;
    }
    if (source.contains('machine')) {
      return Icons.precision_manufacturing_rounded;
    }
    return Icons.inventory_2_rounded;
  }

  static Color _pickColor(String name, String? image) {
    final source = '${name.toLowerCase()} ${image ?? ''}';
    if (source.contains('drill')) {
      return const Color(0xFFFCC419);
    }
    if (source.contains('grinder') || source.contains('motor')) {
      return const Color(0xFF2EC4C7);
    }
    if (source.contains('hammer')) {
      return const Color(0xFF247BA0);
    }
    if (source.contains('helmet') || source.contains('safety')) {
      return const Color(0xFFFFB703);
    }
    if (source.contains('tape') || source.contains('measure')) {
      return const Color(0xFFF4D35E);
    }
    return const Color(0xFFB8C4D6);
  }
}
