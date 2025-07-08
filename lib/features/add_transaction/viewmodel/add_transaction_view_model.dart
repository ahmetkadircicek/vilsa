import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/components/success_dialog.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/init/navigation/navigation_service.dart';
import 'package:vilsa/core/init/network/stock_service.dart';
import 'package:vilsa/core/init/network/transaction_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';
import 'package:vilsa/features/stock_details/viewmodel/stock_details_view_model.dart';

/// ViewModel for adding or editing transactions
class AddTransactionViewModel extends BaseViewModel {
  final TransactionService _transactionService = TransactionService.instance;
  final StockService _stockService = StockService.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController abbreviationController = TextEditingController();
  final BoardDateTimeController controller = BoardDateTimeController();
  String? _stockId;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  StockModel? selectedStock;
  TransactionType selectedType = TransactionType.buy;
  TransactionModel? transactionToEdit;

  // For dropdown stock selection
  List<StockModel> _stocks = [];
  List<StockModel> get stocks => _stocks;

  String? get stockId => _stockId;
  set stockId(String? value) {
    _stockId = value;
    notifyListeners();
  }

  /// Set the selected date
  void setSelectedDate(DateTime date) {
    // Aynı tarih zaten seçiliyse gereksiz bildirim gönderme
    if (selectedDate == date) return;

    selectedDate = date;
    selectedTime = TimeOfDay.fromDateTime(date);
    notifyListeners();
  }

  /// Load stocks from service
  Future<void> loadStocks() async {
    try {
      setLoading(true);
      _stocks = await _stockService.fetchAll();
      setLoading(false);
    } catch (e) {
      setLoading(false);
      throw Exception('Failed to load stocks: $e');
    }
  }

  /// Initialize with an existing transaction for editing
  void setTransactionToEdit(TransactionModel transaction) {
    transactionToEdit = transaction;
    // Use clean format for editing
    priceController.text = _formatForInput(transaction.price);
    quantityController.text = transaction.quantity.toString();
    noteController.text = transaction.note;
    selectedDate = transaction.date;
    selectedTime = TimeOfDay.fromDateTime(transaction.date);
    selectedType = transaction.type;
    selectedStock = transaction.stock;

    notifyListeners();
  }

  /// Format double value for clean input (e.g., 27.65 -> "27,65")
  String _formatForInput(double value) {
    if (value == 0) return '';
    return value.toString().replaceAll('.', ',');
  }

  /// Reset form
  void resetForm() {
    nameController.clear();
    priceController.clear();
    quantityController.clear();
    noteController.clear();
    abbreviationController.clear();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    selectedStock = null;
    selectedType = TransactionType.buy;
    transactionToEdit = null;
    notifyListeners();
  }

  /// Para birimini sayısal değere dönüştüren yardımcı metot
  /// Clean format desteği: "27,65" -> 27.65, "1234,5678" -> 1234.5678
  double? parseCurrencyValue(String text, {bool allowZero = false}) {
    if (text.isEmpty) {
      return null;
    }

    try {
      // Temiz input format'ı: sadece sayı ve virgül/nokta
      String cleanText = text.trim();

      // Hem virgülü hem de noktayı destekle (input formatter nokta->virgül dönüştürür ama safety için)
      String parseableText = cleanText.replaceAll(',', '.');

      double value = double.parse(parseableText);

      // Sıfır kontrolü
      if (!allowZero && value <= 0) {
        return null;
      }

      return value;
    } catch (e) {
      return null;
    }
  }

  /// Save the transaction data
  Future<TransactionModel?> sendData(
    StockModel stock, {
    required BuildContext context,
    TransactionModel? existingTransaction,
  }) async {
    return await executeAsync<TransactionModel?>(() async {
      // Validation checks
      double? price = parseCurrencyValue(priceController.text);
      if (price == null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SuccessDialog(
            message:
                'Fiyat alanı geçerli bir değer olmalı ve sıfırdan büyük olmalı',
            icon: Icons.error_outline_rounded,
            backgroundColor: AppColors.error,
          ),
        );
        return null;
      }

      // Adet kontrolü
      int? quantity;
      try {
        quantity = int.tryParse(quantityController.text);
        if (quantity == null || quantity <= 0) {
          throw Exception();
        }
      } catch (e) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SuccessDialog(
            message:
                'Miktar alanı geçerli bir tam sayı olmalı ve sıfırdan büyük olmalı',
            icon: Icons.error_outline_rounded,
            backgroundColor: AppColors.error,
          ),
        );
        return null;
      }

      // Eğer düzenleme yapılıyorsa, mevcut işlemi güncelle
      final String transactionId = existingTransaction?.id ?? const Uuid().v4();

      // Create transaction with validated values
      final transaction = TransactionModel(
        id: transactionId,
        stockId: stock.id,
        stockName: stock.name,
        stock: stock,
        price: price,
        quantity: quantity,
        note: noteController.text,
        date: selectedDate,
        createDate: existingTransaction?.createDate ?? DateTime.now(),
        type: selectedType,
      );

      // Save to database
      if (existingTransaction != null) {
        await _transactionService.update(transaction);
      } else {
        await _transactionService.save(transaction);
      }

      // Update stocks after transaction is added
      await loadStocks();

      // Notify StockDetailsViewModel to refresh transactions
      Provider.of<StockDetailsViewModel>(context, listen: false)
          .fetchTransactions(stock.id);

      Provider.of<HomeViewModel>(context, listen: false)
          .fetchStocksWithTransactions();

      // Başarılı işlem dialogu göster
      if (context.mounted) {
        // İşlem türüne göre (Alım/Satım) ve işlem moduna göre (Ekleme/Güncelleme) mesaj oluştur
        String actionText =
            selectedType == TransactionType.buy ? "alındı" : "satıldı";
        if (existingTransaction != null) {
          actionText = "güncellendi";
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SuccessDialog(
            message: existingTransaction != null
                ? '${stock.name} işlemi başarıyla güncellendi!'
                : '$quantity adet ${stock.name} hissesi başarıyla $actionText!',
            icon: Icons.check_circle_outline_rounded,
            backgroundColor: AppColors.dividendGreen,
            iconColor: Colors.white,
            duration: const Duration(seconds: 2),
          ),
        );

        // Wait for the dialog to be shown
        Future.delayed(const Duration(milliseconds: 2500), () async {
          // Return to the previous screen
          NavigationService.instance.goBack();
        });
      }

      // Clear fields after saving
      nameController.clear();
      priceController.clear();
      quantityController.clear();
      noteController.clear();
      abbreviationController.clear();

      // Reset date
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
      _stockId = null;

      return transaction;
    },
        errorPrefix: existingTransaction != null
            ? "Failed to update transaction"
            : "Failed to save transaction");
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    noteController.dispose();
    abbreviationController.dispose();
    super.dispose();
  }
}
