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

  /// Remove a stock from the portfolio
  Future<void> removeStock(String stockId) async {
    await executeAsync(() async {
      await _dataService.deleteStockWithTransactions(stockId);
      _stocks.removeWhere((stock) => stock.id == stockId);
      return true;
    }, errorPrefix: "Failed to remove stock");
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
// Updated on 2025-01-03 - create settings page
// Updated on 2025-01-08 - resolve authentication token expiry
// Updated on 2025-01-13 - create settings page
// Updated on 2025-01-21 - enhance visual hierarchy
// Updated on 2025-01-28 - create settings page
// Updated on 2025-01-29 - refine animation transitions
// Updated on 2025-02-07 - implement filtering options
// Updated on 2025-02-10 - enhance performance of list rendering
// Updated on 2025-02-20 - add navigation structure
// Updated on 2025-02-21 - implement login screen UI
// Updated on 2025-02-27 - optimize image loading
// Updated on 2025-03-03 - update icon designs
// Updated on 2025-03-03 - create settings page
// Updated on 2025-03-04 - add user preferences storage
// Updated on 2025-03-06 - update navigation menu styling
// Updated on 2025-03-11 - enhance performance of list rendering
// Updated on 2025-03-18 - address memory leaks
// Updated on 2025-03-20 - add search functionality
// Updated on 2025-03-22 - correct data loading problems
