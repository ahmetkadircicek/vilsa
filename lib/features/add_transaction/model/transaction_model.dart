import 'package:vilsa/features/stock/model/stock_model.dart';

/// Model representing a stock transaction with associated information
class TransactionModel {
  final String id;
  final String stockId;
  final String stockName;
  final StockModel? stock; // Nullable to break circular dependency
  final double price;
  final int quantity;
  final DateTime date;
  final String note;
  final DateTime createDate;
  final double dividends;

  TransactionModel({
    required this.id,
    required this.stockId,
    this.stockName = '',
    this.stock,
    required this.price,
    required this.quantity,
    required this.date,
    this.note = '',
    required this.createDate,
    required this.dividends,
  });

  /// Converts this model to a map for Firebase storage
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "stockId": stockId,
      "stockName": stockName,
      "stock": stock != null
          ? {
              "id": stock!.id,
              "name": stock!.name,
              "abbreviation": stock!.abbreviation,
              "dividends": stock!.dividends,
            }
          : null,
      "price": price,
      "quantity": quantity,
      "date": date.toIso8601String(),
      "note": note,
      "createDate": createDate.toIso8601String(),
      "dividends": dividends,
    };
  }

  /// Creates a TransactionModel from a JSON map
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Create a stock model from the embedded stock data if available
    StockModel? stockModel;

    if (json["stock"] is Map) {
      final stockJson = Map<String, dynamic>.from(json["stock"] as Map);
      stockModel = StockModel.fromJson(stockJson);
    }

    // Use stockId from the JSON if available, otherwise use the stock's ID
    final String stockId = json["stockId"] ?? (stockModel?.id ?? '');

    // Use stockName or get it from the stock model
    final String stockName = json["stockName"] ?? stockModel?.name ?? '';

    // Get note field, handling both "note" and "notes" for backwards compatibility
    final String note = json["note"] ?? json["notes"] ?? '';

    // Handle price safely
    double price = 0.0;
    if (json["price"] is num) {
      price = (json["price"] as num).toDouble();
    } else if (json["price"] is String) {
      price = double.tryParse(json["price"] as String) ?? 0.0;
    }

    // Handle quantity safely
    int quantity = 0;
    if (json["quantity"] is num) {
      quantity = (json["quantity"] as num).toInt();
    } else if (json["quantity"] is String) {
      quantity = int.tryParse(json["quantity"] as String) ?? 0;
    }

    // Handle dividends safely
    double dividends = 0.0;
    if (json["dividends"] is num) {
      dividends = (json["dividends"] as num).toDouble();
    } else if (json["dividends"] is String) {
      dividends = double.tryParse(json["dividends"] as String) ?? 0.0;
    }

    return TransactionModel(
      id: json["id"] ?? '',
      stockId: stockId,
      stockName: stockName,
      stock: stockModel,
      price: price,
      quantity: quantity,
      date: json["date"] != null ? DateTime.parse(json["date"]) : DateTime.now(),
      note: note,
      createDate: json["createDate"] != null ? DateTime.parse(json["createDate"]) : DateTime.now(),
      dividends: dividends,
    );
  }

  /// Creates a copy of this model with optional updated values
  TransactionModel copyWith({
    String? id,
    String? stockId,
    String? stockName,
    StockModel? stock,
    double? price,
    int? quantity,
    DateTime? date,
    String? note,
    DateTime? createDate,
    double? dividends,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      stockId: stockId ?? this.stockId,
      stockName: stockName ?? this.stockName,
      stock: stock ?? this.stock,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      note: note ?? this.note,
      createDate: createDate ?? this.createDate,
      dividends: dividends ?? this.dividends,
    );
  }

  /// Calculate the total cost of this transaction
  double get totalCost => price * quantity;
}
