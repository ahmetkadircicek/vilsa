import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  static const String _path = 'transactions';
  final _db = FirebaseDatabase.instance.ref();

  TransactionService._internal();
  static TransactionService get instance => _instance;

  Future<List<TransactionModel>> fetchAll() async {
    final snapshot = await _db.child(_path).get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return data.entries.map((entry) {
      final map = Map<String, dynamic>.from(entry.value as Map);
      map['id'] ??= entry.key;
      return TransactionModel.fromJson(map);
    }).toList();
  }

  Future<List<TransactionModel>> fetchByStockId(String stockId) async {
    final all = await fetchAll();
    return all.where((t) => t.stockId == stockId).toList();
  }

  Future<TransactionModel?> fetchById(String id) async {
    final all = await fetchAll();
    return all.firstWhere((t) => t.id == id);
  }

  Future<void> save(TransactionModel transaction) async {
    if (transaction.stockId.isEmpty) {
      throw Exception("Transaction must have a valid stockId");
    }
    final sanitized = _sanitizeTransactionData(transaction.toJson());

    if (transaction.id.isEmpty) {
      final newRef = _db.child(_path).push();
      final newId = newRef.key;
      if (newId != null) {
        sanitized['id'] = newId;
        await newRef.set(sanitized);
      }
    } else {
      final key = await _findKeyByField('id', transaction.id);
      if (key != null) {
        await _db.child(_path).child(key).update(sanitized);
      } else {
        await _db.child(_path).push().set(sanitized);
      }
    }
  }

  Future<void> update(TransactionModel transaction) async {
    if (transaction.id.isEmpty || transaction.stockId.isEmpty) {
      throw Exception("Transaction must have a valid id and stockId");
    }
    final sanitized = _sanitizeTransactionData(transaction.toJson());
    final key = await _findKeyByField('id', transaction.id);
    if (key != null) {
      await _db.child(_path).child(key).update(sanitized);
    } else {
      await save(transaction);
    }
  }

  Future<void> delete(String transactionId) async {
    final key = await _findKeyByField('id', transactionId);
    if (key != null) {
      await _db.child(_path).child(key).remove();
    }
  }

  Future<void> deleteByStockId(String stockId) async {
    final snapshot = await _db.child(_path).get();
    if (!snapshot.exists || snapshot.value == null) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    List<String> keysToDelete = [];

    for (var entry in data.entries) {
      final value = Map<String, dynamic>.from(entry.value);
      if (value['stockId'] == stockId) {
        keysToDelete.add(entry.key);
      } else if (value['stock'] is Map &&
          (value['stock'] as Map)['id'] == stockId) {
        keysToDelete.add(entry.key);
      }
    }

    for (final key in keysToDelete) {
      await _db.child(_path).child(key).remove();
    }
  }

  Map<String, dynamic> _sanitizeTransactionData(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);

    if (result['id'] == null || (result['id'] as String).isEmpty) {
      result['id'] = const Uuid().v4();
    }

    if (result['stockId'] == null || (result['stockId'] as String).isEmpty) {
      if (result['stock'] is Map && result['stock']['id'] != null) {
        result['stockId'] = result['stock']['id'];
      }
    }

    if (result['stockName'] == null ||
        (result['stockName'] as String).isEmpty) {
      if (result['stock'] is Map && result['stock']['name'] != null) {
        result['stockName'] = result['stock']['name'];
      }
    }

    if (result['price'] == null) {
      result['price'] = 0.0;
    } else if (result['price'] is String) {
      try {
        result['price'] =
            double.parse(result['price'].toString().replaceAll(',', '.'));
      } catch (_) {
        result['price'] = 0.0;
      }
    } else if (result['price'] is! num) {
      result['price'] = 0.0;
    }

    if (result['quantity'] == null) {
      result['quantity'] = 0;
    } else if (result['quantity'] is String) {
      try {
        result['quantity'] = int.parse(result['quantity']);
      } catch (_) {
        result['quantity'] = 0;
      }
    } else if (result['quantity'] is double) {
      result['quantity'] = (result['quantity'] as double).toInt();
    } else if (result['quantity'] is! num) {
      result['quantity'] = 0;
    }

    for (var field in ['date', 'createDate']) {
      if (result[field] == null || result[field] is! String) {
        result[field] = DateTime.now().toIso8601String();
      } else {
        try {
          DateTime.parse(result[field]);
        } catch (_) {
          result[field] = DateTime.now().toIso8601String();
        }
      }
    }

    if (result['note'] == null) {
      result['note'] = '';
    }

    result.remove('notes');

    return result;
  }

  Future<String?> _findKeyByField(String fieldName, dynamic fieldValue) async {
    final snapshot = await _db.child(_path).get();
    if (!snapshot.exists || snapshot.value == null) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    for (final entry in data.entries) {
      final valueMap = Map<String, dynamic>.from(entry.value);
      if (valueMap[fieldName] == fieldValue) {
        return entry.key;
      }
    }
    return null;
  }
}
