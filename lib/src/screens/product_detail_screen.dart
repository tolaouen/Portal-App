import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/store_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/store_widgets.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final product = widget.product;
    final isFavorite = controller.isFavorite(product.id);
    final totalPrice = product.price * quantity;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(
            onPressed: () => controller.toggleFavorite(product.id),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: AppTheme.brand,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: ProductIllustration(product: product, size: 220)),
              const SizedBox(height: 26),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: AppTheme.brand),
                  const SizedBox(width: 6),
                  Text(
                    '${product.rating} (${product.reviews} reviews)',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Price per item',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 18),
              Text(
                product.description,
                style: const TextStyle(height: 1.65, color: Colors.black87),
              ),
              const SizedBox(height: 28),
              const Text(
                'Quantity',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              QuantityControl(
                quantity: quantity,
                onChanged: (value) =>
                    setState(() => quantity = value < 1 ? 1 : value),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.brand,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Add to Cart',
                icon: Icons.shopping_cart_outlined,
                onPressed: () {
                  controller.addToCart(product.id, quantity: quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart')),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  controller.startBuyNowCheckout(
                    product.id,
                    quantity: quantity,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.flash_on_outlined),
                label: const Text('Buy Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
