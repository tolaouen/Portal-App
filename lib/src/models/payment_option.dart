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

  String get apiValue {
    switch (this) {
      case PaymentOption.cashOnDelivery:
        return 'cash_on_delivery';
      case PaymentOption.abaBank:
        return 'aba_bank';
      case PaymentOption.wing:
        return 'wing';
      case PaymentOption.card:
        return 'card';
    }
  }

  String get backendPaymentStatus {
    switch (this) {
      case PaymentOption.wing:
        return 'KHQR';
      case PaymentOption.cashOnDelivery:
      case PaymentOption.abaBank:
      case PaymentOption.card:
        return 'Bank Account';
    }
  }
}
