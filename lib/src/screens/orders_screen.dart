import 'package:flutter/material.dart';

import '../models/customer_order.dart';
import '../state/store_scope.dart';
import '../widgets/store_widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus? selectedFilter;

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final orders = selectedFilter == null
        ? controller.orders
        : controller.orders
              .where((order) => order.status == selectedFilter)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadOrders,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: selectedFilter == null,
                      onTap: () => setState(() => selectedFilter = null),
                    ),
                    ...OrderStatus.values.map((status) {
                      return _FilterChip(
                        label:
                            status.name[0].toUpperCase() +
                            status.name.substring(1),
                        selected: selectedFilter == status,
                        onTap: () => setState(() => selectedFilter = status),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (controller.isLoadingOrders && orders.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.orderErrorMessage != null &&
                        orders.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _OrdersMessage(
                            title: 'Unable to load orders',
                            message: controller.orderErrorMessage!,
                          ),
                        ],
                      );
                    }

                    if (orders.isEmpty) {
                      return const _OrdersMessage(
                        title: 'No orders yet',
                        message: 'Orders from the API will appear here.',
                      );
                    }

                    return ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final products = order.productIds
                            .map(controller.productById)
                            .toList();
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Order ${order.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  StatusChip(status: order.status),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(order.date),
                                style: const TextStyle(color: Colors.black54),
                              ),
                              if (order.paymentMethod.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  'Payment: ${order.paymentMethod}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              if (order.address.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  order.address,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                              if (products.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 62,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: products.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 10),
                                    itemBuilder: (context, productIndex) {
                                      return ProductIllustration(
                                        product: products[productIndex],
                                        size: 62,
                                      );
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Text(
                                    '\$${order.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    products.isNotEmpty
                                        ? '${products.length} items'
                                        : 'User #${order.userId}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
