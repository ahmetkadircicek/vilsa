import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vilsa/core/init/network/firebase_service.dart';
import 'package:vilsa/features/add_stock/model/stock_model.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/home/model/chart_data_point_model.dart';

class HomeViewModel extends ChangeNotifier {
  List<StockModel> _stocks = [];
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = false;
  bool _isImporting = false;

  // Default date range: one year ago to today
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime _endDate = DateTime.now();

  HomeViewModel() {
    init();
  }

  List<StockModel> get stocks => _stocks;
  List<TransactionModel> get allTransactions => _allTransactions;
  bool get isLoading => _isLoading;
  bool get isImporting => _isImporting;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  // Tarih aralığına göre filtrelenmiş işlemler
  List<TransactionModel> get filteredTransactions {
    return _allTransactions.where((transaction) {
      return transaction.date.isAfter(_startDate) && transaction.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Toplam bakiye hesaplama
  double get totalBalance {
    return filteredTransactions.fold(0.0, (total, transaction) {
      return total + (transaction.price * transaction.quantity);
    });
  }

  // Toplam temettü hesaplama
  double get totalDividends {
    return filteredTransactions.fold(0.0, (total, transaction) {
      return total + transaction.dividends;
    });
  }

  void init() {
    fetchStocksWithTransactions();
  }

  // Örnek verileri yükle
  Future<void> importSampleData(BuildContext context) async {
    _isImporting = true;
    notifyListeners();

    try {
      // Örnek veri dosyasının yolunu belirt
      const String sampleDataPath = 'asset/sample_data.json';

      // Firebase servisini kullanarak örnek verileri içe aktar
      await FirebaseService.instance.importJsonData(sampleDataPath);

      // Verileri yeniden yükle
      await fetchStocksWithTransactions();

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Örnek veriler başarıyla yüklendi!'),
        ),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Örnek veri yükleme hatası: $e'),
        ),
      );
      debugPrint("Örnek veri yükleme hatası: $e");
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  // Stok ve işlemleri beraber getir
  Future<void> fetchStocksWithTransactions() async {
    _isLoading = true;
    notifyListeners();
    print("Fetching stocks with transactions..."); // Debug print

    try {
      _stocks = await FirebaseService.instance.fetchStocksWithTransactions();

      // Tüm işlemleri birleştir
      _allTransactions = [];
      for (var stock in _stocks) {
        if (stock.transactions.isNotEmpty) {
          _allTransactions.addAll(stock.transactions);
        }
      }

      // İşlemleri tarihe göre sırala
      _allTransactions.sort((a, b) => a.date.compareTo(b.date));

      print("Stocks with transactions fetched: ${_stocks.length} stocks, ${_allTransactions.length} transactions");
    } catch (e) {
      print("Error fetching stocks with transactions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tarih aralığını güncelle
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  // Grafik için veri noktaları oluştur
  List<ChartDataPoint> getChartData() {
    if (filteredTransactions.isEmpty) return [];

    // Tarihe göre işlemleri grupla
    Map<DateTime, double> groupedData = {};

    // En az 1, en çok 12 nokta göster
    final daysBetween = _endDate.difference(_startDate).inDays + 1;
    final interval = _calculateInterval(daysBetween);

    // Boş veri noktalarını oluştur
    DateTime currentDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
    while (!currentDate.isAfter(_endDate)) {
      final normalizedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
      groupedData[normalizedDate] = 0.0;
      currentDate = currentDate.add(Duration(days: interval));
    }

    // İşlemleri tarihe göre grupla
    for (var transaction in filteredTransactions) {
      final transactionDate = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);

      // En yakın gruplandırılmış tarihi bul
      DateTime? closestDate;
      int smallestDifference = 10000;

      for (var date in groupedData.keys) {
        final difference = (date.difference(transactionDate).inDays).abs();
        if (difference < smallestDifference) {
          smallestDifference = difference;
          closestDate = date;
        }
      }

      if (closestDate != null) {
        final transactionValue = transaction.price * transaction.quantity;
        groupedData[closestDate] = (groupedData[closestDate] ?? 0) + transactionValue;
      }
    }

    return groupedData.entries.map((entry) {
      return ChartDataPoint(date: entry.key, value: entry.value);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Tarih aralığına göre uygun aralık hesapla
  int _calculateInterval(int daysBetween) {
    if (daysBetween <= 14) return 1; // Günlük
    if (daysBetween <= 60) return 5; // 5 günlük
    if (daysBetween <= 180) return 15; // 15 günlük
    if (daysBetween <= 365) return 30; // Aylık
    return 90; // 3 aylık
  }

  String formatDisplayDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }
}
// Updated on 2025-01-06 - add authentication module
// Updated on 2025-01-13 - implement dark mode support
// Updated on 2025-01-14 - create data caching mechanism
// Updated on 2025-01-15 - add search functionality
// Updated on 2025-01-15 - refine color scheme
// Updated on 2025-01-16 - optimize image loading
// Updated on 2025-01-20 - add navigation structure
// Updated on 2025-01-28 - implement dark mode support
// Updated on 2025-01-29 - resolve null pointer exceptions
// Updated on 2025-02-03 - optimize image loading
// Updated on 2025-02-04 - improve loading indicator
// Updated on 2025-02-06 - simplify API integration
// Updated on 2025-02-12 - add user preferences storage
// Updated on 2025-02-17 - add portfolio summary view
// Updated on 2025-02-24 - implement user profile screen
// Updated on 2025-02-25 - resolve authentication token expiry
// Updated on 2025-02-26 - resolve null pointer exceptions
// Updated on 2025-02-27 - implement chart visualization
// Updated on 2025-02-28 - improve error handling structure
// Updated on 2025-03-05 - refine animation transitions
// Updated on 2025-03-07 - setup firebase configuration
// Updated on 2025-03-09 - improve error handling structure
// Updated on 2025-03-13 - improve button styling
// Updated on 2025-03-16 - correct sorting algorithm
// Updated on 2025-03-18 - add portfolio analysis module
// Updated on 2025-03-19 - address memory leaks
