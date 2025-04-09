import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/init/navigation/navigation_service.dart';
import 'package:vilsa/core/init/network/stock_service.dart';
import 'package:vilsa/core/init/network/transaction_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';
import 'package:provider/provider.dart';

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
  Future<Map<String, dynamic>> addStock(BuildContext context) async {
    bool success = false;
    String operation = "ekleme"; // Varsayılan değer
    print("DEBUG: addStock metodu başladı");

    await executeAsync(() async {
      final name = nameController.text;
      final abbreviation = abbreviationController.text;

      // Parse temettü değerini detaylı olarak ele alalım
      String normalizedText = dividendsController.text
          .trim()
          .replaceAll('₺', '') // TL sembolünü kaldır
          .replaceAll('.', '') // Binlik ayraçları kaldır
          .replaceAll(',', '.'); // Virgülü nokta ile değiştir (ondalık ayırıcı)

      print("DEBUG: Normalize edilmiş temettü metni: '$normalizedText'");

      double dividends = 0.0;
      if (normalizedText.isNotEmpty) {
        try {
          dividends = double.parse(normalizedText);
          print("DEBUG: Parse edilen temettü değeri: $dividends");
        } catch (e) {
          print("DEBUG: Temettü parse hatası: $e");
          print("DEBUG: Form validasyonu başarısız: Temettü değeri geçerli bir sayı değil");
          return null;
        }
      }

      print("DEBUG: Form değerleri: name=$name, abbreviation=$abbreviation, dividends=$dividends");

      if (name.isEmpty || abbreviation.isEmpty) {
        print("DEBUG: Form validasyonu başarısız: Ad veya kısaltma boş");
        // Field validation is now handled in the UI before this method is called
        return null;
      }

      // Temettü değeri negatif olamaz, ama sıfır olabilir
      if (dividends < 0) {
        print("DEBUG: Form validasyonu başarısız: Temettü değeri negatif ($dividends)");
        return null;
      }

      if (_isEditing && _editingStockId != null) {
        operation = "güncelleme";
        print("DEBUG: Hisse güncelleniyor - ID: $_editingStockId");
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
        print("DEBUG: Hisse service ile güncellendi");

        // Update local list
        final index = stocks.indexWhere((s) => s.id == _editingStockId);
        if (index >= 0) {
          stocks[index] = updatedStock;
          print("DEBUG: Local liste güncellendi - index: $index");
        }

        success = true;
        print("DEBUG: Güncelleme başarılı, success=true");
        return updatedStock;
      } else {
        operation = "ekleme";
        print("DEBUG: Yeni hisse ekleniyor");
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
        print("DEBUG: Yeni hisse service ile kaydedildi - ID: ${newStock.id}");

        stocks.add(newStock); // Add to local list
        print("DEBUG: Yeni hisse local listeye eklendi");

        success = true;
        print("DEBUG: Ekleme başarılı, success=true");
        return newStock;
      }
    }, errorPrefix: "Failed to save stock")
        .then((_) {
      // Clear form and editing state
      print("DEBUG: Form temizleniyor");
      clearEditState();
    }).catchError((error) {
      print("DEBUG ERROR: Hisse kaydetme hatası: $error");
      success = false;
    });

    print("DEBUG: addStock metodu tamamlandı, dönüş değeri: $success");
    // Fonksiyon başarıyla tamamlandı mı ve hangi işlem yapıldı?
    return {'success': success, 'operation': operation};
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

      // Refresh state across the app
      try {
        final context = NavigationService.instance.navigatorKey.currentContext;
        if (context != null) {
          // Refresh HomeViewModel
          try {
            Provider.of<HomeViewModel>(context, listen: false).fetchStocks();
          } catch (e) {
            // If HomeViewModel is not available, continue silently
          }

          // Refresh PortfolioViewModel if available
          try {
            final portfolioViewModel = Provider.of<dynamic>(context, listen: false);
            if (portfolioViewModel != null && portfolioViewModel.toString().contains('PortfolioViewModel')) {
              portfolioViewModel.refreshStocks();
            }
          } catch (e) {
            // If PortfolioViewModel is not available, continue silently
          }
        }
      } catch (e) {
        // Continue if any providers are not available
      }

      return stocks;
    }, errorPrefix: "Failed to fetch stocks");
  }

  double? parseCurrencyValue(String text, {bool allowZero = false}) {
    if (text.isEmpty) {
      return null;
    }

    try {
      // Para birimi sembolünü ve binlik ayırıcılarını kaldır
      String parsedText = text
          .replaceAll('₺', '') // TL sembolünü kaldır
          .replaceAll('.', '') // Binlik ayraçları kaldır
          .trim() // Boşlukları kaldır
          .replaceAll(',', '.'); // Virgülü nokta ile değiştir (ondalık ayırıcı)

      double value = double.parse(parsedText);

      // Sıfır kontrolü
      if (!allowZero && value <= 0) {
        return null;
      }

      return value;
    } catch (e) {
      debugPrint("Currency parsing error: $e for value '$text'");
      return null;
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
