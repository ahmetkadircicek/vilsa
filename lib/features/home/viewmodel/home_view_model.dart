import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/init/network/data_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/home/model/chart_data_point_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

/// ViewModel to manage home screen data and operations
class HomeViewModel extends BaseViewModel {
  final DataService _dataService = DataService.instance;

  List<StockModel> _stocks = [];
  List<TransactionModel> _allTransactions = [];

  // Default date range: one year ago to today
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime _endDate = DateTime.now();

  bool _isImporting = false;

  List<StockModel> get stocks => _stocks;
  List<TransactionModel> get allTransactions => _allTransactions;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  bool get isImporting => _isImporting;

  /// Load portfolio data including stocks and transactions
  Future<void> loadPortfolioData() async {
    await fetchStocksWithTransactions();
  }

  HomeViewModel() {
    init();
  }

  /// Initialize the ViewModel by fetching data
  Future<void> init() async {
    await fetchStocksWithTransactions();
  }

  /// Fetch all stocks with their transactions
  Future<void> fetchStocksWithTransactions() async {
    await executeAsync(() async {
      _stocks = await _dataService.fetchStocksWithTransactions();

      // Collect all transactions from all stocks
      _allTransactions = [];
      for (var stock in _stocks) {
        _allTransactions.addAll(stock.transactions);
      }

      return _stocks;
    }, errorPrefix: "Failed to fetch stocks with transactions");
  }

  /// Get transactions filtered by the selected date range
  List<TransactionModel> get filteredTransactions {
    return _allTransactions.where((transaction) {
      return transaction.date.isAfter(_startDate) && transaction.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Calculate the total balance from filtered transactions
  double get totalBalance {
    return filteredTransactions.fold(0.0, (total, transaction) {
      return total + (transaction.price * transaction.quantity);
    });
  }

  /// Calculate the total dividends from filtered transactions
  double get totalDividends {
    return filteredTransactions.fold(0.0, (total, transaction) {
      return total + transaction.dividends;
    });
  }

  /// Get the total investment amount (sum of buy transactions)
  double get totalInvestment {
    return _allTransactions.fold(0.0, (total, transaction) {
      if (transaction.quantity > 0) {
        return total + (transaction.price * transaction.quantity);
      }
      return total;
    });
  }

  /// Get the estimated current value of the portfolio
  double get currentValue {
    double value = 0.0;
    for (var stock in _stocks) {
      // Calculate total quantity owned
      int totalQuantity = stock.transactions.fold(0, (sum, tx) => sum + tx.quantity);
      value += totalQuantity * stock.currentPrice;
    }
    return value;
  }

  /// Calculate total profit/loss (current value - total investment)
  double get totalProfitLoss {
    return currentValue - totalInvestment;
  }

  /// Calculate profit/loss percentage
  double get totalProfitLossPercentage {
    if (totalInvestment == 0) return 0.0;
    return (totalProfitLoss / totalInvestment) * 100;
  }

  /// Calculate total annual dividends
  double get totalAnnualDividends {
    return _stocks.fold(0.0, (total, stock) {
      // Calculate total quantity owned
      int totalQuantity = stock.transactions.fold(0, (sum, tx) => sum + tx.quantity);
      // Annual dividend per share * quantity
      return total + (stock.dividends * totalQuantity);
    });
  }

  /// Calculate dividend yield percentage
  double get dividendYield {
    if (totalInvestment == 0) return 0.0;
    return (totalAnnualDividends / totalInvestment) * 100;
  }

  /// Get top stocks by current value
  List<StockModel> get topStocks {
    // Create a sorted copy of stocks
    List<StockModel> sortedStocks = List.from(_stocks);

    // Sort by current value (price * total quantity)
    sortedStocks.sort((a, b) {
      int quantityA = a.transactions.fold(0, (sum, tx) => sum + tx.quantity);
      int quantityB = b.transactions.fold(0, (sum, tx) => sum + tx.quantity);

      double valueA = quantityA * a.currentPrice;
      double valueB = quantityB * b.currentPrice;

      return valueB.compareTo(valueA); // Descending order
    });

    return sortedStocks;
  }

  /// Get recent transactions sorted by date
  List<TransactionModel> get recentTransactions {
    List<TransactionModel> sorted = List.from(_allTransactions);
    sorted.sort((a, b) => b.date.compareTo(a.date)); // Descending order (newest first)
    return sorted;
  }

  /// Navigate to transactions screen
  void navigateToTransactions(BuildContext context) {
    Navigator.pushNamed(context, '/transactions');
  }

  /// Navigate to portfolio screen
  void navigateToPortfolio(BuildContext context) {
    Navigator.pushNamed(context, '/portfolio');
  }

  /// Navigate to stock details screen
  void navigateToStockDetails(BuildContext context, StockModel stock) {
    Navigator.pushNamed(context, '/stock-details', arguments: stock);
  }

  /// Set the date range for data filtering
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  /// Generate chart data points based on the filtered transactions
  List<ChartDataPoint> getChartData() {
    if (filteredTransactions.isEmpty) return [];

    // Filtrelenmiş işlemleri tarih sırasına göre sıralayalım
    final sortedTransactions = List<TransactionModel>.from(filteredTransactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Her bir işlem için ayrı veri noktası oluşturalım
    final chartPoints = <ChartDataPoint>[];

    for (var transaction in sortedTransactions) {
      // İşlemin değerini hesapla (fiyat * miktar)
      final transactionValue = transaction.price * transaction.quantity;

      // Veri noktasını ekle
      chartPoints.add(ChartDataPoint(
        date: DateTime(transaction.date.year, transaction.date.month, transaction.date.day),
        value: transactionValue,
      ));
    }

    // Eğer aynı gün için birden fazla işlem varsa ve bunları birleştirmek isteniyorsa
    // Bu kısmı aktif edebilirsiniz. Şu an her işlem ayrı bir nokta olarak gösteriliyor.

    // Aynı gün için veri noktalarını birleştir
    final Map<String, ChartDataPoint> uniquePoints = {};

    for (var point in chartPoints) {
      final dateKey = DateFormat('yyyy-MM-dd').format(point.date);

      if (uniquePoints.containsKey(dateKey)) {
        // Aynı gün için mevcut değere ekle
        uniquePoints[dateKey] = ChartDataPoint(
          date: point.date,
          value: uniquePoints[dateKey]!.value + point.value,
        );
      } else {
        // Yeni bir gün için veri noktası ekle
        uniquePoints[dateKey] = point;
      }
    }

    // Map'i listeye dönüştür
    final result = uniquePoints.values.toList()..sort((a, b) => a.date.compareTo(b.date));

    return result;
  }

  /// Format date for display
  String formatDisplayDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  /// Import sample data from a JSON asset file
  Future<void> importSampleData(BuildContext context, String assetPath) async {
    if (_isImporting) return;

    _isImporting = true;
    notifyListeners();

    await executeAsync(() async {
      await _dataService.importSampleData(assetPath);
      await fetchStocksWithTransactions();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Sample data imported successfully!'),
          ),
        );
      }

      return null;
    }, errorPrefix: "Failed to import sample data");

    _isImporting = false;
    notifyListeners();
  }
}
