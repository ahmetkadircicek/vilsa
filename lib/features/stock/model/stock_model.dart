import 'package:vilsa/features/add_transaction/model/transaction_model.dart';

class StockModel {
  final String id; // Stock ID
  final String name; // Stock name
  final String abbreviation; // Stock abbreviation
  final double dividends; // Dividends
  final List<TransactionModel> transactions; // List of transactions associated with this stock

  StockModel({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.dividends,
    this.transactions = const [], // Initialize with an empty list
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "abbreviation": abbreviation,
      "dividends": dividends,
      "transactions": transactions.map((transaction) => transaction.toJson()).toList(),
    };
  }

  factory StockModel.fromJson(Map<String, dynamic> json) {
    var transactionList = json["transactions"] as List<dynamic>? ?? [];
    List<TransactionModel> transactions = transactionList.map((item) => TransactionModel.fromJson(item)).toList();

    return StockModel(
      id: json["id"] ?? '',
      name: json["name"],
      abbreviation: json["abbreviation"] ?? "",
      dividends: (json["dividends"] is num) ? (json["dividends"] as num).toDouble() : 0.0,
      transactions: transactions,
    );
  }
}
// Updated on 2025-01-23 - implement sorting options
// Updated on 2025-01-24 - address UI alignment issues
// Updated on 2025-01-24 - fix API response handling
// Updated on 2025-01-30 - fix layout on smaller screens
// Updated on 2025-02-03 - enhance performance of list rendering
// Updated on 2025-02-06 - implement dark mode support
// Updated on 2025-02-07 - enhance component reusability
// Updated on 2025-02-08 - implement dark mode support
// Updated on 2025-02-12 - address UI alignment issues
// Updated on 2025-03-14 - create data caching mechanism
// Updated on 2025-03-14 - resolve authentication token expiry
