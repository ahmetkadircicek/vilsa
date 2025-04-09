import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/init/network/data_service.dart';
import 'package:vilsa/core/init/network/stock_service.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

/// ViewModel for managing the portfolio screen
class PortfolioViewModel extends BaseViewModel {
  final DataService _dataService = DataService.instance;
  final StockService _stockService = StockService.instance;
  List<StockModel> _stocks = [];

  List<StockModel> get stocks => _stocks;

  PortfolioViewModel() {
    fetchStocks();
  }

  /// Fetch all stocks in the portfolio
  Future<void> fetchStocks() async {
    await executeAsync(() async {
      _stocks = await _stockService.fetchAll();
      return _stocks;
    }, errorPrefix: "Failed to fetch stocks");
  }

  /// Remove a stock from the portfolio and update state
  Future<void> removeStock(String stockId) async {
    await executeAsync(() async {
      await _dataService.deleteStockWithTransactions(stockId);
      _stocks.removeWhere((stock) => stock.id == stockId);

      // Notify listeners to refresh UI
      notifyListeners();

      return true;
    }, errorPrefix: "Failed to remove stock");
  }

  /// Refresh stocks data after operations in other ViewModels
  Future<void> refreshStocks() async {
    await fetchStocks();
    // Force notify
    notifyListeners();
  }

  /// Get total portfolio value
  double get totalPortfolioValue {
    return _stocks.fold(0.0, (total, stock) {
      int quantity = stock.transactions.fold(0, (sum, tx) => sum + tx.quantity);
      return total + (quantity * stock.currentPrice);
    });
  }

  /// Sort stocks by value (descending)
  List<StockModel> getStocksSortedByValue() {
    List<StockModel> sorted = List.from(_stocks);
    sorted.sort((a, b) {
      int quantityA = a.transactions.fold(0, (sum, tx) => sum + tx.quantity);
      int quantityB = b.transactions.fold(0, (sum, tx) => sum + tx.quantity);

      double valueA = quantityA * a.currentPrice;
      double valueB = quantityB * b.currentPrice;

      return valueB.compareTo(valueA); // Descending order
    });
    return sorted;
  }
}
