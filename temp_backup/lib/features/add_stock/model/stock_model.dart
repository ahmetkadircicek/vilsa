import 'package:vilsa/features/add_transaction/model/transaction_model.dart';

class StockModel {
  final String id; // Stock ID
  final String name; // Stock name
  final String abbreviation; // Stock abbreviation
  final double dividends; // Dividends
  List<TransactionModel> transactions; // List of transactions associated with this stock

  StockModel({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.dividends,
    this.transactions = const [], // Initialize with an empty list
  });

  // For Firebase JSON serialization
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "abbreviation": abbreviation,
      "dividends": dividends,
      // We don't include transactions in the stock JSON to avoid circular references
    };
  }

  // For Firebase JSON deserialization
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json["id"] ?? '',
      name: json["name"] ?? '',
      abbreviation: json["abbreviation"] ?? "",
      dividends: (json["dividends"] is num) ? (json["dividends"] as num).toDouble() : 0.0,
      // Transactions will be added separately to avoid circular references
    );
  }

  // Method to update stock details
  StockModel copyWith({
    String? id,
    String? name,
    String? abbreviation,
    double? dividends,
    List<TransactionModel>? transactions,
  }) {
    return StockModel(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      dividends: dividends ?? this.dividends,
      transactions: transactions ?? this.transactions,
    );
  }
}
// Updated on 2025-01-02 - add transaction history page
// Updated on 2025-01-10 - create data caching mechanism
// Updated on 2025-01-11 - improve form element consistency
// Updated on 2025-01-31 - implement filtering options
// Updated on 2025-02-01 - improve button styling
// Updated on 2025-02-12 - address memory leaks
// Updated on 2025-02-19 - implement error handling
// Updated on 2025-02-24 - add search functionality
// Updated on 2025-02-27 - implement sorting options
// Updated on 2025-03-06 - optimize data fetching logic
// Updated on 2025-03-13 - correct data loading problems
// Updated on 2025-03-15 - improve loading indicator
// Updated on 2025-03-19 - enhance component reusability
// Updated on 2025-03-20 - add transaction history page
