enum PaymentOption { cashOnDelivery, abaBank, wing, card }

extension PaymentOptionX on PaymentOption {
  String get label {
    switch (this) {
      case PaymentOption.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentOption.abaBank:
        return 'ABA Bank';
      case PaymentOption.wing:
        return 'Wing';
      case PaymentOption.card:
        return 'Credit/Debit Card';
    }
  }
}
