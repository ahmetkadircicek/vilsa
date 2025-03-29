import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/init/network/transaction_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

/// ViewModel for adding transactions
class AddTransactionViewModel extends BaseViewModel {
  final TransactionService _transactionService = TransactionService.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController abbreviationController = TextEditingController();
  final TextEditingController dividendsController = TextEditingController();
  final BoardDateTimeController controller = BoardDateTimeController();
  String? _stockId;

  String? get stockId => _stockId;
  set stockId(String? value) {
    _stockId = value;
    notifyListeners();
  }

  // Single date property
  DateTime? _selectedDate = DateTime.now();

  DateTime? get selectedDate => _selectedDate;

  /// Set the selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Para birimini sayısal değere dönüştüren yardımcı metot
  /// "₺1.234,56" gibi formatlı bir string'i 1234.56 double değerine dönüştürür
  double? parseCurrencyValue(String text, {bool allowZero = false}) {
    if (text.isEmpty) {
      return null;
    }

    try {
      // Para birimi sembolünü ve binlik ayırıcılarını kaldır
      String parsedText = text
          .replaceAll('₺', '') // TL sembolünü kaldır
          .replaceAll('.', '') // Binlik ayraçları kaldır
          .trim() // Boşlukları kaldır
          .replaceAll(',', '.'); // Virgülü nokta ile değiştir (ondalık ayırıcı)

      double value = double.parse(parsedText);

      // Sıfır kontrolü
      if (!allowZero && value <= 0) {
        return null;
      }

      return value;
    } catch (e) {
      debugPrint("Currency parsing error: $e for value '$text'");
      return null;
    }
  }

  /// Save the transaction data
  Future<TransactionModel?> sendData(StockModel stock, {required BuildContext context}) async {
    return await executeAsync<TransactionModel?>(() async {
      // Validation checks
      double? price = parseCurrencyValue(priceController.text);
      if (price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Fiyat alanı geçerli bir değer olmalı ve sıfırdan büyük olmalı"),
              backgroundColor: Colors.red),
        );
        return null;
      }

      // Adet kontrolüp
      int? quantity;
      try {
        quantity = int.tryParse(quantityController.text);
        if (quantity == null || quantity <= 0) {
          throw Exception();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Miktar alanı geçerli bir tam sayı olmalı ve sıfırdan büyük olmalı"),
              backgroundColor: Colors.red),
        );
        return null;
      }

      // Temettü alanını kontrol et (isteğe bağlı)
      double dividends = 0.0;
      if (dividendsController.text.isNotEmpty) {
        double? parsedDividends = parseCurrencyValue(dividendsController.text, allowZero: true);
        if (parsedDividends == null || parsedDividends < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Temettü alanı geçerli bir değer olmalı ve negatif olmamalı"),
                backgroundColor: Colors.red),
          );
          return null;
        }
        dividends = parsedDividends;
      }

      // Create transaction with validated values
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        stockId: stock.id,
        stockName: stock.name,
        stock: stock,
        price: price,
        quantity: quantity,
        note: noteController.text,
        date: _selectedDate ?? DateTime.now(),
        createDate: DateTime.now(),
        dividends: dividends,
      );

      // Log the transaction data before saving
      debugPrint(
          "💹 Saving transaction: ID=${transaction.id}, Stock=${stock.name}, Price=$price, Quantity=$quantity, Dividends=$dividends");

      // Save to database
      await _transactionService.save(transaction);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("İşlem başarıyla kaydedildi"), backgroundColor: Colors.green),
      );

      // Clear fields after saving
      nameController.clear();
      priceController.clear();
      quantityController.clear();
      noteController.clear();
      abbreviationController.clear();
      dividendsController.clear();

      // Reset date
      _selectedDate = DateTime.now();
      _stockId = null;

      return transaction;
    }, errorPrefix: "Failed to save transaction");
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    noteController.dispose();
    abbreviationController.dispose();
    dividendsController.dispose();
    super.dispose();
  }
}
// Updated on 2025-01-10 - correct sorting algorithm
// Updated on 2025-01-12 - simplify authentication flow
// Updated on 2025-01-30 - implement sorting options
// Updated on 2025-02-02 - enhance performance of list rendering
// Updated on 2025-02-03 - simplify API integration
// Updated on 2025-02-05 - address network timeout handling
// Updated on 2025-02-06 - setup firebase configuration
// Updated on 2025-02-13 - add stock detail screen
// Updated on 2025-02-14 - add stock detail screen
// Updated on 2025-02-16 - create stock listing component
// Updated on 2025-02-21 - implement sorting options
// Updated on 2025-02-25 - correct date formatting issues
// Updated on 2025-03-05 - implement filtering options
// Updated on 2025-03-10 - create data caching mechanism
// Updated on 2025-03-17 - add search functionality
