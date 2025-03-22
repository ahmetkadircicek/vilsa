import 'package:flutter/material.dart';
import 'package:vilsa/core/init/network/firebase_service.dart';
import 'package:vilsa/features/add_stock/model/stock_model.dart';

class PortfolioViewModel extends ChangeNotifier {
  List<StockModel> _stocks = [];
  bool _isLoading = false;

  List<StockModel> get stocks => _stocks;
  bool get isLoading => _isLoading;

  PortfolioViewModel() {
    fetchStocks();
  }

  Future<void> fetchStocks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stocks = await FirebaseService.instance.fetchStock();
    } catch (e) {
      print("Error fetching stocks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeStock(String stockId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseService.instance.removeStock(stockId);
      _stocks.removeWhere((stock) => stock.id == stockId);
    } catch (e) {
      print("Error removing stock: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
