import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Eğer giriş tamamen silindiyse boş bırak (₺0,00 yerine "")
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Sadece sayıları al, diğer karakterleri kaldır
    String newValueText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // İlk sayı olarak "0" girilmesini önle (ama "0,01" gibi değerler girilebilir)
    if (newValueText.length == 1 && newValueText == '0') {
      return oldValue;
    }

    // Sayıyı parse et, hata olursa eski değeri koru
    int newValueNumber = int.tryParse(newValueText) ?? 0;

    // Maksimum sınır: 99,999,999.99
    if (newValueNumber > 999999999) {
      return oldValue;
    }

    // Yeni değeri formatla
    final formattedValue = currencyFormat.format(newValueNumber / 100);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
