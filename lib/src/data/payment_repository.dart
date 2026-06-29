abstract class PaymentRepository {
  Future<void> createPayment({
    required int orderId,
    required double amount,
    required String paymentMethod,
    required String paymentStatus,
    required String paymentDate,
  });
}
