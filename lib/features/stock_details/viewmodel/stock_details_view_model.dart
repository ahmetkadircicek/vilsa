import 'dart:async';

import 'package:intl/intl.dart';
import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/init/event/event_bus.dart';
import 'package:vilsa/core/init/event/event_type_enum.dart';
import 'package:vilsa/core/init/network/stock_service.dart';
import 'package:vilsa/core/init/network/transaction_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

/// ViewModel for managing stock details screen
class StockDetailsViewModel extends BaseViewModel {
  final StockService _stockService = StockService.instance;
  final TransactionService _transactionService = TransactionService.instance;
  final EventBus _eventBus = EventBus.instance;

  // Event aboneliklerini takip etmek için
  late StreamSubscription<AppEvent> _transactionAddedSubscription;
  late StreamSubscription<AppEvent> _transactionUpdatedSubscription;
  late StreamSubscription<AppEvent> _transactionDeletedSubscription;

  List<TransactionModel> _transactions = [];
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365 * 2)); // Default to 1 year ago
  DateTime _endDate = DateTime.now(); // Default to today
  StockModel? _currentStock;
  String? _currentStockId;
  bool _hasLoadedTransactions = false; // Transaction yükleme durumu

  // Cache for expensive calculations
  List<TransactionModel>? _cachedFilteredTransactions;
  double? _cachedTotalCostPrice;
  double? _cachedTotalDividends;
  double? _cachedDividendYield;
  double? _cachedAverageCostPerShare;
  List<Map<String, dynamic>>? _cachedChartData;

  StockDetailsViewModel() {
    _initializeEventListeners();
  }

  /// Olay dinleyicilerini başlatma
  void _initializeEventListeners() {
    _transactionAddedSubscription = _eventBus.on(EventType.transactionAdded).listen(_onTransactionEvent);
    _transactionUpdatedSubscription = _eventBus.on(EventType.transactionUpdated).listen(_onTransactionEvent);
    _transactionDeletedSubscription = _eventBus.on(EventType.transactionDeleted).listen(_onTransactionEvent);
  }

  /// İşlem olaylarını işleme
  void _onTransactionEvent(AppEvent event) {
    // Olay tipini ve veriyi logla
    print("İşlem Olayı: ${event.type}, Veri: ${event.data.toString()}");

    // Eğer aktif bir stok yoksa güncelleme yapmaya gerek yok
    if (_currentStockId == null) {
      print("Aktif bir stok bulunmadığı için işlem olayı işlenemiyor.");
      return;
    }

    final TransactionModel transaction = event.data as TransactionModel;
    print("İşlem StockId: ${transaction.stockId}, Mevcut StockId: $_currentStockId");

    // Eğer bu işlem mevcut stoka aitse, verileri yenile
    if (transaction.stockId == _currentStockId) {
      print("İşlem bu stoka ait, veriler yenileniyor");
      // Verileri yenile
      fetchTransactions(_currentStockId!);
    } else {
      print("İşlem farklı bir stoka ait, veriler yenilenmiyor");
    }
  }

  // Invalidate cache when data changes
  void _invalidateCache() {
    _cachedFilteredTransactions = null;
    _cachedTotalCostPrice = null;
    _cachedTotalDividends = null;
    _cachedDividendYield = null;
    _cachedAverageCostPerShare = null;
    _cachedChartData = null;
  }

  List<TransactionModel> get transactions => _transactions;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  StockModel? get currentStock => _currentStock;
  bool get hasLoadedTransactions => _hasLoadedTransactions;

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
    _currentStockId = stockId;

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

      // İşlemlerin yüklendiğini işaretle
      _hasLoadedTransactions = true;

      print("fetchTransactions: ${_transactions.length} işlem yüklendi (StockID: $stockId)");

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
      if (transaction.type == TransactionType.buy) {
        total += transaction.price * transaction.quantity;
      } else if (transaction.type == TransactionType.sell) {
        // Satışları maliyetten düşmüyoruz, çünkü ortalama maliyet hesabında net alım adedine bölünecek
      }
    }

    _cachedTotalCostPrice = total;
    return total;
  }

  /// Calculate average cost per share
  double calculateAverageCostPerShare() {
    if (_cachedAverageCostPerShare != null) return _cachedAverageCostPerShare!;

    double totalCost = 0;
    int totalShares = 0;

    for (var transaction in filteredTransactions) {
      if (transaction.type == TransactionType.buy) {
        totalCost += transaction.price * transaction.quantity;
        totalShares += transaction.quantity;
      } else if (transaction.type == TransactionType.sell) {
        totalShares -= transaction.quantity;
      }
    }

    // Eğer hiç hisse yoksa veya tüm hisseler satılmışsa ortalama maliyet gösterilmez
    if (totalShares <= 0) {
      _cachedAverageCostPerShare = 0;
      return 0;
    }

    _cachedAverageCostPerShare = totalCost / totalShares;
    return _cachedAverageCostPerShare!;
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

  /// Calculate total dividends for the filtered range
  double calculateTotalDividends() {
    if (_cachedTotalDividends != null) return _cachedTotalDividends!;

    // Get total dividends from filtered transactions
    double transactionDividends = filteredTransactions.fold(0.0, (total, transaction) => total + transaction.dividends);

    // Get dividends from the stock itself and calculate based on the date range
    if (_currentStock != null) {
      // Toplam hisse adedi
      int totalQuantity = getTotalSharesCount();

      // Adet başına temettü ile toplam adet çarpımı
      double stockDividends = _currentStock!.dividends * totalQuantity;

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

  /// Delete a transaction by ID
  Future<void> deleteTransaction(String transactionId) async {
    await executeAsync(() async {
      // Önce silinen işlemi al (olay yayınlamak için)
      final transaction = _transactions.firstWhere((tx) => tx.id == transactionId);

      // İşlemi veritabanından sil
      await _transactionService.delete(transactionId);

      // Yerel listeden de kaldır
      _transactions.removeWhere((tx) => tx.id == transactionId);

      // Önbelleği temizle
      _invalidateCache();

      // İşlem silindi olayını yayınla
      _eventBus.fireEvent(EventType.transactionDeleted, data: transaction);

      return true;
    }, errorPrefix: "Failed to delete transaction");
  }

  @override
  void dispose() {
    // Abonelikleri iptal et
    _transactionAddedSubscription.cancel();
    _transactionUpdatedSubscription.cancel();
    _transactionDeletedSubscription.cancel();

    super.dispose();
  }
}
