import 'package:flutter/material.dart';
import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/components/success_dialog.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/init/network/dividend_service.dart';
import 'package:vilsa/core/init/network/transaction_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/stock/model/dividend_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

/// ViewModel for managing dividend addition and editing
class AddDividendViewModel extends BaseViewModel {
  final DividendService _dividendService = DividendService.instance;
  final TransactionService _transactionService = TransactionService.instance;

  // Form controllers
  final TextEditingController perShareAmountController =
      TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Form data
  DateTime selectedDate = DateTime.now();
  DividendModel? dividendToEdit;
  int _currentLotCount = 0;

  /// Get current lot count for display
  int get currentLotCount => _currentLotCount;

  /// Calculate total dividend amount based on current lots
  double get totalDividendAmount {
    final perShareAmount =
        parseCurrencyValue(perShareAmountController.text) ?? 0.0;
    return perShareAmount * _currentLotCount;
  }

  /// Set selected date
  void setSelectedDate(DateTime date) {
    selectedDate = date;
    _updateLotCount();
    notifyListeners();
  }

  /// Calculate lot count at the dividend date
  Future<void> _updateLotCount() async {
    try {
      final transactions = await _transactionService.fetchAll();

      // Filter transactions up to the selected date for this stock
      int totalLots = 0;
      for (final transaction in transactions) {
        if (transaction.date.isBefore(selectedDate) ||
            transaction.date.isAtSameMomentAs(selectedDate)) {
          if (transaction.type == TransactionType.buy) {
            totalLots += transaction.quantity;
          } else if (transaction.type == TransactionType.sell) {
            totalLots -= transaction.quantity;
          }
        }
      }

      _currentLotCount = totalLots > 0 ? totalLots : 0;
      notifyListeners();
    } catch (e) {
      debugPrint("Error calculating lot count: $e");
      _currentLotCount = 0;
      notifyListeners();
    }
  }

  /// Initialize for a specific stock
  Future<void> initializeForStock(String stockId) async {
    await _updateLotCount();
  }

  /// Initialize with an existing dividend for editing
  void setDividendToEdit(DividendModel dividend) {
    dividendToEdit = dividend;
    perShareAmountController.text = _formatForInput(dividend.perShareAmount);
    noteController.text = dividend.note;
    selectedDate = dividend.date;
    _currentLotCount = dividend.totalLots;
    notifyListeners();
  }

  /// Format double value for clean input (e.g., 27.65 -> "27,65")
  String _formatForInput(double value) {
    if (value == 0) return '';
    return value.toString().replaceAll('.', ',');
  }

  /// Reset form
  void resetForm() {
    perShareAmountController.clear();
    noteController.clear();
    selectedDate = DateTime.now();
    dividendToEdit = null;
    _currentLotCount = 0;
    notifyListeners();
  }

  /// Parse currency value from text input
  double? parseCurrencyValue(String text, {bool allowZero = false}) {
    if (text.isEmpty) {
      return null;
    }

    try {
      // Clean input format: just numbers and comma
      String cleanText = text.trim();

      // Replace comma with dot (decimal separator)
      String parseableText = cleanText.replaceAll(',', '.');

      double value = double.parse(parseableText);

      // Zero check
      if (!allowZero && value <= 0) {
        return null;
      }

      return value;
    } catch (e) {
      debugPrint("Currency parsing error: $e for value '$text'");
      return null;
    }
  }

  /// Validate that user has lots for dividend
  bool _validateLotCount(BuildContext context) {
    if (_currentLotCount <= 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SuccessDialog(
          message:
              'Bu tarihe kadar bu hisseye ait hiç lot işleminiz bulunmuyor. Önce hisse alım işlemi yapmanız gerekiyor.',
          icon: Icons.warning_amber_rounded,
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
    return true;
  }

  /// Save or update dividend
  Future<DividendModel?> saveDividend(
    StockModel stock, {
    required BuildContext context,
    DividendModel? existingDividend,
  }) async {
    DividendModel? result;

    await executeAsync(() async {
      // Validate per share amount
      double? perShareAmount =
          parseCurrencyValue(perShareAmountController.text);
      if (perShareAmount == null || perShareAmount <= 0) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SuccessDialog(
            message: 'Lütfen geçerli bir hisse başına temettü tutarı girin!',
            icon: Icons.error_outline_rounded,
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Validate lot count (only for new dividends)
      if (existingDividend == null && !_validateLotCount(context)) {
        return;
      }

      // For new dividends, calculate current lot count at selected date
      if (existingDividend == null) {
        // Recalculate lots for the selected stock specifically
        final transactions = await _transactionService.fetchByStockId(stock.id);
        int stockLots = 0;

        for (final transaction in transactions) {
          if (transaction.date.isBefore(selectedDate) ||
              transaction.date.isAtSameMomentAs(selectedDate)) {
            if (transaction.type == TransactionType.buy) {
              stockLots += transaction.quantity;
            } else if (transaction.type == TransactionType.sell) {
              stockLots -= transaction.quantity;
            }
          }
        }

        if (stockLots <= 0) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SuccessDialog(
              message:
                  'Bu tarihe kadar ${stock.name} hissesine ait hiç lot işleminiz bulunmuyor.',
              icon: Icons.warning_amber_rounded,
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        _currentLotCount = stockLots;
      }

      // Create or update dividend
      final dividend = existingDividend?.copyWith(
            perShareAmount: perShareAmount,
            totalLots: existingDividend
                .totalLots, // Keep original lot count for editing
            date: selectedDate,
            note: noteController.text,
          ) ??
          DividendModel.create(
            stockId: stock.id,
            perShareAmount: perShareAmount,
            totalLots: _currentLotCount,
            date: selectedDate,
            note: noteController.text,
          );

      // Save to database
      if (existingDividend != null) {
        await _dividendService.update(dividend);
      } else {
        await _dividendService.save(dividend);
      }

      // Show success dialog with details
      final totalAmount = dividend.totalAmount;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => SuccessDialog(
          message: existingDividend != null
              ? 'Temettü başarıyla güncellendi!\nHisse Başına: ₺${dividend.perShareAmount.toStringAsFixed(4)}\nToplam Lot: ${dividend.totalLots}\nToplam Tutar: ₺${totalAmount.toStringAsFixed(2)}'
              : 'Temettü başarıyla eklendi!\nHisse Başına: ₺${dividend.perShareAmount.toStringAsFixed(4)}\nToplam Lot: ${dividend.totalLots}\nToplam Tutar: ₺${totalAmount.toStringAsFixed(2)}',
          backgroundColor: AppColors.dividendGreen,
          icon: Icons.check_circle_outline_rounded,
          iconColor: Colors.white,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back after dialog
      Future.delayed(const Duration(seconds: 3), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });

      result = dividend;
    }, errorPrefix: "Failed to save dividend");

    return result;
  }

  @override
  void dispose() {
    perShareAmountController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
