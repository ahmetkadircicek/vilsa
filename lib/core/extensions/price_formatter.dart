import 'package:intl/intl.dart';

/// Utility class for formatting prices consistently throughout the app
class PriceFormatter {
  /// The singleton instance
  static final PriceFormatter _instance = PriceFormatter._internal();

  /// The number formatter for currency
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  /// Private constructor
  PriceFormatter._internal();

  /// Factory constructor to return the singleton instance
  factory PriceFormatter() {
    return _instance;
  }

  /// Static getter for the instance
  static PriceFormatter get instance => _instance;

  /// Format a price value to a currency string
  String formatPrice(double price) {
    return _currencyFormat.format(price);
  }

  /// Format a price value without currency symbol
  String formatPriceWithoutSymbol(double price) {
    return _currencyFormat.format(price).replaceAll('₺', '').trim();
  }

  /// Get the currency symbol
  String get currencySymbol => '₺';
}

/// Extension method for double to easily format as price
extension PriceFormatting on double {
  String toPrice() {
    return PriceFormatter.instance.formatPrice(this);
  }

  String toPriceWithoutSymbol() {
    return PriceFormatter.instance.formatPriceWithoutSymbol(this);
  }
}
