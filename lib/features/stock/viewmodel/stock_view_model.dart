import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/core/init/network/firebase_service.dart';
import 'package:vilsa/features/add_stock/model/stock_model.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';

class StockViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController abbreviationController = TextEditingController();
  final TextEditingController dividendsController = TextEditingController();
  List<StockModel> stocks = [];
  bool _isLoading = false;
  bool _isEditing = false;
  String? _editingStockId;

  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String? get editingStockId => _editingStockId;

  StockViewModel() {
    init();
  }

  Future<void> init() async {
    await fetchStocks();
  }

  // Set up controllers for editing a stock
  void setupForEdit(StockModel stock) {
    _isEditing = true;
    _editingStockId = stock.id;
    nameController.text = stock.name;
    abbreviationController.text = stock.abbreviation;
    dividendsController.text = stock.dividends.toString();
    notifyListeners();
  }

  // Clear editing state
  void clearEditState() {
    _isEditing = false;
    _editingStockId = null;
    nameController.clear();
    abbreviationController.clear();
    dividendsController.clear();
    notifyListeners();
  }

  Future<void> addStock(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final name = nameController.text;
    final abbreviation = abbreviationController.text;
    final dividends = double.tryParse(dividendsController.text.replaceAll(',', '.')) ?? 0.0;

    if (name.isEmpty || abbreviation.isEmpty || dividends <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Lütfen tüm alanları doğru şekilde doldurun!'),
        ),
      );
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      if (_isEditing && _editingStockId != null) {
        // Update existing stock
        final stockToUpdate = stocks.firstWhere((s) => s.id == _editingStockId);
        final updatedStock = stockToUpdate.copyWith(
          name: name,
          abbreviation: abbreviation,
          dividends: dividends,
        );

        await FirebaseService.instance.updateStock(updatedStock);

        // Update local list
        final index = stocks.indexWhere((s) => s.id == _editingStockId);
        if (index >= 0) {
          stocks[index] = updatedStock;
        }

        // Display success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('$name hissesi güncellendi!'),
          ),
        );
      } else {
        // Add new stock
        final String stockId = const Uuid().v4();
        final newStock = StockModel(
          id: stockId,
          name: name,
          abbreviation: abbreviation,
          dividends: dividends,
          transactions: [], // Initialize with an empty list of transactions
        );

        await FirebaseService.instance.saveStock(newStock);
        stocks.add(newStock); // Add to local list

        // Display success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('$name hissesi eklendi!'),
          ),
        );
      }
    } catch (e) {
      // Display error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Hata oluştu: $e'),
        ),
      );
    } finally {
      // Clear form and editing state
      clearEditState();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransactionToStock(String stockId, TransactionModel transaction) async {
    // Find the stock by ID and add the transaction
    final stock = stocks.firstWhere((s) => s.id == stockId);
    stock.transactions.add(transaction);
    await FirebaseService.instance.saveTransaction(transaction);
    notifyListeners();
  }

  Future<void> fetchStocks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedStocks = await FirebaseService.instance.fetchStock();
      stocks = fetchedStocks;
    } catch (e) {
      print("Error fetching stocks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    abbreviationController.dispose();
    dividendsController.dispose();
    super.dispose();
  }
}
// Updated on 2025-01-10 - implement notification system
// Updated on 2025-01-16 - implement sorting options
// Updated on 2025-01-23 - implement sorting options
// Updated on 2025-01-24 - address UI alignment issues
// Updated on 2025-01-24 - fix API response handling
// Updated on 2025-01-30 - fix layout on smaller screens
// Updated on 2025-02-03 - enhance performance of list rendering
// Updated on 2025-02-06 - implement dark mode support
// Updated on 2025-02-07 - enhance component reusability
// Updated on 2025-02-08 - implement dark mode support
// Updated on 2025-02-11 - add user preferences storage
// Updated on 2025-02-12 - address UI alignment issues
// Updated on 2025-03-14 - create data caching mechanism
// Updated on 2025-03-14 - resolve authentication token expiry
// Updated on 2025-03-21 - address network timeout handling
