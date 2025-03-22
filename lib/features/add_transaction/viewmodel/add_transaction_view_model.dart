import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/core/extensions/string_extension.dart';
import 'package:vilsa/core/init/network/firebase_service.dart';
import 'package:vilsa/features/add_stock/model/stock_model.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';

class AddTransactionViewModel extends ChangeNotifier {
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

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> sendData(StockModel stock) async {
    try {
      final transaction = TransactionModel(
        id: const Uuid().v4(), // Use UUID for id
        stock: stock, // Use stockId property
        price: priceController.text.toDouble(), // Ensure price is a double
        quantity: int.parse(quantityController.text), // Ensure quantity is an int
        note: noteController.text,
        date: _selectedDate ?? DateTime.now(), // Use selectedDate for transaction date
        createDate: DateTime.now(),
        dividends: dividendsController.text.toDouble(),
        stockId: '',
      );

      await FirebaseService.instance.saveTransaction(transaction);

      // Clear fields after saving
      nameController.clear();
      priceController.clear();
      quantityController.clear();
      noteController.clear();
      abbreviationController.clear();
      dividendsController.clear(); // Clear dividends field

      // Reset date
      _selectedDate = DateTime.now();
      _stockId = null; // Clear stockId after saving

      notifyListeners();
    } catch (e) {
      print("Error parsing data: $e");
    }
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
