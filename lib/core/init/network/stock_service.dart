import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

class StockService {
  static final StockService _instance = StockService._internal();
  static const String _path = 'stock';
  final _db = FirebaseDatabase.instance.ref();

  StockService._internal();
  static StockService get instance => _instance;

  Future<List<StockModel>> fetchAll() async {
    final snapshot = await _db.child(_path).get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return data.entries.map((entry) {
      final map = Map<String, dynamic>.from(entry.value as Map);
      map['id'] ??= entry.key;
      return StockModel.fromJson(map);
    }).toList();
  }

  Future<StockModel?> fetchById(String id) async {
    final all = await fetchAll();
    return all.firstWhere((e) => e.id == id);
  }

  Future<void> save(StockModel stock) async {
    final sanitizedData = _sanitizeStockData(stock.toJson());

    if (stock.id.isEmpty) {
      final newRef = _db.child(_path).push();
      final newId = newRef.key;
      if (newId != null) {
        sanitizedData['id'] = newId;
        await newRef.set(sanitizedData);
      }
    } else {
      final key = await _findKeyByField('id', stock.id);
      if (key != null) {
        await _db.child(_path).child(key).update(sanitizedData);
      } else {
        await _db.child(_path).push().set(sanitizedData);
      }
    }
  }

  Future<void> update(StockModel stock) async {
    if (stock.id.isEmpty) throw Exception("Stock must have a valid ID");

    final sanitizedData = _sanitizeStockData(stock.toJson());
    final key = await _findKeyByField('id', stock.id);

    if (key != null) {
      await _db.child(_path).child(key).update(sanitizedData);
    } else {
      await save(stock);
    }
  }

  Future<void> delete(String stockId) async {
    final key = await _findKeyByField('id', stockId);
    if (key != null) {
      await _db.child(_path).child(key).remove();
    }
  }

  Map<String, dynamic> _sanitizeStockData(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);

    if (result['id'] == null || (result['id'] as String).isEmpty) {
      result['id'] = const Uuid().v4();
    }
    if (result['name'] == null) result['name'] = '';
    if (result['abbreviation'] == null) result['abbreviation'] = '';

    if (result['dividends'] == null) {
      result['dividends'] = 0.0;
    } else if (result['dividends'] is String) {
      try {
        result['dividends'] =
            double.parse((result['dividends'] as String).replaceAll(',', '.'));
      } catch (_) {
        result['dividends'] = 0.0;
      }
    } else if (result['dividends'] is! num) {
      result['dividends'] = 0.0;
    }

    result.remove('transactions');
    result.remove('currentPrice');
    result.remove('changePercentage');

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
