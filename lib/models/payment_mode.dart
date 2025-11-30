enum PaymentMode {
  upi,
  creditCard,
  debitCard,
  cash;

  String get displayName {
    switch (this) {
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.creditCard:
        return 'Credit Card';
      case PaymentMode.debitCard:
        return 'Debit Card';
      case PaymentMode.cash:
        return 'Hand Cash';
    }
  }
}
