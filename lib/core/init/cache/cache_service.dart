import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/stock/model/dividend_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;

  // Cache keys
  static const String _stocksKey = 'cached_stocks';
  static const String _transactionsKey = 'cached_transactions';
  static const String _dividendsKey = 'cached_dividends';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _pendingOperationsKey = 'pending_operations';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Stocks Cache
  Future<void> cacheStocks(List<StockModel> stocks) async {
    final stocksJson = stocks.map((stock) => stock.toJson()).toList();
    await _prefs?.setString(_stocksKey, jsonEncode(stocksJson));
    await _updateLastSync();
  }

  Future<List<StockModel>> getCachedStocks() async {
    final stocksString = _prefs?.getString(_stocksKey);
    if (stocksString == null) return [];

    try {
      final stocksJson = jsonDecode(stocksString) as List;
      return stocksJson.map((json) => StockModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Transactions Cache
  Future<void> cacheTransactions(List<TransactionModel> transactions) async {
    final transactionsJson = transactions.map((t) => t.toJson()).toList();
    await _prefs?.setString(_transactionsKey, jsonEncode(transactionsJson));
    await _updateLastSync();
  }

  Future<List<TransactionModel>> getCachedTransactions() async {
    final transactionsString = _prefs?.getString(_transactionsKey);
    if (transactionsString == null) return [];

    try {
      final transactionsJson = jsonDecode(transactionsString) as List;
      return transactionsJson
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Dividends Cache
  Future<void> cacheDividends(List<DividendModel> dividends) async {
    final dividendsJson = dividends.map((d) => d.toJson()).toList();
    await _prefs?.setString(_dividendsKey, jsonEncode(dividendsJson));
    await _updateLastSync();
  }

  Future<List<DividendModel>> getCachedDividends() async {
    final dividendsString = _prefs?.getString(_dividendsKey);
    if (dividendsString == null) return [];

    try {
      final dividendsJson = jsonDecode(dividendsString) as List;
      return dividendsJson.map((json) => DividendModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Pending Operations (for offline operations)
  Future<void> addPendingOperation(Map<String, dynamic> operation) async {
    final operations = await getPendingOperations();
    operations.add({
      ...operation,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _prefs?.setString(_pendingOperationsKey, jsonEncode(operations));
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final operationsString = _prefs?.getString(_pendingOperationsKey);
    if (operationsString == null) return [];

    try {
      final operationsJson = jsonDecode(operationsString) as List;
      return operationsJson.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> removePendingOperation(int index) async {
    final operations = await getPendingOperations();
    if (index >= 0 && index < operations.length) {
      operations.removeAt(index);
      await _prefs?.setString(_pendingOperationsKey, jsonEncode(operations));
    }
  }

  Future<void> clearPendingOperations() async {
    await _prefs?.remove(_pendingOperationsKey);
  }

  // Sync Management
  Future<void> _updateLastSync() async {
    await _prefs?.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastSyncTime() async {
    final timestamp = _prefs?.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<bool> isCacheExpired(
      {Duration maxAge = const Duration(hours: 1)}) async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) > maxAge;
  }

  // Clear Cache
  Future<void> clearCache() async {
    await _prefs?.remove(_stocksKey);
    await _prefs?.remove(_transactionsKey);
    await _prefs?.remove(_dividendsKey);
    await _prefs?.remove(_lastSyncKey);
  }

  Future<void> clearAll() async {
    await clearCache();
    await clearPendingOperations();
  }
}
