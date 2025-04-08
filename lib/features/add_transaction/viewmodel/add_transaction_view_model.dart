import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vilsa/core/base/base_view_model.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/components/success_dialog.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/init/event/event_bus.dart';
import 'package:vilsa/core/init/event/event_type_enum.dart';
import 'package:vilsa/core/init/network/stock_service.dart';
import 'package:vilsa/core/init/network/transaction_service.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

/// ViewModel for adding or editing transactions
class AddTransactionViewModel extends BaseViewModel {
  final TransactionService _transactionService = TransactionService.instance;
  final StockService _stockService = StockService.instance;
  final EventBus _eventBus = EventBus.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController abbreviationController = TextEditingController();
  final TextEditingController dividendsController = TextEditingController();
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
    priceController.text = transaction.price.toString();
    quantityController.text = transaction.quantity.toString();
    dividendsController.text = transaction.dividends.toString();
    noteController.text = transaction.note;
    selectedDate = transaction.date;
    selectedTime = TimeOfDay.fromDateTime(transaction.date);
    selectedType = transaction.type;
    selectedStock = transaction.stock;

    notifyListeners();
  }

  /// Reset form
  void resetForm() {
    nameController.clear();
    priceController.clear();
    quantityController.clear();
    noteController.clear();
    abbreviationController.clear();
    dividendsController.clear();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    selectedStock = null;
    selectedType = TransactionType.buy;
    transactionToEdit = null;
    notifyListeners();
  }

  /// Para birimini sayısal değere dönüştüren yardımcı metot
  /// "₺1.234,56" gibi formatlı bir string'i 1234.56 double değerine dönüştürür
  double? parseCurrencyValue(String text, {bool allowZero = false}) {
    if (text.isEmpty) {
      return null;
    }

    try {
      // Para birimi sembolünü ve binlik ayırıcılarını kaldır
      String parsedText = text
          .replaceAll('₺', '') // TL sembolünü kaldır
          .replaceAll('.', '') // Binlik ayraçları kaldır
          .trim() // Boşlukları kaldır
          .replaceAll(',', '.'); // Virgülü nokta ile değiştir (ondalık ayırıcı)

      double value = double.parse(parsedText);

      // Sıfır kontrolü
      if (!allowZero && value <= 0) {
        return null;
      }

      return value;
    } catch (e) {
      debugPrint("Currency parsing error: $e for value '$text'");
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
            message: 'Fiyat alanı geçerli bir değer olmalı ve sıfırdan büyük olmalı',
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
            message: 'Miktar alanı geçerli bir tam sayı olmalı ve sıfırdan büyük olmalı',
            icon: Icons.error_outline_rounded,
            backgroundColor: AppColors.error,
          ),
        );
        return null;
      }

      // Temettü alanını kontrol et (isteğe bağlı)
      double dividends = 0.0;
      if (dividendsController.text.isNotEmpty) {
        double? parsedDividends = parseCurrencyValue(dividendsController.text, allowZero: true);
        if (parsedDividends == null || parsedDividends < 0) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SuccessDialog(
              message: 'Temettü alanı geçerli bir değer olmalı ve negatif olmamalı',
              icon: Icons.error_outline_rounded,
              backgroundColor: AppColors.error,
            ),
          );
          return null;
        }
        dividends = parsedDividends;
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
        dividends: dividends,
        type: selectedType,
      );

      // Log the transaction data before saving
      final isUpdate = existingTransaction != null;
      debugPrint(
          "${isUpdate ? '🔄 Updating' : '💹 Creating'} transaction: ID=${transaction.id}, Stock=${stock.name}, Price=$price, Quantity=$quantity, Dividends=$dividends");

      // Save to database
      if (isUpdate) {
        await _transactionService.update(transaction);

        // İşlem güncellendi olayını yayınla
        _eventBus.fireEvent(EventType.transactionUpdated, data: transaction);
      } else {
        await _transactionService.save(transaction);

        // İşlem eklendi olayını yayınla
        _eventBus.fireEvent(EventType.transactionAdded, data: transaction);
      }

      // Başarılı işlem dialogu göster
      if (context.mounted) {
        // İşlem türüne göre (Alım/Satım) ve işlem moduna göre (Ekleme/Güncelleme) mesaj oluştur
        String actionText = selectedType == TransactionType.buy ? "alındı" : "satıldı";
        if (isUpdate) {
          actionText = "güncellendi";
        }

        print("Dialog gösteriliyor: isUpdate=$isUpdate, stock=${stock.name}, stockId=${stock.id}");

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SuccessDialog(
            message: isUpdate
                ? '${stock.name} işlemi başarıyla güncellendi!'
                : '$quantity adet ${stock.name} hissesi başarıyla $actionText!',
            icon: Icons.check_circle_outline_rounded,
            backgroundColor: AppColors.dividendGreen,
            iconColor: Colors.white,
            duration: const Duration(seconds: 2),
          ),
        );

        // Dialog gösterdikten sonra bekleme süresi
        Future.delayed(const Duration(milliseconds: 2500), () {
          print("İşlem tamamlandı, ekran kapatılıyor");

          // Context hala geçerli mi kontrol et
          if (context.mounted) {
            // Ana ekrana dön
            Navigator.of(context).pop();
          }
        });
      }

      // Clear fields after saving
      nameController.clear();
      priceController.clear();
      quantityController.clear();
      noteController.clear();
      abbreviationController.clear();
      dividendsController.clear();

      // Reset date
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
      _stockId = null;

      return transaction;
    }, errorPrefix: existingTransaction != null ? "Failed to update transaction" : "Failed to save transaction");
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    noteController.dispose();
    abbreviationController.dispose();
    dividendsController.dispose();
    super.dispose();
  }
}
