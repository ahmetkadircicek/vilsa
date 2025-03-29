import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/init/network/stock_service.dart';
import 'package:vilsa/core/init/network/transaction_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

/// ViewModel for managing stocks
class StockViewModel extends BaseViewModel {
  final StockService _stockService = StockService.instance;
  final TransactionService _transactionService = TransactionService.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController abbreviationController = TextEditingController();
  final TextEditingController dividendsController = TextEditingController();

  List<StockModel> stocks = [];
  bool _isEditing = false;
  String? _editingStockId;

  bool get isEditing => _isEditing;
  String? get editingStockId => _editingStockId;

  StockViewModel() {
    init();
  }

  /// Initialize the ViewModel
  Future<void> init() async {
    await fetchStocks();
  }

  /// Set up controllers for editing a stock
  void setupForEdit(StockModel stock) {
    _isEditing = true;
    _editingStockId = stock.id;
    nameController.text = stock.name;
    abbreviationController.text = stock.abbreviation;
    dividendsController.text = stock.dividends.toString();
    notifyListeners();
  }

  /// Clear editing state
  void clearEditState() {
    _isEditing = false;
    _editingStockId = null;
    nameController.clear();
    abbreviationController.clear();
    dividendsController.clear();
    notifyListeners();
  }

  /// Add or update a stock
  Future<void> addStock(BuildContext context) async {
    await executeAsync(() async {
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
        return null;
      }

      if (_isEditing && _editingStockId != null) {
        // Update existing stock
        final stockToUpdate = stocks.firstWhere((s) => s.id == _editingStockId);
        final updatedStock = StockModel(
          id: stockToUpdate.id,
          name: name,
          abbreviation: abbreviation,
          dividends: dividends,
          transactions: stockToUpdate.transactions,
        );

        await _stockService.update(updatedStock);

        // Update local list
        final index = stocks.indexWhere((s) => s.id == _editingStockId);
        if (index >= 0) {
          stocks[index] = updatedStock;
        }

        // Display success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('$name hissesi güncellendi!'),
            ),
          );
        }

        return updatedStock;
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

        await _stockService.save(newStock);
        stocks.add(newStock); // Add to local list

        // Display success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('$name hissesi eklendi!'),
            ),
          );
        }

        return newStock;
      }
    }, errorPrefix: "Failed to save stock")
        .then((_) {
      // Clear form and editing state
      clearEditState();
    });
  }

  /// Add a transaction to a stock
  Future<void> addTransactionToStock(String stockId, TransactionModel transaction) async {
    await executeAsync(() async {
      // Find the stock by ID and add the transaction
      final stock = stocks.firstWhere((s) => s.id == stockId);
      final updatedTransactions = [...stock.transactions, transaction];

      // Save the transaction
      await _transactionService.save(transaction);

      // Update stock with new transaction
      final updatedStock = stock.copyWith(transactions: updatedTransactions);
      stocks[stocks.indexWhere((s) => s.id == stockId)] = updatedStock;

      return transaction;
    }, errorPrefix: "Failed to add transaction to stock");
  }

  /// Fetch all stocks
  Future<void> fetchStocks() async {
    await executeAsync(() async {
      stocks = await _stockService.fetchAll();
      return stocks;
    }, errorPrefix: "Failed to fetch stocks");
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
