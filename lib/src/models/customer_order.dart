enum OrderStatus { pending, shipped, delivered, cancelled }

class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.userId,
    required this.date,
    required this.status,
    required this.productIds,
    required this.total,
    required this.paymentMethod,
    required this.address,
  });

  final String id;
  final int userId;
  final DateTime date;
  final OrderStatus status;
  final List<String> productIds;
  final double total;
  final String paymentMethod;
  final String address;

  factory CustomerOrder.fromApiJson(Map<String, dynamic> json) {
    final status = (json['status'] as String? ?? '').trim().toLowerCase();
    return CustomerOrder(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      date:
          DateTime.tryParse(json['order_date'] as String? ?? '') ??
          DateTime.now(),
      status: _parseStatus(status),
      productIds: const [],
      total: (json['total_amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['payment_method'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  static OrderStatus _parseStatus(String value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
