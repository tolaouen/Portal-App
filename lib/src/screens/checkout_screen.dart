import 'package:flutter/material.dart';

import '../models/payment_option.dart';
import '../state/store_scope.dart';
import '../widgets/store_widgets.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.clearBuyNowCheckout();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              controller.clearBuyNowCheckout();
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Checkout',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const Text(
                        'Shipping Address',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        leading: const Icon(Icons.location_on_outlined),
                        title: const Text(
                          'Home',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(controller.shippingAddress),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...PaymentOption.values.map((option) {
                        return PaymentOptionTile(
                          option: option,
                          groupValue: controller.selectedPayment,
                          onChanged: controller.setPaymentOption,
                        );
                      }),
                    ],
                  ),
                ),
                const Divider(height: 24),
                _CheckoutRow(label: 'Subtotal', value: controller.subtotal),
                const SizedBox(height: 8),
                _CheckoutRow(label: 'Shipping', value: controller.shippingFee),
                const SizedBox(height: 12),
                _CheckoutRow(
                  label: 'Total',
                  value: controller.total,
                  bold: true,
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Place Order',
                  onPressed: controller.activeCheckoutItems.isEmpty
                      ? null
                      : () async {
                          await controller.placeOrder();
                          if (!context.mounted) return;
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order placed successfully'),
                            ),
                          );
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutRow extends StatelessWidget {
  const _CheckoutRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 24 : 16,
      fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
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
