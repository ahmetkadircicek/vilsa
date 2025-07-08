import 'package:intl/intl.dart';

/// Utility class for formatting prices consistently throughout the app
class PriceFormatter {
  /// The singleton instance
  static final PriceFormatter _instance = PriceFormatter._internal();

  /// The number formatter for currency with 4 decimal places
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 4,
  );

  /// The number formatter for currency with 2 decimal places (for display only)
  final NumberFormat _displayFormat = NumberFormat.currency(
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

  /// Format a price value to a currency string with smart decimal handling
  String formatPrice(double price) {
    // If price has significant decimals (more than 2), show 4 decimals
    if (price != double.parse(price.toStringAsFixed(2))) {
      return _currencyFormat.format(price);
    }
    // Otherwise show 2 decimals for cleaner display
    return _displayFormat.format(price);
  }

  /// Format a price value without currency symbol
  String formatPriceWithoutSymbol(double price) {
    return formatPrice(price).replaceAll('₺', '').trim();
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
