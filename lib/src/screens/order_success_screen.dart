import 'package:flutter/material.dart';

import '../models/customer_order.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final CustomerOrder order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mist,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.brand,
                    child: Icon(
                      Icons.check_rounded,
                      size: 38,
                      color: AppTheme.dark,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Order Confirmed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your order #${order.id} and payment were created successfully.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ID: ${order.id}'),
                        const SizedBox(height: 6),
                        Text('Total: \$${order.total.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        Text('Payment: ${order.paymentMethod}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainShell()),
                        (route) => false,
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.brand,
                      foregroundColor: AppTheme.dark,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Go to Orders',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
