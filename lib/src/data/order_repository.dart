import '../models/customer_order.dart';
import '../models/order_item.dart';

abstract class OrderRepository {
  Future<List<CustomerOrder>> fetchOrders();
  Future<CustomerOrder> createOrder({
    required CustomerOrder order,
    required List<OrderItemPayload> items,
  });
}
