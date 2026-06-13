import '../models/customer_order.dart';

abstract class OrderRepository {
  Future<List<CustomerOrder>> fetchOrders();
}
