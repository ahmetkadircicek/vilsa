import 'package:vilsa/features/add_stock/model/stock_model.dart';

class TransactionModel {
  final String id; // Transaction ID
  final String stockId; // ID of the stock this transaction belongs to
  final StockModel stock; // Reference to the stock model (not serialized)
  final double price; // Transaction price
  final int quantity; // Transaction quantity
  final DateTime date; // Transaction date
  final String note; // Transaction note
  final DateTime createDate; // Creation date
  final double dividends; // Dividends associated with this transaction

  TransactionModel({
    required this.id,
    required this.stockId,
    required this.stock,
    required this.price,
    required this.quantity,
    required this.date,
    required this.note,
    required this.createDate,
    required this.dividends,
  });

  // For Firebase JSON serialization
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "stockId": stockId, // Store only the stock ID
      "stock": {
        "id": stock.id,
        "name": stock.name,
        "abbreviation": stock.abbreviation,
        "dividends": stock.dividends,
      }, // Include minimal stock info
      "price": price,
      "quantity": quantity,
      "date": date.toIso8601String(),
      "note": note,
      "createDate": createDate.toIso8601String(),
      "dividends": dividends,
    };
  }

  // For Firebase JSON deserialization
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Create a stock model from the embedded stock data
    StockModel stockModel;

    if (json["stock"] is Map) {
      final stockJson = Map<String, dynamic>.from(json["stock"] as Map);
      stockModel = StockModel.fromJson(stockJson);
    } else {
      // Fallback if stock data is missing or malformed
      stockModel = StockModel(
        id: '',
        name: 'Unknown Stock',
        abbreviation: 'UNK',
        dividends: 0.0,
      );
    }

    // Use stockId from the JSON if available, otherwise use the stock's ID
    final String stockId = json["stockId"] ?? stockModel.id;

    return TransactionModel(
      id: json["id"] ?? '',
      stockId: stockId,
      stock: stockModel,
      price: (json["price"] is num) ? (json["price"] as num).toDouble() : 0.0,
      quantity: json["quantity"] is int ? json["quantity"] as int : 0,
      date: json["date"] != null ? DateTime.parse(json["date"]) : DateTime.now(),
      note: json["note"] ?? '',
      createDate: json["createDate"] != null ? DateTime.parse(json["createDate"]) : DateTime.now(),
      dividends: (json["dividends"] is num) ? (json["dividends"] as num).toDouble() : 0.0,
    );
  }

  // Create a copy of this transaction with updated fields
  TransactionModel copyWith({
    String? id,
    String? stockId,
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
      stock: stock ?? this.stock,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      note: note ?? this.note,
      createDate: createDate ?? this.createDate,
      dividends: dividends ?? this.dividends,
    );
  }
}
// Updated on 2025-01-10 - correct sorting algorithm
// Updated on 2025-02-02 - enhance performance of list rendering
// Updated on 2025-02-03 - simplify API integration
// Updated on 2025-02-05 - address network timeout handling
// Updated on 2025-02-06 - setup firebase configuration
// Updated on 2025-02-14 - add stock detail screen
// Updated on 2025-02-21 - implement sorting options
// Updated on 2025-02-25 - correct date formatting issues
// Updated on 2025-03-05 - implement filtering options
// Updated on 2025-03-10 - create data caching mechanism
