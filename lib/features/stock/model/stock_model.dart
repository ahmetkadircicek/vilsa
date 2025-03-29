import 'package:vilsa/features/add_transaction/model/transaction_model.dart';

/// Model representing a stock with its basic information and associated transactions
class StockModel {
  final String id;
  final String name;
  final String abbreviation;
  final double dividends;
  final List<TransactionModel> transactions;
  final double currentPrice;
  final double changePercentage;

  StockModel({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.dividends,
    this.transactions = const [],
    this.currentPrice = 0.0,
    this.changePercentage = 0.0,
  });

  /// Converts this model to a map for Firebase storage
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "abbreviation": abbreviation,
      "dividends": dividends,
      // We don't include transactions in the stock JSON to avoid circular references
      // currentPrice and changePercentage are not stored as they are dynamic values
    };
  }

  /// Creates a StockModel from a JSON map
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json["id"] ?? '',
      name: json["name"] ?? '',
      abbreviation: json["abbreviation"] ?? "",
      dividends: (json["dividends"] is num) ? (json["dividends"] as num).toDouble() : 0.0,
      currentPrice: (json["currentPrice"] is num) ? (json["currentPrice"] as num).toDouble() : 0.0,
      changePercentage: (json["changePercentage"] is num) ? (json["changePercentage"] as num).toDouble() : 0.0,
      // Transactions will be loaded separately
    );
  }

  /// Creates a copy of this model with optional updated values
  StockModel copyWith({
    String? id,
    String? name,
    String? abbreviation,
    double? dividends,
    List<TransactionModel>? transactions,
    double? currentPrice,
    double? changePercentage,
  }) {
    return StockModel(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      dividends: dividends ?? this.dividends,
      transactions: transactions ?? this.transactions,
      currentPrice: currentPrice ?? this.currentPrice,
      changePercentage: changePercentage ?? this.changePercentage,
    );
  }

  /// Calculate the total cost of all transactions
  double get totalCost {
    return transactions.fold(0.0, (sum, transaction) => sum + (transaction.price * transaction.quantity));
  }

  /// Calculate the average price per share
  double get averagePrice {
    int totalQuantity = transactions.fold(0, (sum, transaction) => sum + transaction.quantity);
    return totalQuantity > 0 ? totalCost / totalQuantity : 0.0;
  }

  /// Calculate the total quantity of shares
  int get totalQuantity {
    return transactions.fold(0, (sum, transaction) => sum + transaction.quantity);
  }

  /// Get the stock symbol (same as abbreviation for consistency)
  String get symbol => abbreviation;
}
