import 'package:flutter/material.dart';

/// Base ViewModel class that provides common functionality and state management
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  /// Set loading state and notify listeners
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state with a message and notify listeners
  void setError(String message) {
    _hasError = true;
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
    debugPrint("🚨 Error: $message");
  }

  /// Clear error state and notify listeners
  void clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  /// Safely execute an async function with proper error handling and loading state
  Future<T?> executeAsync<T>(Future<T> Function() action, {String? errorPrefix}) async {
    try {
      setLoading(true);
      clearError();
      final result = await action();
      setLoading(false);
      return result;
    } catch (e) {
      final prefix = errorPrefix != null ? "$errorPrefix: " : "";
      setError("$prefix$e");
      return null;
    }
  }
}
