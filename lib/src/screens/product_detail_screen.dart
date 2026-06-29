import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/store_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/store_widgets.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  String? selectedSize;
  int selectedPreview = 0;

  @override
  void initState() {
    super.initState();
    final sizes = widget.product.sizes;
    if (sizes.isNotEmpty) {
      selectedSize = sizes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final product = widget.product;
    final galleryImages = {
      if (product.image != null && product.image!.trim().isNotEmpty)
        product.image!.trim(),
      ...product.productImages.where((image) => image.trim().isNotEmpty),
    }.toList();
    final selectedImage = galleryImages.isNotEmpty &&
            selectedPreview >= 0 &&
            selectedPreview < galleryImages.length
        ? galleryImages[selectedPreview]
        : product.image;
    final maxStock = product.stock < 0 ? 0 : product.stock;
    final isFavorite = controller.isFavorite(product.id);
    final totalPrice = product.price * quantity;
    final sizes = product.sizes;

    return Scaffold(
      backgroundColor: AppTheme.mist,
      appBar: AppBar(
        backgroundColor: AppTheme.mist,
        leading: const BackButton(),
        centerTitle: true,
        title: const Text(
          'Product Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleFavoriteTap(context, product.id),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: AppTheme.brand,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 252,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: ProductIllustration(
                    product: product,
                    imageSource: selectedImage,
                    size: 205,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (sizes.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var index = 0; index < sizes.length; index++) ...[
                        if (index > 0) const SizedBox(width: 10),
                        _SizeChip(
                          label: sizes[index],
                          selected: selectedSize == sizes[index],
                          onTap: () =>
                              setState(() => selectedSize = sizes[index]),
                        ),
                      ],
                    ],
                  ),
                ),
              if (galleryImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: galleryImages.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return _PreviewThumb(
                        product: product,
                        imageSource: galleryImages[index],
                        selected: selectedPreview == index,
                        onTap: () => setState(() => selectedPreview = index),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (product.rating > 1) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 18, color: AppTheme.brand),
                    const Icon(Icons.star, size: 18, color: AppTheme.brand),
                    const Icon(Icons.star, size: 18, color: AppTheme.brand),
                    Icon(
                      Icons.star,
                      size: 18,
                      color: AppTheme.brand.withValues(alpha: 0.35),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Text(
                '\$${product.price.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                maxStock > 0 ? 'In stock: $maxStock' : 'Out of Stock',
                style: TextStyle(
                  color: maxStock > 0 ? const Color(0xFF3D7CFF) : Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Quality',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              QuantityControl(
                quantity: quantity,
                maxQuantity: maxStock > 0 ? maxStock : 1,
                onChanged: (value) => setState(
                  () => quantity = value.clamp(1, maxStock > 0 ? maxStock : 1),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${totalPrice.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.brand,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Add to cart',
                icon: Icons.shopping_cart_outlined,
                onPressed: maxStock <= 0
                    ? null
                    : () {
                        if (!_ensureLoggedIn(context)) return;
                        final added = controller.addToCart(
                          product.id,
                          quantity: quantity,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              added
                                  ? '${product.name} added to cart'
                                  : '${product.name} is out of stock',
                            ),
                          ),
                        );
                      },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: maxStock <= 0
                    ? null
                    : () {
                        if (!_ensureLoggedIn(context)) return;
                        final started = controller.startBuyNowCheckout(
                          product.id,
                          quantity: quantity,
                        );
                        if (!started) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} is out of stock'),
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.brand,
                  backgroundColor: Colors.transparent,
                  side: BorderSide.none,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.crop_free_rounded),
                label: Text(maxStock > 0 ? 'Buy Now' : 'Out of Stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _ensureLoggedIn(BuildContext context) {
    final controller = StoreScope.of(context);
    if (controller.isLoggedIn) {
      return true;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
    return false;
  }

  void _handleFavoriteTap(BuildContext context, String productId) {
    if (!_ensureLoggedIn(context)) return;
    StoreScope.of(context).toggleFavorite(productId);
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4E89EF) : Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PreviewThumb extends StatelessWidget {
  const _PreviewThumb({
    required this.product,
    required this.imageSource,
    required this.selected,
    required this.onTap,
  });

  final Product product;
  final String imageSource;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF4E89EF) : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: ProductIllustration(
          product: product,
          imageSource: imageSource,
          size: 42,
        ),
      ),
    );
  }
}
