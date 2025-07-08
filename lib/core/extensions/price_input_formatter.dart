import 'package:flutter/services.dart';

/// Clean price input formatter that supports natural decimal input
/// Supports up to 4 decimal places without currency symbols
class PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow empty input
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Only allow numbers, comma and dot (convert dot to comma)
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9,.]'), '');

    // Convert dot to comma for Turkish decimal format
    newText = newText.replaceAll('.', ',');

    // Replace multiple commas with single comma
    List<String> parts = newText.split(',');
    if (parts.length > 2) {
      newText = '${parts[0]},${parts.sublist(1).join('')}';
    }

    // Limit decimal places to 4
    if (parts.length == 2 && parts[1].length > 4) {
      newText = '${parts[0]},${parts[1].substring(0, 4)}';
    }

    // Validate numeric value
    double? numericValue;
    try {
      String parseableText = newText.replaceAll(',', '.');
      numericValue = double.tryParse(parseableText);
    } catch (e) {
      return oldValue;
    }

    if (numericValue == null) {
      return oldValue;
    }

    // Maximum limit: 999,999.9999
    if (numericValue > 999999.9999) {
      return oldValue;
    }

    // Calculate cursor position
    int cursorPosition = newText.length;

    // If user was typing at the end, keep cursor at end
    if (newValue.selection.baseOffset >= newValue.text.length) {
      cursorPosition = newText.length;
    } else {
      // Try to maintain relative cursor position
      cursorPosition = newValue.selection.baseOffset.clamp(0, newText.length);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
