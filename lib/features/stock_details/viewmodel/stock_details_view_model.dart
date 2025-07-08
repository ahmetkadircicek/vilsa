import 'dart:async';

import 'package:intl/intl.dart';
import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/init/network/dividend_service.dart';
import 'package:vilsa/core/init/network/stock_service.dart';
import 'package:vilsa/core/init/network/transaction_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/stock/model/dividend_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

/// ViewModel for managing stock details screen
class StockDetailsViewModel extends BaseViewModel {
  final StockService _stockService = StockService.instance;
  final TransactionService _transactionService = TransactionService.instance;
  final DividendService _dividendService = DividendService.instance;

  List<TransactionModel> _transactions = [];
  List<DividendModel> _dividends = [];
  DateTime _startDate = DateTime.now()
      .subtract(const Duration(days: 365 * 2)); // Default to 2 years ago
  DateTime _endDate = DateTime.now(); // Default to today
  StockModel? _currentStock;
  String? _currentStockId;
  bool _hasLoadedTransactions = false; // Transaction yükleme durumu
  bool _hasLoadedDividends = false; // Dividend yükleme durumu

  StockDetailsViewModel();

  List<TransactionModel> get transactions => _transactions;
  List<DividendModel> get dividends => _dividends;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  StockModel? get currentStock => _currentStock;
  String? get currentStockId => _currentStockId;
  bool get hasLoadedTransactions => _hasLoadedTransactions;
  bool get hasLoadedDividends => _hasLoadedDividends;

  /// Get transactions filtered by the selected date range
  List<TransactionModel> get filteredTransactions {
    return _transactions.where((transaction) {
      return transaction.date.isAfter(_startDate) &&
          transaction.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get dividends filtered by the selected date range
  List<DividendModel> get filteredDividends {
    return _dividends.where((dividend) {
      return dividend.date.isAfter(_startDate) &&
          dividend.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Fetch transactions and dividends for a specific stock
  Future<void> fetchTransactions(String stockId) async {
    _currentStockId = stockId;

    await executeAsync(() async {
      // First fetch the stock to get its details
      _currentStock = await _stockService.fetchById(stockId);

      // Then fetch all transactions
      final allTransactions = await _transactionService.fetchAll();

      // Filter transactions by stock ID
      _transactions = allTransactions.where((transaction) {
        return transaction.stockId == stockId ||
            transaction.stock?.id == stockId;
      }).toList();

      // Sort transactions by date
      _transactions.sort((a, b) => a.date.compareTo(b.date));

      // Fetch dividends for this stock
      _dividends = await _dividendService.fetchByStockId(stockId);

      // İşlemlerin ve temettülerin yüklendiğini işaretle
      _hasLoadedTransactions = true;
      _hasLoadedDividends = true;

      print(
          "fetchTransactions: ${_transactions.length} işlem ve ${_dividends.length} temettü yüklendi (StockID: $stockId)");

      return _transactions;
    }, errorPrefix: "Failed to fetch transactions and dividends");
  }

  /// Update date range
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;

    notifyListeners();
  }

  /// Calculate total cost price for the filtered range (remaining cost basis)
  double calculateTotalCostPrice() {
    double totalCost = 0;
    int totalShares = 0;

    for (var transaction in filteredTransactions) {
      if (transaction.type == TransactionType.buy) {
        totalCost += transaction.price * transaction.quantity;
        totalShares += transaction.quantity;
      } else if (transaction.type == TransactionType.sell) {
        // When selling, reduce the cost proportionally
        if (totalShares > 0) {
          double avgCostSoFar = totalCost / totalShares;
          double soldCost = avgCostSoFar * transaction.quantity;
          totalCost -= soldCost;
        }
        totalShares -= transaction.quantity;
      }
    }

    // Return the remaining cost basis
    return totalCost > 0 ? totalCost : 0;
  }

  /// Calculate average cost per share
  double calculateAverageCostPerShare() {
    double totalCost = 0;
    int totalShares = 0;

    for (var transaction in filteredTransactions) {
      if (transaction.type == TransactionType.buy) {
        totalCost += transaction.price * transaction.quantity;
        totalShares += transaction.quantity;
      } else if (transaction.type == TransactionType.sell) {
        // When selling, reduce the shares but proportionally reduce the cost basis
        if (totalShares > 0) {
          double avgCostSoFar = totalCost / totalShares;
          double soldCost = avgCostSoFar * transaction.quantity;
          totalCost -= soldCost;
        }
        totalShares -= transaction.quantity;
      }
    }

    // Eğer hiç hisse yoksa veya tüm hisseler satılmışsa ortalama maliyet gösterilmez
    if (totalShares <= 0) {
      return 0;
    }

    return totalCost / totalShares;
  }

  /// Get total shares count
  int getTotalSharesCount() {
    int totalShares = 0;

    for (var transaction in filteredTransactions) {
      if (transaction.type == TransactionType.buy) {
        totalShares += transaction.quantity;
      } else if (transaction.type == TransactionType.sell) {
        totalShares -= transaction.quantity;
      }
    }

    return totalShares < 0 ? 0 : totalShares;
  }

  /// Calculate total dividends for the filtered range (NEW SYSTEM)
  double calculateTotalDividends() {
    // Use new dividend system only
    double totalDividends = filteredDividends.fold(0.0, (total, dividend) {
      return total + dividend.totalAmount;
    });

    return totalDividends;
  }

  /// Calculate dividend yield for the filtered range
  double calculateDividendYield() {
    double totalCostPrice = calculateTotalCostPrice();
    double totalDividends = calculateTotalDividends();

    return totalCostPrice > 0 ? (totalDividends / totalCostPrice) * 100 : 0.0;
  }

  /// Get data points for chart display
  List<Map<String, dynamic>> getChartData() {
    List<Map<String, dynamic>> chartData = [];
    final sortedTransactions = filteredTransactions.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

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

    return chartData;
  }

  /// Delete a transaction by ID
  Future<void> deleteTransaction(String transactionId) async {
    await executeAsync(() async {
      // İşlemi veritabanından sil
      await _transactionService.delete(transactionId);

      // Yerel listeden de kaldır
      _transactions.removeWhere((tx) => tx.id == transactionId);

      return true;
    }, errorPrefix: "Failed to delete transaction");
  }

  /// Calculate current market value based on current price
  double calculateCurrentMarketValue() {
    if (_currentStock?.currentPrice == null ||
        _currentStock!.currentPrice <= 0) {
      return 0.0;
    }

    int totalShares = getTotalSharesCount();
    return _currentStock!.currentPrice * totalShares;
  }

  /// Calculate profit/loss amount
  double calculateProfitLoss() {
    double currentValue = calculateCurrentMarketValue();
    double totalCost = calculateTotalCostPrice();

    if (currentValue <= 0 || totalCost <= 0) {
      return 0.0;
    }

    return currentValue - totalCost;
  }

  /// Calculate profit/loss percentage
  double calculateProfitLossPercentage() {
    double profitLoss = calculateProfitLoss();
    double totalCost = calculateTotalCostPrice();

    if (totalCost <= 0) {
      return 0.0;
    }

    return (profitLoss / totalCost) * 100;
  }

  /// Check if current stock has a valid current price
  bool get hasCurrentPrice {
    return _currentStock?.currentPrice != null &&
        _currentStock!.currentPrice > 0;
  }

  /// Delete a dividend by ID
  Future<void> deleteDividend(String dividendId) async {
    await executeAsync(() async {
      // Delete from service
      await _dividendService.delete(dividendId);

      // Remove from local list
      _dividends.removeWhere((d) => d.id == dividendId);

      return true;
    }, errorPrefix: "Failed to delete dividend");
  }
}
