import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.id,
    required this.code,
    required this.categoryId,
    this.categoryName,
    this.categoryDescription,
    this.createdAt,
    required this.name,
    required this.price,
    required this.stock,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.icon,
    required this.color,
    this.image,
    this.productImages = const [],
    this.sizes = const [],
    this.isPopular = false,
    this.isFeatured = false,
  });

  final String id;
  final String code;
  final String categoryId;
  final String? categoryName;
  final String? categoryDescription;
  final DateTime? createdAt;
  final String name;
  final double price;
  final int stock;
  final double rating;
  final int reviews;
  final String description;
  final IconData icon;
  final Color color;
  final String? image;
  final List<String> productImages;
  final List<String> sizes;
  final bool isPopular;
  final bool isFeatured;

  factory Product.fromApiJson(
    Map<String, dynamic> json, {
    String? overrideCategoryId,
  }) {
    final name = json['name'] as String? ?? 'Unnamed Product';
    final description = json['description'] as String? ?? '';
    final code = (json['code'] as String? ?? '').trim();
    final categoryId = json['category_id'];
    final category = json['category'] as Map<String, dynamic>?;
    final price = json['price'];
    final stock = json['stock'];
    final rating = json['is_rating'] ?? json['rating'];
    final productImages = _extractProductImages(json['product_images']);
    final sizes = _extractSizes(json['size']);
    final image = _firstNonEmptyImage([
      json['image'] as String?,
      if (productImages.isNotEmpty) productImages.first,
    ]);
    final isPopular = _parseBool(json['is_popular']);
    final createdAt = DateTime.tryParse(json['created_at'] as String? ?? '');

    return Product(
      id: (json['id'] ?? name).toString(),
      code: code.isEmpty ? (json['id'] ?? name).toString() : code,
      categoryId: overrideCategoryId ?? categoryId?.toString() ?? 'unknown',
      categoryName: category?['name'] as String?,
      categoryDescription: category?['description'] as String?,
      createdAt: createdAt,
      name: name,
      price: price is num ? price.toDouble() : 0,
      stock: stock is num ? stock.toInt() : 0,
      rating: rating is num ? rating.toDouble() : 0,
      reviews: 0,
      description: description.isEmpty
          ? 'No description available.'
          : description,
      icon: _pickIcon(name, description),
      color: _pickColor(name, image),
      image: image,
      productImages: productImages,
      sizes: sizes,
      isPopular: isPopular,
      isFeatured: isPopular,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  static String? _firstNonEmptyImage(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static List<String> _extractProductImages(dynamic rawImages) {
    if (rawImages is! List) {
      return const [];
    }

    final images = <String>[];
    for (final item in rawImages) {
      if (item is String && item.trim().isNotEmpty) {
        images.add(item.trim());
        continue;
      }
      if (item is Map) {
        final map = item.map(
          (key, value) => MapEntry(key.toString(), value),
        );

        final subImages = map['sub_image'];
        if (subImages is List) {
          for (final subImage in subImages) {
            if (subImage is String && subImage.trim().isNotEmpty) {
              images.add(subImage.trim());
            }
          }
        }

        final nestedImage = map['image'];
        String? resolvedImage;

        if (nestedImage is String) {
          resolvedImage = nestedImage;
        } else if (nestedImage is Map) {
          final nestedMap = nestedImage.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          resolvedImage = _firstNonEmptyImage([
            nestedMap['url'] as String?,
            nestedMap['path'] as String?,
            nestedMap['image'] as String?,
            nestedMap['src'] as String?,
          ]);
        }

        final image = _firstNonEmptyImage([
          resolvedImage,
          map['url'] as String?,
          map['path'] as String?,
          map['src'] as String?,
          map['file'] as String?,
          map['image_url'] as String?,
          map['image_path'] as String?,
          map['photo'] as String?,
        ]);
        if (image != null) {
          images.add(image);
        }
      }
    }
    return images.toSet().toList();
  }

  static List<String> _extractSizes(dynamic rawSizes) {
    if (rawSizes is! List) {
      return const [];
    }

    final sizes = <String>[];
    for (final item in rawSizes) {
      final value = item?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        sizes.add(value);
      }
    }
    return sizes.toSet().toList();
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
