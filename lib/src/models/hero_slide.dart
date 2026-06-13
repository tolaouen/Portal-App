import 'package:flutter/material.dart';

class HeroSlide {
  const HeroSlide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.productId,
    required this.icon,
    required this.gradientColors,
  });

  final String id;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String productId;
  final IconData icon;
  final List<Color> gradientColors;
}
