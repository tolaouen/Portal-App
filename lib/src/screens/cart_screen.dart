import 'package:flutter/material.dart';

import '../state/store_scope.dart';
import '../widgets/store_widgets.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [TextButton(onPressed: () {}, child: const Text('Edit'))],
      ),
      body: controller.cart.isEmpty
          ? const _EmptyCart()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: controller.cart.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 18),
                        itemBuilder: (context, index) {
                          final item = controller.cart[index];
                          final product = controller.productById(
                            item.productId,
                          );
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductIllustration(product: product, size: 82),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    QuantityControl(
                                      quantity: item.quantity,
                                      onChanged: (value) =>
                                          controller.updateCartQuantity(
                                            product.id,
                                            value,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    controller.removeFromCart(product.id),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    _PriceRow(label: 'Subtotal', value: controller.subtotal),
                    const SizedBox(height: 10),
                    _PriceRow(label: 'Shipping', value: controller.shippingFee),
                    const Divider(height: 30),
                    _PriceRow(
                      label: 'Total',
                      value: controller.total,
                      isStrong: true,
                    ),
                    const SizedBox(height: 18),
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
      fontSize: isStrong ? 22 : 16,
      fontWeight: isStrong ? FontWeight.w900 : FontWeight.w600,
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
    return const Center(child: Text('Your cart is empty'));
  }
}
