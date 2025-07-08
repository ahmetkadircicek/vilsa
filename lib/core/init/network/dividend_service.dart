import 'package:firebase_database/firebase_database.dart';
import 'package:vilsa/features/stock/model/dividend_model.dart';

class DividendService {
  static final DividendService _instance = DividendService._internal();
  static const String _path = 'dividends';
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  DividendService._internal();
  static DividendService get instance => _instance;

  Future<List<DividendModel>> fetchAll() async {
    final snapshot = await _dbRef.child(_path).get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final rawData = Map<String, dynamic>.from(snapshot.value as Map);
    return rawData.entries.map((entry) {
      final map = Map<String, dynamic>.from(entry.value as Map);
      map['id'] ??= entry.key;
      return DividendModel.fromJson(map);
    }).toList();
  }

  Future<DividendModel?> fetchById(String id) async {
    final dividends = await fetchAll();
    try {
      return dividends.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<DividendModel>> fetchByStockId(String stockId) async {
    final dividends = await fetchAll();
    final filtered = dividends.where((d) => d.stockId == stockId).toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Future<void> save(DividendModel dividend) async {
    if (dividend.stockId.isEmpty) {
      throw Exception('Dividend must have a valid stockId');
    }

    final data = dividend.toJson();

    if (dividend.id.isEmpty) {
      final newRef = _dbRef.child(_path).push();
      final newId = newRef.key;
      if (newId == null) throw Exception('Failed to generate new key');
      data['id'] = newId;
      await newRef.set(data);
    } else {
      final key = await _findKeyById(dividend.id);
      if (key != null) {
        await _dbRef.child(_path).child(key).update(data);
      } else {
        final newRef = _dbRef.child(_path).push();
        final newId = newRef.key;
        if (newId == null) throw Exception('Failed to generate new key');
        data['id'] = newId;
        await newRef.set(data);
      }
    }
  }

  Future<void> update(DividendModel dividend) async {
    if (dividend.id.isEmpty || dividend.stockId.isEmpty) {
      throw Exception('Dividend must have valid id and stockId');
    }

    final key = await _findKeyById(dividend.id);
    if (key != null) {
      await _dbRef.child(_path).child(key).update(dividend.toJson());
    } else {
      await save(dividend);
    }
  }

  Future<void> delete(String dividendId) async {
    final key = await _findKeyById(dividendId);
    if (key != null) {
      await _dbRef.child(_path).child(key).remove();
    }
  }

  // Future<double> calculateTotalDividends(
  //   String stockId, {
  //   DateTime? startDate,
  //   DateTime? endDate,
  // }) async {
  //   final dividends = await fetchByStockId(stockId);
  //   return dividends.fold(0.0, (total, dividend) {
  //     final inRange =
  //         (startDate == null || !dividend.date.isBefore(startDate)) &&
  //             (endDate == null || !dividend.date.isAfter(endDate));
  //     return inRange ? (total ?? 0) + dividend.totalAmount : total ?? 0;
  //   });
  // }

  Future<void> deleteByStockId(String stockId) async {
    final dividends = await fetchByStockId(stockId);
    for (final dividend in dividends) {
      await delete(dividend.id);
    }
  }

  // Private helper to find Firebase key by dividend id
  Future<String?> _findKeyById(String id) async {
    final snapshot = await _dbRef.child(_path).get();
    if (!snapshot.exists || snapshot.value == null) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    for (final entry in data.entries) {
      final value = Map<String, dynamic>.from(entry.value as Map);
      if (value['id'] == id) {
        return entry.key;
      }
    }
    return null;
  }
}
