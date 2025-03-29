import 'package:intl/intl.dart';
import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/init/network/stock_service.dart';
import 'package:vilsa/core/init/network/transaction_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

/// ViewModel for managing stock details screen
class StockDetailsViewModel extends BaseViewModel {
  final StockService _stockService = StockService.instance;
  final TransactionService _transactionService = TransactionService.instance;

  List<TransactionModel> _transactions = [];
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365)); // Default to 1 year ago
  DateTime _endDate = DateTime.now(); // Default to today
  StockModel? _currentStock;

  // Cache for expensive calculations
  List<TransactionModel>? _cachedFilteredTransactions;
  double? _cachedTotalCostPrice;
  double? _cachedTotalDividends;
  double? _cachedDividendYield;
  List<Map<String, dynamic>>? _cachedChartData;

  // Invalidate cache when data changes
  void _invalidateCache() {
    _cachedFilteredTransactions = null;
    _cachedTotalCostPrice = null;
    _cachedTotalDividends = null;
    _cachedDividendYield = null;
    _cachedChartData = null;
  }

  List<TransactionModel> get transactions => _transactions;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  StockModel? get currentStock => _currentStock;

  /// Get transactions filtered by the selected date range
  List<TransactionModel> get filteredTransactions {
    if (_cachedFilteredTransactions != null) return _cachedFilteredTransactions!;

    _cachedFilteredTransactions = _transactions.where((transaction) {
      return transaction.date.isAfter(_startDate) && transaction.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();

    return _cachedFilteredTransactions!;
  }

  /// Fetch transactions for a specific stock
  Future<void> fetchTransactions(String stockId) async {
    await executeAsync(() async {
      // First fetch the stock to get its details
      _currentStock = await _stockService.fetchById(stockId);

      // Then fetch all transactions
      final allTransactions = await _transactionService.fetchAll();

      // Filter transactions by stock ID
      _transactions = allTransactions.where((transaction) {
        return transaction.stockId == stockId || transaction.stock?.id == stockId;
      }).toList();

      // Sort transactions by date
      _transactions.sort((a, b) => a.date.compareTo(b.date));

      // Invalidate cache when transactions change
      _invalidateCache();

      return _transactions;
    }, errorPrefix: "Failed to fetch transactions");
  }

  /// Update date range
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;

    // Invalidate cache when date range changes
    _invalidateCache();
    notifyListeners();
  }

  /// Calculate total cost price for the filtered range
  double calculateTotalCostPrice() {
    if (_cachedTotalCostPrice != null) return _cachedTotalCostPrice!;

    double total = 0;
    for (var transaction in filteredTransactions) {
      total += transaction.price * transaction.quantity;
    }

    _cachedTotalCostPrice = total;
    return total;
  }

  /// Calculate total dividends for the filtered range
  double calculateTotalDividends() {
    if (_cachedTotalDividends != null) return _cachedTotalDividends!;

    // Get total dividends from filtered transactions
    double transactionDividends = filteredTransactions.fold(0.0, (total, transaction) => total + transaction.dividends);

    // Get dividends from the stock itself and calculate based on the date range
    if (_currentStock != null) {
      // Calculate months between start and end date
      int months = (_endDate.difference(_startDate).inDays / 30).ceil();
      // Assuming dividends are monthly, multiply by months (max 12 months per year)
      double stockDividends = _currentStock!.dividends * (months > 12 ? 12 : months) / 12;

      _cachedTotalDividends = transactionDividends + stockDividends;
      return _cachedTotalDividends!;
    }

    _cachedTotalDividends = transactionDividends;
    return transactionDividends;
  }

  /// Calculate dividend yield for the filtered range
  double calculateDividendYield() {
    if (_cachedDividendYield != null) return _cachedDividendYield!;

    double totalCostPrice = calculateTotalCostPrice();
    double totalDividends = calculateTotalDividends();

    _cachedDividendYield = totalCostPrice > 0 ? (totalDividends / totalCostPrice) * 100 : 0.0;
    return _cachedDividendYield!;
  }

  /// Get data points for chart display
  List<Map<String, dynamic>> getChartData() {
    if (_cachedChartData != null) return _cachedChartData!;

    List<Map<String, dynamic>> chartData = [];
    final sortedTransactions = filteredTransactions.toList()..sort((a, b) => a.date.compareTo(b.date));

    // Generate data points for each transaction
    for (var transaction in sortedTransactions) {
      chartData.add({
        'date': DateFormat('yyyy-MM-dd').format(transaction.date),
        'price': transaction.price,
        'quantity': transaction.quantity,
        'total': transaction.price * transaction.quantity,
        'id': transaction.id,
        'time': DateFormat('HH:mm').format(transaction.date),
      });
    }

    _cachedChartData = chartData;
    return chartData;
  }
}
// Updated on 2025-01-17 - resolve null pointer exceptions
// Updated on 2025-01-20 - resolve authentication token expiry
// Updated on 2025-01-31 - address UI alignment issues
// Updated on 2025-02-13 - implement filtering options
// Updated on 2025-02-14 - setup firebase configuration
// Updated on 2025-02-18 - address UI alignment issues
// Updated on 2025-02-20 - add transaction history page
// Updated on 2025-02-22 - add portfolio analysis module
// Updated on 2025-02-26 - add navigation structure
// Updated on 2025-03-01 - correct date formatting issues
// Updated on 2025-03-02 - add search functionality
// Updated on 2025-03-04 - optimize data fetching logic
// Updated on 2025-03-06 - add search functionality
// Updated on 2025-03-10 - implement notification system
// Updated on 2025-03-11 - add stock detail screen
// Updated on 2025-03-12 - implement error handling
