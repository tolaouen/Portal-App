import 'package:flutter/material.dart';

import '../models/customer_order.dart';
import '../models/product.dart';
import '../state/store_controller.dart';
import '../state/store_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/store_widgets.dart';
import 'login_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    if (!controller.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppTheme.mist,
        appBar: AppBar(
          backgroundColor: AppTheme.mist,
          title: const Text(
            'My Order',
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
                  'Please login to view your orders.',
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

    final orders = controller.orders;

    return Scaffold(
      backgroundColor: AppTheme.mist,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadOrders,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
            children: [
              const Center(
                child: Text(
                  'My Order',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 20),
              if (controller.isLoadingOrders && orders.isEmpty)
                const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.orderErrorMessage != null && orders.isEmpty)
                _OrdersMessage(
                  title: 'Unable to load orders',
                  message: controller.orderErrorMessage!,
                )
              else if (orders.isEmpty)
                const _OrdersMessage(
                  title: 'No orders yet',
                  message: 'Orders from the API will appear here.',
                )
              else
                ...orders.map((order) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _OrderCard(
                        order: order,
                        controller: controller,
                        onChangeStatus: (status) => _changeOrderStatus(
                          context,
                          controller,
                          order,
                          status,
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeOrderStatus(
    BuildContext context,
    StoreController controller,
    CustomerOrder order,
    OrderStatus nextStatus,
  ) async {
    await controller.updateOrderStatus(order.id, nextStatus);
    if (!context.mounted) {
      return;
    }
    final statusLabel =
        nextStatus.name[0].toUpperCase() + nextStatus.name.substring(1);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Order ${order.id} moved to $statusLabel.')),
      );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.controller,
    required this.onChangeStatus,
  });

  final CustomerOrder order;
  final StoreController controller;
  final ValueChanged<OrderStatus> onChangeStatus;

  @override
  Widget build(BuildContext context) {
    final products = order.productIds
        .map(controller.productByIdOrNull)
        .whereType<Product>()
        .toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Order No: ${order.id}\n${_formatDate(order.date)}',
                  style: const TextStyle(height: 1.5),
                ),
              ),
              StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text('Payment Method: ${order.paymentMethod}'),
          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Address: ${order.address}'),
          ],
          if (products.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: products
                  .take(3)
                  .map(
                    (product) => Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(0xFFF7F8FA),
                      ),
                      child: ProductIllustration(product: product, size: 44),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text('${order.productIds.length} items'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _buildOrderActions(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrderActions() {
    switch (order.status) {
      case OrderStatus.pending:
        return [
          _ActionChip(
            label: 'Ship',
            onTap: () => onChangeStatus(OrderStatus.shipped),
          ),
          _ActionChip(
            label: 'Cancel',
            onTap: () => onChangeStatus(OrderStatus.cancelled),
          ),
        ];
      case OrderStatus.shipped:
        return [
          _ActionChip(
            label: 'Deliver',
            onTap: () => onChangeStatus(OrderStatus.delivered),
          ),
        ];
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return const [];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F7EB),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF25B33F),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _OrdersMessage extends StatelessWidget {
  const _OrdersMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}
