import 'package:uuid/uuid.dart';

/// Model representing a dividend payment for a stock
class DividendModel {
  final String id;
  final String stockId;
  final double perShareAmount; // Amount per share
  final int totalLots; // Total lots at the time of dividend
  final DateTime date;
  final DateTime createDate;
  final String note;

  DividendModel({
    required this.id,
    required this.stockId,
    required this.perShareAmount,
    required this.totalLots,
    required this.date,
    required this.createDate,
    this.note = '',
  });

  /// Calculate total dividend amount
  double get totalAmount => perShareAmount * totalLots;

  /// Factory constructor for creating a new dividend
  factory DividendModel.create({
    required String stockId,
    required double perShareAmount,
    required int totalLots,
    required DateTime date,
    String note = '',
  }) {
    return DividendModel(
      id: const Uuid().v4(),
      stockId: stockId,
      perShareAmount: perShareAmount,
      totalLots: totalLots,
      date: date,
      createDate: DateTime.now(),
      note: note,
    );
  }

  /// Converts this model to a map for storage
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "stockId": stockId,
      "perShareAmount": perShareAmount,
      "totalLots": totalLots,
      "date": date.toIso8601String(),
      "createDate": createDate.toIso8601String(),
      "note": note,
    };
  }

  /// Creates a DividendModel from a JSON map
  factory DividendModel.fromJson(Map<String, dynamic> json) {
    // Handle backward compatibility for old "amount" field
    double perShareAmount = 0.0;
    int totalLots = 0;

    if (json.containsKey("perShareAmount")) {
      perShareAmount = (json["perShareAmount"] is num)
          ? (json["perShareAmount"] as num).toDouble()
          : 0.0;
    } else if (json.containsKey("amount")) {
      // Backward compatibility - assume it was total amount with 1 lot
      perShareAmount =
          (json["amount"] is num) ? (json["amount"] as num).toDouble() : 0.0;
    }

    if (json.containsKey("totalLots")) {
      totalLots =
          (json["totalLots"] is num) ? (json["totalLots"] as num).toInt() : 1;
    } else {
      // Backward compatibility
      totalLots = 1;
    }

    return DividendModel(
      id: json["id"] ?? '',
      stockId: json["stockId"] ?? '',
      perShareAmount: perShareAmount,
      totalLots: totalLots,
      date: DateTime.tryParse(json["date"] ?? '') ?? DateTime.now(),
      createDate: DateTime.tryParse(json["createDate"] ?? '') ?? DateTime.now(),
      note: json["note"] ?? '',
    );
  }

  /// Creates a copy of this model with optional updated values
  DividendModel copyWith({
    String? id,
    String? stockId,
    double? perShareAmount,
    int? totalLots,
    DateTime? date,
    DateTime? createDate,
    String? note,
  }) {
    return DividendModel(
      id: id ?? this.id,
      stockId: stockId ?? this.stockId,
      perShareAmount: perShareAmount ?? this.perShareAmount,
      totalLots: totalLots ?? this.totalLots,
      date: date ?? this.date,
      createDate: createDate ?? this.createDate,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'DividendModel(id: $id, stockId: $stockId, perShareAmount: $perShareAmount, totalLots: $totalLots, totalAmount: $totalAmount, date: $date)';
  }
}
