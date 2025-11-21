import 'package:intl/intl.dart';

String formatCurrency(double amount, {String symbol = '₹'}) {
  final decimals = amount % 1 == 0 ? 0 : 2;
  return NumberFormat.currency(
    locale: 'en_IN',
    symbol: symbol,
    decimalDigits: decimals,
  ).format(amount);
}

String formatCompactCurrency(double amount, {String symbol = '₹'}) {
  return NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: symbol,
  ).format(amount);
}

String formatDateTime(DateTime date) => DateFormat('d MMM, h:mm a').format(date);

String formatShortDate(DateTime date) => DateFormat('d MMM').format(date);
