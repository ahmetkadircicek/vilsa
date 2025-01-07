import 'package:intl/intl.dart';

extension DateFormatExtension on DateTime {
  String toUserFriendlyFormat() {
    return DateFormat('d MMMM y', 'tr').format(this); // Örnek: 25 Mart 2025
  }
}
