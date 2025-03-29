import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/core/base/base_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';

import 'database_helper.dart';

/// Service to handle transaction-related data operations
class TransactionService implements BaseService<TransactionModel> {
  static final TransactionService _instance = TransactionService._internal();
  final DatabaseHelper _db = DatabaseHelper.instance;
  static const String _path = 'transactions';

  TransactionService._internal();

  static TransactionService get instance => _instance;

  @override
  Future<List<TransactionModel>> fetchAll() async {
    try {
      final data = await _db.getAll(_path);
      List<TransactionModel> transactions = [];

      data.forEach((key, value) {
        try {
          final transactionMap = Map<String, dynamic>.from(value as Map);

          // Ensure the transaction has an ID
          if (transactionMap['id'] == null || transactionMap['id'].toString().isEmpty) {
            transactionMap['id'] = key.toString();
          }

          // Create transaction model
          TransactionModel transaction = TransactionModel.fromJson(transactionMap);
          transactions.add(transaction);
        } catch (e) {
          debugPrint("🚨 Error parsing individual transaction: $e");
        }
      });

      debugPrint("🚀 Loaded ${transactions.length} transactions");
      return transactions;
    } catch (e) {
      debugPrint("🚨 Error fetching transactions: $e");
      throw Exception("Failed to fetch transactions: $e");
    }
  }

  /// Fetch transactions for a specific stock
  Future<List<TransactionModel>> fetchByStockId(String stockId) async {
    try {
      final transactions = await fetchAll();
      return transactions.where((transaction) => transaction.stockId == stockId).toList();
    } catch (e) {
      debugPrint("🚨 Error fetching transactions for stock: $e");
      return [];
    }
  }

  @override
  Future<TransactionModel?> fetchById(String id) async {
    try {
      final transactions = await fetchAll();
      return transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      debugPrint("🚨 Error fetching transaction by ID: $e");
      return null;
    }
  }

  @override
  Future<void> save(TransactionModel transaction) async {
    try {
      // Validate transaction data
      if (transaction.stockId.isEmpty) {
        throw Exception("Transaction must have a valid stockId");
      }

      // Prepare transaction data
      final Map<String, dynamic> transactionData = _sanitizeTransactionData(transaction.toJson());

      // If transaction has no ID, get one from Firebase
      if (transaction.id.isEmpty) {
        final String? newId = await _db.push(_path, transactionData);
        if (newId != null) {
          transactionData['id'] = newId;
          await _db.update(_path, newId, transactionData);
          debugPrint("🚀 New transaction created with ID: $newId");
        }
      } else {
        // Use existing ID
        final String? firebaseKey = await _db.findKey(_path, 'id', transaction.id);

        if (firebaseKey != null) {
          // Update existing record
          await _db.update(_path, firebaseKey, transactionData);
          debugPrint("🚀 Updated existing transaction with ID: ${transaction.id}");
        } else {
          // Create new record with existing ID
          final String? newId = await _db.push(_path, transactionData);
          debugPrint("🚀 Transaction saved with key: $newId");
        }
      }
    } catch (e) {
      debugPrint("🚨 Transaction save error: $e");
      throw Exception("Failed to save transaction: $e");
    }
  }

  @override
  Future<void> update(TransactionModel transaction) async {
    try {
      // Validate transaction data
      if (transaction.id.isEmpty || transaction.stockId.isEmpty) {
        throw Exception("Transaction must have a valid id and stockId");
      }

      // Prepare transaction data
      final Map<String, dynamic> transactionData = _sanitizeTransactionData(transaction.toJson());

      // Get the firebase key for this transaction ID
      final String? firebaseKey = await _db.findKey(_path, 'id', transaction.id);

      if (firebaseKey != null) {
        await _db.update(_path, firebaseKey, transactionData);
        debugPrint("🚀 Transaction updated successfully!");
      } else {
        debugPrint("⚠️ Transaction not found for update. Creating new one instead.");
        await save(transaction);
      }
    } catch (e) {
      debugPrint("🚨 Transaction update error: $e");
      throw Exception("Failed to update transaction: $e");
    }
  }

  /// Helper method to sanitize transaction data before saving
  Map<String, dynamic> _sanitizeTransactionData(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);

    // Ensure required fields are present
    if (!result.containsKey('id') || result['id'] == null) {
      result['id'] = const Uuid().v4();
    }

    // Ensure stockId is valid
    if (!result.containsKey('stockId') || result['stockId'] == null || result['stockId'] == '') {
      if (result.containsKey('stock') && result['stock'] is Map && result['stock']['id'] != null) {
        result['stockId'] = result['stock']['id'];
      }
    }

    // Ensure stockName is valid
    if (!result.containsKey('stockName') || result['stockName'] == null || result['stockName'] == '') {
      if (result.containsKey('stock') && result['stock'] is Map && result['stock']['name'] != null) {
        result['stockName'] = result['stock']['name'];
      }
    }

    // Ensure numeric fields are proper numbers
    for (var field in ['price', 'dividends']) {
      if (!result.containsKey(field) || result[field] == null) {
        result[field] = 0.0;
      } else if (result[field] is String) {
        try {
          result[field] = double.parse(result[field].toString().replaceAll(',', '.'));
        } catch (e) {
          result[field] = 0.0;
        }
      } else if (result[field] is! num) {
        result[field] = 0.0;
      }
    }

    // Ensure quantity is an integer
    if (!result.containsKey('quantity') || result['quantity'] == null) {
      result['quantity'] = 0;
    } else if (result['quantity'] is String) {
      try {
        result['quantity'] = int.parse(result['quantity']);
      } catch (e) {
        result['quantity'] = 0;
      }
    } else if (result['quantity'] is! num) {
      result['quantity'] = 0;
    } else if (result['quantity'] is double) {
      result['quantity'] = (result['quantity'] as double).toInt();
    }

    // Ensure dates are valid
    for (var field in ['date', 'createDate']) {
      if (!result.containsKey(field) || result[field] == null) {
        result[field] = DateTime.now().toIso8601String();
      } else if (result[field] is! String) {
        result[field] = DateTime.now().toIso8601String();
      } else {
        try {
          // Validate the date string
          DateTime.parse(result[field]);
        } catch (e) {
          result[field] = DateTime.now().toIso8601String();
        }
      }
    }

    // Ensure note is valid
    if (!result.containsKey('note') || result['note'] == null) {
      result['note'] = '';
    }

    // Remove legacy fields
    result.remove('notes');

    return result;
  }

  @override
  Future<void> delete(String transactionId) async {
    try {
      // Get the firebase key for this transaction ID
      final String? firebaseKey = await _db.findKey(_path, 'id', transactionId);

      if (firebaseKey != null) {
        await _db.delete(_path, firebaseKey);
        debugPrint("🚀 Transaction removed successfully!");
      } else {
        debugPrint("⚠️ Transaction not found for removal.");
      }
    } catch (e) {
      debugPrint("🚨 Error removing transaction: $e");
      throw Exception("Failed to delete transaction: $e");
    }
  }

  /// Delete all transactions for a specific stock
  Future<void> deleteByStockId(String stockId) async {
    try {
      // Find all transaction keys for this stock ID
      final List<String> transactionKeys = await _db.findKeys(_path, 'stockId', stockId);

      // Also check nested stock object
      final data = await _db.getAll(_path);
      for (var entry in data.entries) {
        final value = Map<String, dynamic>.from(entry.value as Map);
        if (value['stock'] is Map && (value['stock'] as Map)['id'] == stockId && !transactionKeys.contains(entry.key)) {
          transactionKeys.add(entry.key);
        }
      }

      // Remove all transactions for this stock
      for (String key in transactionKeys) {
        await _db.delete(_path, key);
      }

      debugPrint("🚀 Removed ${transactionKeys.length} transactions for stock $stockId");
    } catch (e) {
      debugPrint("🚨 Error removing transactions for stock: $e");
      throw Exception("Failed to delete transactions for stock: $e");
    }
  }
}
