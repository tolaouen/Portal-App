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

  CustomerOrder copyWith({
    String? id,
    int? userId,
    DateTime? date,
    OrderStatus? status,
    List<String>? productIds,
    double? total,
    String? paymentMethod,
    String? address,
  }) {
    return CustomerOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      status: status ?? this.status,
      productIds: productIds ?? this.productIds,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      address: address ?? this.address,
    );
  }

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] as String? ?? '').trim().toLowerCase();
    final rawProductIds = json['product_ids'] as List<dynamic>? ?? const [];
    return CustomerOrder(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      date:
          DateTime.tryParse(json['order_date'] as String? ?? '') ??
          DateTime.now(),
      status: _parseStatus(status),
      productIds: rawProductIds.map((id) => id.toString()).toList(),
      total: (json['total_amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['payment_method'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_date': date.toIso8601String(),
      'status': status.name,
      'product_ids': productIds,
      'total_amount': total,
      'payment_method': paymentMethod,
      'address': address,
    };
  }

  static OrderStatus _parseStatus(String value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'process':
      case 'shipped':
        return OrderStatus.shipped;
      case 'completed':
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
