import 'package:flutter/material.dart';

import '../state/store_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/store_widgets.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final cartItems = controller.cart
        .where((item) => controller.productByIdOrNull(item.productId) != null)
        .toList();
    if (!controller.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppTheme.mist,
        appBar: AppBar(
          backgroundColor: AppTheme.mist,
          title: const Text(
            'My Cart',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please login to use your cart.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Login',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.mist,
      body: SafeArea(
        child: cartItems.isEmpty
            ? const _EmptyCart()
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Cart',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: ListView.separated(
                        itemCount: cartItems.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final product = controller.productByIdOrNull(
                            item.productId,
                          );
                          if (product == null) {
                            return const SizedBox.shrink();
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 102,
                                height: 92,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ProductIllustration(
                                  product: product,
                                  size: 88,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      QuantityControl(
                                        quantity: item.quantity,
                                        maxQuantity: product.stock > 0
                                            ? product.stock
                                            : 1,
                                        onChanged: (value) =>
                                            controller.updateCartQuantity(
                                              product.id,
                                              value,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    controller.removeFromCart(product.id),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 26,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _PriceRow(label: 'Sub Total', value: controller.subtotal),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.black45, height: 1),
                    const SizedBox(height: 12),
                    _PriceRow(
                      label: 'Total',
                      value: controller.total,
                      isStrong: true,
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Checkout',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isStrong = false,
  });

  final String label;
  final double value;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isStrong ? 18 : 16,
      fontWeight: isStrong ? FontWeight.w800 : FontWeight.w700,
    );
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text('\$${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Your cart is empty',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
