import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/customer_order.dart';
import '../models/payment_option.dart';
import '../models/product.dart';
import '../models/store_category.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionLabel,
            style: const TextStyle(color: AppTheme.brand),
          ),
        ),
      ],
    );
  }
}

class CategoryChipCard extends StatelessWidget {
  const CategoryChipCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final StoreCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 68),
        height: 36,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          category.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.dark,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final illustrationSize = (constraints.maxWidth * 0.68).clamp(
            102.0,
            142.0,
          );
          final imagePanelHeight = (constraints.maxHeight * 0.40).clamp(
            108.0,
            122.0,
          );

          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EBF2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: imagePanelHeight,
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(2, 2, 2, 4),
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (product.isPopular)
                        Positioned(
                          right: -2,
                          top: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5C92F3),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Popular',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      Center(
                        child: ProductIllustration(
                          product: product,
                          size: illustrationSize,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            height: 1.12,
                            color: AppTheme.dark,
                          ),
                        ),
                        if (product.rating > 1) ...[
                          const SizedBox(height: 0.5),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 11,
                                color: AppTheme.brand,
                              ),
                              const Icon(
                                Icons.star_rounded,
                                size: 11,
                                color: AppTheme.brand,
                              ),
                              const Icon(
                                Icons.star_rounded,
                                size: 11,
                                color: AppTheme.brand,
                              ),
                              Icon(
                                Icons.star_rounded,
                                size: 11,
                                color: AppTheme.brand.withValues(alpha: 0.35),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 3),
                        SizedBox(
                          height: 14,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              product.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                height: 1.2,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${product.price.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.dark,
                          ),
                        ),
                        const SizedBox(height: 0.5),
                        Text(
                          product.stock > 0
                              ? 'In stock: ${product.stock}'
                              : 'Out of stock',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: product.stock > 0
                                ? const Color(0xFF3D7CFF)
                                : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProductIllustration extends StatelessWidget {
  const ProductIllustration({
    super.key,
    required this.product,
    this.imageSource,
    this.size = 96,
  });

  final Product product;
  final String? imageSource;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolvedImage = imageSource ?? product.image;
    final imageBytes = _decodeProductImage(resolvedImage);
    final imageUrl = _normalizeImageUrl(resolvedImage);
    final hasImage = imageBytes != null || imageUrl != null;

    return SizedBox(
      width: size,
      height: size * 0.88,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: hasImage ? 0 : 10,
          vertical: hasImage ? 2 : 10,
        ),
        child: imageBytes != null
            ? Image.memory(
                imageBytes,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => _fallbackIcon(),
              )
            : imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => _fallbackIcon(),
              )
            : _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Icon(product.icon, size: size * 0.52, color: AppTheme.dark);
  }

  Uint8List? _decodeProductImage(String? rawImage) {
    if (rawImage == null || rawImage.trim().isEmpty) {
      return null;
    }

    if (_normalizeImageUrl(rawImage) != null) {
      return null;
    }

    try {
      final normalized = rawImage.contains(',')
          ? rawImage.split(',').last
          : rawImage;
      return base64Decode(normalized);
    } catch (_) {
      return null;
    }
  }

  String? _normalizeImageUrl(String? rawImage) {
    if (rawImage == null || rawImage.trim().isEmpty) {
      return null;
    }
    final normalized = rawImage.trim();
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }
    return null;
  }
}

class QuantityControl extends StatelessWidget {
  const QuantityControl({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.maxQuantity,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int? maxQuantity;

  @override
  Widget build(BuildContext context) {
    final canDecrease = quantity > 1;
    final canIncrease =
        maxQuantity == null ? true : quantity < (maxQuantity ?? quantity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove,
            onTap: canDecrease ? () => onChanged(quantity - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            onTap: canIncrease ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Icon(
          icon,
          size: 15,
          color: onTap == null ? Colors.black26 : null,
        ),
      ),
    );
  }
}

class PaymentOptionTile extends StatelessWidget {
  const PaymentOptionTile({
    super.key,
    required this.option,
    required this.groupValue,
    required this.onChanged,
  });

  final PaymentOption option;
  final PaymentOption groupValue;
  final ValueChanged<PaymentOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = option == groupValue;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onChanged(option),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppTheme.brand : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              option.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
      case OrderStatus.shipped:
        color = Colors.blue;
      case OrderStatus.delivered:
        color = Colors.green;
      case OrderStatus.cancelled:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isEnabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.brand,
          foregroundColor: AppTheme.dark,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.dark),
                ),
              ),
              const SizedBox(width: 12),
            ] else if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 10),
            ],
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
