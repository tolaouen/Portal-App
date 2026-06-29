import 'package:flutter/material.dart';

class HeroSlide {
  const HeroSlide({
    required this.id,
    required this.title,
    required this.subtitle,
    this.description = '',
    required this.ctaLabel,
    this.productId,
    required this.gradientColors,
    this.backgroundImage,
    this.backgroundAssetPath,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String ctaLabel;
  final String? productId;
  final List<Color> gradientColors;
  final String? backgroundImage;
  final String? backgroundAssetPath;

  factory HeroSlide.fromApiJson(Map<String, dynamic> json) {
    final title = (json['title'] as String? ?? '').trim();
    final description = (json['description'] as String? ?? '').trim();
    return HeroSlide(
      id: (json['id'] ?? title).toString(),
      title: title.isEmpty ? 'Next Style' : title,
      subtitle: 'Featured Banner',
      description: description,
      ctaLabel: 'Shop Now',
      productId: null,
      gradientColors: const [
        Color(0xFF163EAE),
        Color(0xFF3565EC),
        Color(0xFF0E1322),
      ],
      backgroundImage: json['banner_image'] as String?,
    );
  }
}
