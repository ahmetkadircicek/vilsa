import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/core/base/base_service.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

import 'database_helper.dart';

/// Service to handle stock-related data operations
class StockService implements BaseService<StockModel> {
  static final StockService _instance = StockService._internal();
  final DatabaseHelper _db = DatabaseHelper.instance;
  static const String _path = 'stock';

  StockService._internal();

  static StockService get instance => _instance;

  @override
  Future<List<StockModel>> fetchAll() async {
    try {
      final data = await _db.getAll(_path);
      List<StockModel> stocks = [];

      data.forEach((key, value) {
        try {
          final stockMap = Map<String, dynamic>.from(value as Map);

          // Ensure the stock has an ID
          if (stockMap['id'] == null || stockMap['id'].toString().isEmpty) {
            stockMap['id'] = key.toString();
          }

          // Create stock model
          StockModel stock = StockModel.fromJson(stockMap);
          stocks.add(stock);
        } catch (e) {
          debugPrint("🚨 Error parsing individual stock: $e");
        }
      });

      debugPrint("🚀 Loaded ${stocks.length} stocks");
      return stocks;
    } catch (e) {
      debugPrint("🚨 Error fetching stocks: $e");
      throw Exception("Failed to fetch stocks: $e");
    }
  }

  @override
  Future<StockModel?> fetchById(String id) async {
    try {
      final stocks = await fetchAll();
      return stocks.firstWhere((stock) => stock.id == id);
    } catch (e) {
      debugPrint("🚨 Error fetching stock by ID: $e");
      return null;
    }
  }

  @override
  Future<void> save(StockModel stock) async {
    try {
      // Sanitize and validate stock data
      final Map<String, dynamic> stockData = _sanitizeStockData(stock.toJson());

      // If stock has no ID, get one from Firebase
      if (stock.id.isEmpty) {
        final String? newId = await _db.push(_path, stockData);
        if (newId != null) {
          stockData['id'] = newId;
          await _db.update(_path, newId, stockData);
          debugPrint("🚀 New stock created with ID: $newId");
        }
      } else {
        // Use existing ID
        final String? firebaseKey = await _db.findKey(_path, 'id', stock.id);

        if (firebaseKey != null) {
          // Update existing record
          await _db.update(_path, firebaseKey, stockData);
          debugPrint("🚀 Updated existing stock with ID: ${stock.id}");
        } else {
          // Create new record with existing ID
          final String? newId = await _db.push(_path, stockData);
          debugPrint("🚀 Stock saved with key: $newId");
        }
      }
    } catch (e) {
      debugPrint("🚨 Stock save error: $e");
      throw Exception("Failed to save stock: $e");
    }
  }

  @override
  Future<void> update(StockModel stock) async {
    try {
      // Validate stock ID
      if (stock.id.isEmpty) {
        throw Exception("Stock must have a valid ID");
      }

      // Sanitize and validate stock data
      final Map<String, dynamic> stockData = _sanitizeStockData(stock.toJson());

      // Get the firebase key for this stock ID
      final String? firebaseKey = await _db.findKey(_path, 'id', stock.id);

      if (firebaseKey != null) {
        await _db.update(_path, firebaseKey, stockData);
        debugPrint("🚀 Stock updated successfully!");
      } else {
        debugPrint("⚠️ Stock not found for update. Creating new one instead.");
        await save(stock);
      }
    } catch (e) {
      debugPrint("🚨 Stock update error: $e");
      throw Exception("Failed to update stock: $e");
    }
  }

  /// Helper method to sanitize stock data before saving
  Map<String, dynamic> _sanitizeStockData(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);

    // Ensure required fields are present
    if (!result.containsKey('id') || result['id'] == null || result['id'] == '') {
      result['id'] = const Uuid().v4();
    }

    // Ensure name is valid
    if (!result.containsKey('name') || result['name'] == null) {
      result['name'] = '';
    }

    // Ensure abbreviation is valid
    if (!result.containsKey('abbreviation') || result['abbreviation'] == null) {
      result['abbreviation'] = '';
    }

    // Ensure dividends is a valid number
    if (!result.containsKey('dividends') || result['dividends'] == null) {
      result['dividends'] = 0.0;
    } else if (result['dividends'] is String) {
      try {
        result['dividends'] = double.parse(result['dividends'].toString().replaceAll(',', '.'));
      } catch (e) {
        result['dividends'] = 0.0;
      }
    } else if (result['dividends'] is! num) {
      result['dividends'] = 0.0;
    }

    // Don't include transactions in the stock data
    result.remove('transactions');

    // Other dynamic fields shouldn't be stored
    result.remove('currentPrice');
    result.remove('changePercentage');

    return result;
  }

  @override
  Future<void> delete(String stockId) async {
    try {
      // Get the firebase key for this stock ID
      final String? firebaseKey = await _db.findKey(_path, 'id', stockId);

      if (firebaseKey != null) {
        await _db.delete(_path, firebaseKey);
        debugPrint("🚀 Stock removed successfully!");
      } else {
        debugPrint("⚠️ Stock not found for removal.");
      }
    } catch (e) {
      debugPrint("🚨 Error removing stock: $e");
      throw Exception("Failed to delete stock: $e");
    }
  }
}
