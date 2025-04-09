import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/init/network/data_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/home/model/chart_data_point_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

/// Grafik gösterme modları
enum ChartDisplayMode {
  /// Günlük değerleri gösterir (her işlem ayrı noktadır)
  daily,

  /// Birikimli değerleri gösterir (her işlem önceki değerlerin üzerine eklenir)
  total,
}

/// Grafik türleri
enum ChartType {
  daily,
  total,
}

/// Hisse filtreleme durumları
enum StockFilterType {
  /// Tüm hisseleri gösterir
  all,

  /// Sadece işlem yapılan hisseleri gösterir
  traded,

  /// Sadece işlem yapılmayan hisseleri gösterir
  untraded,
}

/// Hisse sıralama türleri
enum StockSortType {
  /// Alfabetik sıralama
  alphabetical,

  /// Toplam adet sıralama
  quantity,

  /// Toplam değer sıralama
  totalValue,

  /// Ortalama alış fiyatı sıralama
  averagePrice,
}

/// ViewModel to manage home screen data and operations
class HomeViewModel extends BaseViewModel {
  final DataService _dataService = DataService.instance;

  List<StockModel> _stocks = [];
  List<TransactionModel> _allTransactions = [];

  // Default date range: one year ago to today
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365 * 2));
  DateTime _endDate = DateTime.now();

  bool _isImporting = false;

  // Default chart display mode
  ChartDisplayMode _chartDisplayMode = ChartDisplayMode.daily;

  // Default chart type
  ChartType _chartType = ChartType.daily;

  // Default stock filter type
  StockFilterType _stockFilterType = StockFilterType.all;

  // Default stock sort type
  StockSortType _stockSortType = StockSortType.alphabetical;

  List<StockModel> get stocks => _stocks;
  List<TransactionModel> get allTransactions => _allTransactions;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  bool get isImporting => _isImporting;
  ChartDisplayMode get chartDisplayMode => _chartDisplayMode;
  ChartType get chartType => _chartType;
  StockFilterType get stockFilterType => _stockFilterType;
  StockSortType get stockSortType => _stockSortType;

  /// Grafik gösterim modunu değiştir
  void setChartDisplayMode(ChartDisplayMode mode) {
    if (_chartDisplayMode != mode) {
      _chartDisplayMode = mode;
      notifyListeners();
    }
  }

  /// Grafik türünü değiştir
  void setChartType(ChartType type) {
    _chartType = type;
    notifyListeners();
  }

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

  /// Fetch all stocks with their transactions
  Future<void> fetchStocks() async {
    await executeAsync(() async {
      _stocks = await _dataService.fetchStocksWithTransactions();
      return _stocks;
    }, errorPrefix: "Failed to fetch stocks");
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
    // İşlemlerdeki temettüleri topla
    double transactionDividends = filteredTransactions.fold(0.0, (total, transaction) {
      return total + transaction.dividends;
    });

    // Hisse temettülerini topla
    double stockDividends = _stocks.fold(0.0, (total, stock) {
      // Her hisse için toplam adet hesapla
      int totalQuantity = stock.transactions.fold(0, (sum, tx) => sum + tx.quantity);
      // Adet başına temettü ile toplam adet çarpımını ekle
      return total + (stock.dividends * totalQuantity);
    });

    return transactionDividends + stockDividends;
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

    double runningTotal = 0.0; // Birikimli toplam için

    for (var transaction in sortedTransactions) {
      // İşlemin değerini hesapla (fiyat * miktar)
      final transactionValue = transaction.price * transaction.quantity;

      if (_chartType == ChartType.total) {
        // Toplam moda göre, her işlem değeri önceki toplama eklenir
        runningTotal += transactionValue;

        // Veri noktasını ekle
        chartPoints.add(ChartDataPoint(
          date: transaction.date,
          value: runningTotal,
        ));
      } else {
        // Günlük moda göre, her işlem ayrı bir nokta olarak eklenir
        chartPoints.add(ChartDataPoint(
          date: transaction.date,
          value: transactionValue,
        ));
      }
    }

    return chartPoints;
  }

  /// Format date for display
  String formatDisplayDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  /// Hisse filtreleme türünü değiştir
  void setStockFilterType(StockFilterType type) {
    _stockFilterType = type;
    notifyListeners();
  }

  /// Hisse sıralama türünü değiştir
  void setStockSortType(StockSortType type) {
    _stockSortType = type;
    notifyListeners();
  }

  /// Get filtered and sorted stocks
  List<StockModel> get filteredStocks {
    // Önce filtreleme yap
    List<StockModel> filtered = switch (_stockFilterType) {
      StockFilterType.traded => _stocks.where((stock) => stock.transactions.isNotEmpty).toList(),
      StockFilterType.untraded => _stocks.where((stock) => stock.transactions.isEmpty).toList(),
      StockFilterType.all => _stocks,
    };

    // Sonra sıralama yap
    filtered.sort((a, b) {
      switch (_stockSortType) {
        case StockSortType.alphabetical:
          return a.name.compareTo(b.name);
        case StockSortType.quantity:
          int quantityA = a.transactions.fold(0, (sum, tx) => sum + tx.quantity);
          int quantityB = b.transactions.fold(0, (sum, tx) => sum + tx.quantity);
          return quantityB.compareTo(quantityA); // Büyükten küçüğe
        case StockSortType.totalValue:
          int quantityA = a.transactions.fold(0, (sum, tx) => sum + tx.quantity);
          int quantityB = b.transactions.fold(0, (sum, tx) => sum + tx.quantity);
          double valueA = quantityA * a.currentPrice;
          double valueB = quantityB * b.currentPrice;
          return valueB.compareTo(valueA); // Büyükten küçüğe
        case StockSortType.averagePrice:
          double avgPriceA = a.transactions.isEmpty
              ? 0
              : a.transactions.fold(0.0, (sum, tx) => sum + tx.price) / a.transactions.length;
          double avgPriceB = b.transactions.isEmpty
              ? 0
              : b.transactions.fold(0.0, (sum, tx) => sum + tx.price) / b.transactions.length;
          return avgPriceB.compareTo(avgPriceA); // Büyükten küçüğe
      }
    });

    return filtered;
  }

  /// Immediately refresh the stocks list without a full fetch - useful after deletion
  void refreshStocksList() {
    notifyListeners();
  }
}
