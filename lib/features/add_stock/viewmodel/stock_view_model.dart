import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/core/init/network/firebase_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/add_stock/model/stock_model.dart';

class StockViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController abbreviationController = TextEditingController();
  final TextEditingController dividendsController = TextEditingController();
  List<StockModel> stocks = [];

  StockViewModel() {
    init();
  }

  Future<void> init() async {
    await fetchStocks();
  }

  Future<void> addStock(BuildContext context) async {
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
      return;
    }

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
    notifyListeners();

    nameController.clear();
    abbreviationController.clear();
    dividendsController.clear();
  }

  Future<void> addTransactionToStock(String stockId, TransactionModel transaction) async {
    // Find the stock by ID and add the transaction
    final stock = stocks.firstWhere((s) => s.id == stockId);
    stock.transactions.add(transaction);
    await FirebaseService.instance.saveStock(stock); // Save updated stock with transactions
    notifyListeners();
  }

  Future<void> fetchStocks() async {
    try {
      final fetchedStocks = await FirebaseService.instance.fetchStock();
      stocks = fetchedStocks;
      notifyListeners();
    } catch (e) {
      print("Error fetching stocks: $e");
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
// Updated on 2025-01-02 - add transaction history page
// Updated on 2025-01-06 - implement login screen UI
// Updated on 2025-01-10 - create data caching mechanism
// Updated on 2025-01-11 - improve form element consistency
// Updated on 2025-01-20 - implement filtering options
// Updated on 2025-01-26 - simplify API integration
// Updated on 2025-01-31 - implement filtering options
// Updated on 2025-02-01 - improve button styling
// Updated on 2025-02-09 - add portfolio summary view
// Updated on 2025-02-12 - address memory leaks
// Updated on 2025-02-15 - implement dark mode support
// Updated on 2025-02-19 - implement error handling
// Updated on 2025-02-21 - simplify authentication flow
// Updated on 2025-02-24 - implement user profile screen
// Updated on 2025-02-24 - add search functionality
// Updated on 2025-02-27 - implement sorting options
// Updated on 2025-03-06 - optimize data fetching logic
// Updated on 2025-03-13 - correct data loading problems
// Updated on 2025-03-15 - improve loading indicator
// Updated on 2025-03-19 - enhance component reusability
// Updated on 2025-03-20 - add transaction history page
