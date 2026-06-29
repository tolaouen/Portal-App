class OrderItemPayload {
  const OrderItemPayload({
    this.id,
    this.orderId,
    this.productId,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
  });

  final int? id;
  final int? orderId;
  final int? productId;
  final int qty;
  final double unitPrice;
  final double subtotal;

  factory OrderItemPayload.fromApiJson(Map<String, dynamic> json) {
    return OrderItemPayload(
      id: (json['id'] as num?)?.toInt(),
      orderId: (json['order_id'] as num?)?.toInt(),
      productId: (json['product_id'] as num?)?.toInt(),
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'qty': qty,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  OrderItemPayload copyWith({
    int? id,
    int? orderId,
    int? productId,
    int? qty,
    double? unitPrice,
    double? subtotal,
  }) {
    return OrderItemPayload(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}
