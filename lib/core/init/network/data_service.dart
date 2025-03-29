import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

import 'database_helper.dart';
import 'stock_service.dart';
import 'transaction_service.dart';

/// Service to handle combined data operations and synchronization
class DataService {
  static final DataService _instance = DataService._internal();
  final DatabaseHelper _db = DatabaseHelper.instance;
  final StockService _stockService = StockService.instance;
  final TransactionService _transactionService = TransactionService.instance;

  DataService._internal();

  static DataService get instance => _instance;

  /// Fetch stocks with their related transactions
  Future<List<StockModel>> fetchStocksWithTransactions() async {
    try {
      // Fetch all stocks
      List<StockModel> stocks = await _stockService.fetchAll();

      // If no stocks found, return empty list
      if (stocks.isEmpty) {
        debugPrint("⚠️ No stocks found");
        return [];
      }

      // Fetch all transactions
      List<TransactionModel> allTransactions = await _transactionService.fetchAll();

      // If no transactions found, just return stocks
      if (allTransactions.isEmpty) {
        debugPrint("⚠️ No transactions found");
        return stocks;
      }

      // Map to store stock IDs for faster lookup
      final Map<String, String> stockIds = {};
      for (var stock in stocks) {
        stockIds[stock.id] = stock.id;
      }

      // Group transactions by stockId
      Map<String, List<TransactionModel>> transactionsByStock = {};

      for (var transaction in allTransactions) {
        // Determine the actual stockId
        String? stockId = transaction.stockId;

        // If stockId is empty or not valid, try to get it from the stock object
        if (stockId.isEmpty || !stockIds.containsKey(stockId)) {
          if (transaction.stock != null) {
            stockId = transaction.stock!.id;
          }
        }

        // Skip transactions without a valid stock reference
        if (stockId.isEmpty || !stockIds.containsKey(stockId)) {
          debugPrint("⚠️ Skipping transaction ${transaction.id} - Invalid stockId: $stockId");
          continue;
        }

        // Initialize the list if not already present
        if (!transactionsByStock.containsKey(stockId)) {
          transactionsByStock[stockId] = [];
        }

        // Add the transaction to the correct stock
        transactionsByStock[stockId]!.add(transaction);
      }

      // Assign transactions to each stock
      List<StockModel> enrichedStocks = stocks.map((stock) {
        // Get transactions for this stock, or empty list if none found
        List<TransactionModel> stockTransactions = transactionsByStock[stock.id] ?? [];

        // Sort transactions by date (newest first)
        stockTransactions.sort((a, b) => b.date.compareTo(a.date));

        // Create a new stock model with the transactions
        return stock.copyWith(transactions: stockTransactions);
      }).toList();

      debugPrint("🚀 Loaded ${enrichedStocks.length} stocks with ${allTransactions.length} transactions");
      return enrichedStocks;
    } catch (e) {
      debugPrint("🚨 Error fetching stocks with transactions: $e");
      throw Exception("Failed to fetch stocks with transactions: $e");
    }
  }

  /// Save a stock with its transactions
  Future<void> saveStockWithTransactions(StockModel stock) async {
    try {
      // Save the stock first
      await _stockService.save(stock);

      // Save each transaction
      for (var transaction in stock.transactions) {
        // Make sure transaction has the correct stockId
        TransactionModel updatedTransaction = transaction.copyWith(stockId: stock.id);
        await _transactionService.save(updatedTransaction);
      }

      debugPrint("🚀 Stock and ${stock.transactions.length} transactions saved successfully");
    } catch (e) {
      debugPrint("🚨 Error saving stock with transactions: $e");
      throw Exception("Failed to save stock with transactions: $e");
    }
  }

  /// Delete a stock and all its transactions
  Future<void> deleteStockWithTransactions(String stockId) async {
    try {
      // Delete all related transactions first
      await _transactionService.deleteByStockId(stockId);

      // Then delete the stock
      await _stockService.delete(stockId);

      debugPrint("🚀 Stock and its transactions deleted successfully");
    } catch (e) {
      debugPrint("🚨 Error deleting stock with transactions: $e");
      throw Exception("Failed to delete stock with transactions: $e");
    }
  }

  /// Update a stock and manage its transactions
  Future<void> updateStockWithTransactions(StockModel updatedStock, List<TransactionModel> originalTransactions) async {
    try {
      // Update the stock
      await _stockService.update(updatedStock);

      // Find transactions to add, update, or delete
      Set<String> updatedTransactionIds = updatedStock.transactions.map((t) => t.id).toSet();
      Set<String> originalTransactionIds = originalTransactions.map((t) => t.id).toSet();

      // Transactions to delete (in original but not in updated)
      Set<String> transactionsToDelete = originalTransactionIds.difference(updatedTransactionIds);

      // Delete transactions that are no longer present
      for (String transactionId in transactionsToDelete) {
        await _transactionService.delete(transactionId);
      }

      // Add or update the current transactions
      for (var transaction in updatedStock.transactions) {
        // Ensure transaction has the correct stockId
        TransactionModel updatedTransaction = transaction.copyWith(stockId: updatedStock.id);

        if (transaction.id.isEmpty || !originalTransactionIds.contains(transaction.id)) {
          // New transaction
          await _transactionService.save(updatedTransaction);
        } else {
          // Existing transaction
          await _transactionService.update(updatedTransaction);
        }
      }

      debugPrint("🚀 Stock updated with ${updatedStock.transactions.length} transactions");
    } catch (e) {
      debugPrint("🚨 Error updating stock with transactions: $e");
      throw Exception("Failed to update stock with transactions: $e");
    }
  }

  /// Import sample data from a JSON file
  Future<void> importSampleData(String jsonFilePath) async {
    try {
      // Clear existing data
      await _db.getAll('stock').then((data) async {
        for (String key in data.keys) {
          await _db.delete('stock', key);
        }
      });

      await _db.getAll('transactions').then((data) async {
        for (String key in data.keys) {
          await _db.delete('transactions', key);
        }
      });

      // Read the JSON file
      final String jsonString = await rootBundle.loadString(jsonFilePath);
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      debugPrint("🔍 Starting JSON import from: $jsonFilePath");

      // Process stocks
      if (jsonData.containsKey('stocks')) {
        final List<dynamic> stocksData = jsonData['stocks'];

        for (var stockData in stocksData) {
          final StockModel stock = StockModel.fromJson(stockData as Map<String, dynamic>);
          await _stockService.save(stock);
        }

        debugPrint("✅ Imported ${stocksData.length} stocks");
      }

      // Process transactions
      if (jsonData.containsKey('transactions')) {
        final List<dynamic> transactionsData = jsonData['transactions'];

        for (var transactionData in transactionsData) {
          final TransactionModel transaction = TransactionModel.fromJson(transactionData as Map<String, dynamic>);
          await _transactionService.save(transaction);
        }

        debugPrint("✅ Imported ${transactionsData.length} transactions");
      }

      debugPrint("🚀 Sample data import completed successfully");
    } catch (e) {
      debugPrint("🚨 Error importing sample data: $e");
      throw Exception("Failed to import sample data: $e");
    }
  }
}
