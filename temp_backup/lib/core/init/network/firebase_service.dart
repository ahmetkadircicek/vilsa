import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vilsa/features/add_stock/model/stock_model.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';

abstract class IFirebaseService {
  Future<void> saveTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> fetchTransactions();
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> removeTransaction(String transactionId);
  Future<void> saveStock(StockModel stock);
  Future<void> updateStock(StockModel stock);
  Future<List<StockModel>> fetchStock();
  Future<StockModel?> fetchStockById(String stockId);
  Future<void> removeStock(String stockId);
  Future<List<StockModel>> fetchStocksWithTransactions();
  Future<void> importJsonData(String jsonFilePath);
}

class FirebaseService extends IFirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  final _database = FirebaseDatabase.instance.ref();
  FirebaseService._internal();

  static FirebaseService get instance => _instance;

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    try {
      final newRef = _database.child('transactions').push();
      final firebaseKey = newRef.key;

      // Store the Firebase-generated key as the ID if we don't have one
      final Map<String, dynamic> transactionData = transaction.toJson();
      if (transaction.id.isEmpty && firebaseKey != null) {
        transactionData['id'] = firebaseKey;
      }

      await newRef.set(transactionData);
      debugPrint("🚀 Transaction saved successfully with key: ${newRef.key ?? 'unknown'}");
    } catch (e) {
      debugPrint("🚨 Transaction save error: $e");
    }
  }

  @override
  Future<void> importJsonData(String jsonFilePath) async {
    try {
      // Read the JSON file
      final String jsonString = await rootBundle.loadString(jsonFilePath);
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      debugPrint("🔍 Starting JSON import from: $jsonFilePath");

      // Clear existing data (optional)
      await _database.child('stock').remove();
      await _database.child('transactions').remove();

      // Process stocks
      if (jsonData.containsKey('stock')) {
        final Map<String, dynamic> stocksData = Map<String, dynamic>.from(jsonData['stock']);

        debugPrint("📊 Found ${stocksData.length} stocks in the JSON file");

        // Create a map of stock IDs to StockModel objects
        Map<String, StockModel> stocksMap = {};

        // Add each stock to the database
        for (var entry in stocksData.entries) {
          final String firebaseKey = entry.key;
          final Map<String, dynamic> stockData = Map<String, dynamic>.from(entry.value);

          // Ensure the stock has an ID
          if (stockData['id'] == null || stockData['id'].toString().isEmpty) {
            stockData['id'] = firebaseKey;
          }

          // Create the stock
          final stock = StockModel.fromJson(stockData);
          stocksMap[stock.id] = stock;

          // Save to Firebase
          final stockRef = _database.child('stock').push();
          await stockRef.set(stockData);
          debugPrint("✅ Imported stock: ${stock.name} (${stock.abbreviation})");
        }

        // Process transactions
        if (jsonData.containsKey('transactions')) {
          final Map<String, dynamic> transactionsData = Map<String, dynamic>.from(jsonData['transactions']);

          debugPrint("🧾 Found ${transactionsData.length} transactions in the JSON file");

          // Add each transaction to the database
          for (var entry in transactionsData.entries) {
            final String firebaseKey = entry.key;
            final Map<String, dynamic> transactionData = Map<String, dynamic>.from(entry.value);

            // Ensure the transaction has an ID
            if (transactionData['id'] == null || transactionData['id'].toString().isEmpty) {
              transactionData['id'] = firebaseKey;
            }

            // Get the associated stock
            if (transactionData.containsKey('stock') && transactionData['stock'] is Map) {
              final Map<String, dynamic> stockData = Map<String, dynamic>.from(transactionData['stock']);
              final String stockId = stockData['id'];

              // Add stockId field for our improved model
              transactionData['stockId'] = stockId;

              // Save to Firebase
              final transactionRef = _database.child('transactions').push();
              await transactionRef.set(transactionData);
              debugPrint("✅ Imported transaction: ${transactionData['id']} for stock ${stockData['abbreviation']}");
            } else {
              debugPrint("⚠️ Transaction is missing stock data: ${transactionData['id']}");
            }
          }
        } else {
          debugPrint("⚠️ No transactions found in the JSON file");
        }

        debugPrint("🎉 JSON import completed successfully!");
      } else {
        debugPrint("⚠️ No stock data found in the JSON file");
      }
    } catch (e) {
      debugPrint("🚨 Error importing JSON data: $e");
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      // Find the transaction by its ID in the database
      final snapshot = await _database.child('transactions').get();

      if (snapshot.exists && snapshot.value != null) {
        final rawData = snapshot.value as Map<Object?, Object?>;

        // Find the Firebase key for this transaction ID
        String? firebaseKey;
        rawData.forEach((key, value) {
          final Map<String, dynamic> transData = Map<String, dynamic>.from(value as Map);
          if (transData['id'] == transaction.id) {
            firebaseKey = key.toString();
          }
        });

        if (firebaseKey != null) {
          await _database.child('transactions').child(firebaseKey!).update(transaction.toJson());
          debugPrint("🚀 Transaction updated successfully!");
        } else {
          debugPrint("⚠️ Transaction not found for update. Creating new one instead.");
          await saveTransaction(transaction);
        }
      }
    } catch (e) {
      debugPrint("🚨 Transaction update error: $e");
    }
  }

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    try {
      final snapshot = await _database.child('transactions').get();

      if (snapshot.exists && snapshot.value != null) {
        debugPrint("🚀 Raw transaction data fetched.");

        final rawData = snapshot.value as Map<Object?, Object?>;
        List<TransactionModel> transactions = [];

        rawData.forEach((key, value) {
          try {
            final transactionMap = Map<String, dynamic>.from(value as Map);

            // Ensure the transaction has an ID
            if (transactionMap['id'] == null || transactionMap['id'].toString().isEmpty) {
              transactionMap['id'] = key.toString();
            }

            // Make sure stock data is properly formatted
            if (transactionMap.containsKey('stock') && transactionMap['stock'] is Map) {
              transactionMap['stock'] = Map<String, dynamic>.from(transactionMap['stock'] as Map);
            }

            // Create transaction model
            TransactionModel transaction = TransactionModel.fromJson(transactionMap);
            transactions.add(transaction);
          } catch (e) {
            debugPrint("🚨 Error parsing individual transaction: $e");
          }
        });

        debugPrint("🚀 Loaded ${transactions.length} transactions.");
        return transactions;
      }
    } catch (e) {
      debugPrint("🚨 Error processing transactions: $e");
    }
    return [];
  }

  @override
  Future<void> removeTransaction(String transactionId) async {
    try {
      final snapshot = await _database.child('transactions').get();

      if (snapshot.exists && snapshot.value != null) {
        final rawData = snapshot.value as Map<Object?, Object?>;

        // Find the Firebase key for this transaction ID
        String? firebaseKey;
        rawData.forEach((key, value) {
          final Map<String, dynamic> transData = Map<String, dynamic>.from(value as Map);
          if (transData['id'] == transactionId) {
            firebaseKey = key.toString();
          }
        });

        if (firebaseKey != null) {
          await _database.child('transactions').child(firebaseKey!).remove();
          debugPrint("🚀 Transaction removed successfully!");
        } else {
          debugPrint("⚠️ Transaction not found for removal.");
        }
      }
    } catch (e) {
      debugPrint("🚨 Error removing transaction: $e");
    }
  }

  @override
  Future<void> saveStock(StockModel stock) async {
    try {
      final newRef = _database.child('stock').push();
      final firebaseKey = newRef.key;

      // Store the Firebase-generated key as the ID if we don't have one
      final Map<String, dynamic> stockData = stock.toJson();
      if (stock.id.isEmpty && firebaseKey != null) {
        stockData['id'] = firebaseKey;
      }

      await newRef.set(stockData);
      debugPrint("🚀 Stock saved successfully with key: ${newRef.key ?? 'unknown'}");
    } catch (e) {
      debugPrint("🚨 Stock save error: $e");
    }
  }

  @override
  Future<void> updateStock(StockModel stock) async {
    try {
      // Find the stock by its ID in the database
      final snapshot = await _database.child('stock').get();

      if (snapshot.exists && snapshot.value != null) {
        final rawData = snapshot.value as Map<Object?, Object?>;

        // Find the Firebase key for this stock ID
        String? firebaseKey;
        rawData.forEach((key, value) {
          final Map<String, dynamic> stockData = Map<String, dynamic>.from(value as Map);
          if (stockData['id'] == stock.id) {
            firebaseKey = key.toString();
          }
        });

        if (firebaseKey != null) {
          await _database.child('stock').child(firebaseKey!).update(stock.toJson());
          debugPrint("🚀 Stock updated successfully!");
        } else {
          debugPrint("⚠️ Stock not found for update. Creating new one instead.");
          await saveStock(stock);
        }
      }
    } catch (e) {
      debugPrint("🚨 Stock update error: $e");
    }
  }

  @override
  Future<List<StockModel>> fetchStock() async {
    try {
      final snapshot = await _database.child('stock').get();
      if (snapshot.exists && snapshot.value != null) {
        final rawData = snapshot.value as Map<Object?, Object?>;
        List<StockModel> stocks = [];

        rawData.forEach((key, value) {
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

        debugPrint("🚀 Loaded ${stocks.length} stocks.");
        return stocks;
      }
    } catch (e) {
      debugPrint("🚨 Error fetching stocks: $e");
    }
    return [];
  }

  @override
  Future<StockModel?> fetchStockById(String stockId) async {
    try {
      final stocks = await fetchStock();
      return stocks.firstWhere((stock) => stock.id == stockId);
    } catch (e) {
      debugPrint("🚨 Error fetching stock by ID: $e");
      return null;
    }
  }

  @override
  Future<void> removeStock(String stockId) async {
    try {
      // First find the stock by its ID
      final snapshot = await _database.child('stock').get();

      if (snapshot.exists && snapshot.value != null) {
        final rawData = snapshot.value as Map<Object?, Object?>;

        // Find the Firebase key for this stock ID
        String? firebaseKey;
        rawData.forEach((key, value) {
          final Map<String, dynamic> stockData = Map<String, dynamic>.from(value as Map);
          if (stockData['id'] == stockId) {
            firebaseKey = key.toString();
          }
        });

        if (firebaseKey != null) {
          // Remove the stock
          await _database.child('stock').child(firebaseKey!).remove();

          // Now find and remove all transactions related to this stock
          final transactionsSnapshot = await _database.child('transactions').get();
          if (transactionsSnapshot.exists && transactionsSnapshot.value != null) {
            final transRawData = transactionsSnapshot.value as Map<Object?, Object?>;

            // Find all transaction keys for this stock ID
            List<String> transactionKeys = [];
            transRawData.forEach((key, value) {
              final Map<String, dynamic> transData = Map<String, dynamic>.from(value as Map);
              if (transData['stockId'] == stockId ||
                  (transData['stock'] is Map && transData['stock']['id'] == stockId)) {
                transactionKeys.add(key.toString());
              }
            });

            // Remove all transactions for this stock
            for (String key in transactionKeys) {
              await _database.child('transactions').child(key).remove();
            }

            debugPrint("🚀 Stock and ${transactionKeys.length} related transactions removed successfully!");
          }
        } else {
          debugPrint("⚠️ Stock not found for removal.");
        }
      }
    } catch (e) {
      debugPrint("🚨 Error removing stock: $e");
    }
  }

  @override
  Future<List<StockModel>> fetchStocksWithTransactions() async {
    try {
      // First get all stocks
      final stocks = await fetchStock();

      // Then get all transactions
      final allTransactions = await fetchTransactions();

      // Group transactions by stock ID
      for (var stock in stocks) {
        final stockTransactions = allTransactions
            .where((transaction) => transaction.stockId == stock.id || transaction.stock.id == stock.id)
            .toList();

        // Update the stock's transactions list
        stock.transactions = stockTransactions;
      }

      debugPrint("🚀 Loaded ${stocks.length} stocks with their transactions.");
      return stocks;
    } catch (e) {
      debugPrint("🚨 Error fetching stocks with transactions: $e");
      return [];
    }
  }
}
