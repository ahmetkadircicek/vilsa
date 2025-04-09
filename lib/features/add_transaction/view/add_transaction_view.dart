import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/general_button.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_input_formatter.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/add_transaction/viewmodel/add_transaction_view_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

class AddTransactionView extends StatefulWidget {
  final StockModel stock;
  final TransactionModel? transaction;

  const AddTransactionView({
    super.key,
    required this.stock,
    this.transaction,
  });

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  late AddTransactionViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<AddTransactionViewModel>(context, listen: false);

    // Eğer düzenleme modundaysak form alanlarını doldur
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      viewModel.priceController.text = transaction.price.toString();
      viewModel.quantityController.text = transaction.quantity.toString();
      viewModel.dividendsController.text = transaction.dividends > 0 ? transaction.dividends.toString() : '';
      viewModel.noteController.text = transaction.note;

      // Build tamamlandıktan sonra setSelectedDate çağrılsın
      Future.microtask(() {
        viewModel.setSelectedDate(transaction.date);
      });

      viewModel.stockId = transaction.stockId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<AddTransactionViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(child: SingleChildScrollView(child: _buildAddForm(viewModel, context))),
                _buildButton(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.primary,
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: context.onPrimary),
        onPressed: () {
          Navigator.pop(context);
          viewModel.resetForm();
        },
      ),
      title: Highlight(text: widget.transaction != null ? 'Düzenle' : 'Ekle', color: Colors.white),
    );
  }

  Widget _buildAddForm(AddTransactionViewModel viewModel, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBalanceSection(context),
          Padding(
            padding: PaddingConstants.symmetricHorizontalMedium + PaddingConstants.onlyTopMedium,
            child: Column(
              spacing: 16,
              children: [
                _buildDateRangePicker(context, viewModel),
                _buildPriceField(viewModel, context),
                _buildQuantityField(viewModel, context),
                _buildDividendsField(viewModel, context),
                _buildNoteField(viewModel, context),
              ],
            ),
          ),
          // Button için boş alan bırak
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, AddTransactionViewModel viewModel) {
    return Container(
      color: context.onPrimary,
      padding: PaddingConstants.symmetricHorizontalMedium +
          PaddingConstants.onlyBottomMedium +
          PaddingConstants.onlyTopSmall,
      child: GeneralButton(
        onPressed: () async {
          final transaction = await viewModel.sendData(
            widget.stock,
            context: context,
            existingTransaction: widget.transaction,
          );

          // İşlem başarılı olduğunda sayfadan çıkma işlemi viewModel içinde yapılıyor
          // Dialog gösterilip otomatik kapandıktan sonra
        },
        text: widget.transaction != null ? 'Güncelle' : 'Ekle',
        textColor: context.onPrimary,
        backgroundColor: context.primary,
      ),
    );
  }

  Widget _buildBalanceSection(BuildContext context) {
    return Container(
      width: context.width,
      decoration: BoxDecoration(
        color: context.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: GeneralConstants.instance.borderRadius.bottomLeft,
          bottomRight: GeneralConstants.instance.borderRadius.bottomRight,
        ),
      ),
      padding: PaddingConstants.symmetricHorizontalMedium + PaddingConstants.onlyBottomLarge,
      child: Column(
        spacing: 24,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMarketItem(context),
        ],
      ),
    );
  }

  Widget _buildMarketItem(BuildContext context) {
    return Container(
      margin: PaddingConstants.onlyBottomSmall,
      decoration: BoxDecoration(
        borderRadius: GeneralConstants.instance.borderRadius,
        color: context.onSurface.withValues(alpha: 0.1),
      ),
      padding: PaddingConstants.allSmall,
      child: Row(
        spacing: 8,
        children: [
          CircleAvatar(
            backgroundColor: context.secondary.withValues(alpha: 0.3),
            child: Icon(Icons.wallet, color: context.onSecondary, size: 30),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Helper(
                  text: widget.stock.name,
                  color: context.surface,
                  isBold: true,
                  overflow: true,
                ),
                Label(
                  text: widget.stock.abbreviation,
                  overflow: true,
                  color: context.surface.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, AddTransactionViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: GeneralConstants.instance.borderRadius,
        border: Border.all(color: context.secondary.withValues(alpha: 0.2)),
      ),
      padding: PaddingConstants.allSmall,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Label(text: 'İşlem Tarihi:'),
          GestureDetector(
            onTap: () => _selectDate(context, viewModel),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Content(
                    text: DateFormat('dd/MM/yyyy').format(viewModel.selectedDate),
                    color: context.onSurface,
                    fontSize: 14,
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.calendar_today, size: 16, color: context.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, AddTransactionViewModel viewModel) async {
    final newDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: viewModel.selectedDate,
    );

    if (newDate != null) {
      viewModel.setSelectedDate(newDate);
    }
  }

  Widget _buildPriceField(AddTransactionViewModel viewModel, BuildContext context) {
    return TextField(
      inputFormatters: [CurrencyInputFormatter()],
      controller: viewModel.priceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Alış fiyatını girin',
        hintStyle: GoogleFonts.montserrat(
          letterSpacing: 1,
        ),
        filled: true,
        fillColor: context.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: GeneralConstants.instance.borderRadius,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildQuantityField(AddTransactionViewModel viewModel, BuildContext context) {
    return TextField(
      controller: viewModel.quantityController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Adet girin',
        hintStyle: GoogleFonts.montserrat(
          letterSpacing: 1,
        ),
        filled: true,
        fillColor: context.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: GeneralConstants.instance.borderRadius,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDividendsField(AddTransactionViewModel viewModel, BuildContext context) {
    return TextField(
      inputFormatters: [CurrencyInputFormatter()],
      controller: viewModel.dividendsController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Temettü tutarını girin (opsiyonel)',
        hintStyle: GoogleFonts.montserrat(
          letterSpacing: 1,
        ),
        filled: true,
        fillColor: context.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: GeneralConstants.instance.borderRadius,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildNoteField(AddTransactionViewModel viewModel, BuildContext context) {
    return TextField(
      controller: viewModel.noteController,
      decoration: InputDecoration(
        hintText: 'Bir not ekleyin',
        hintStyle: GoogleFonts.montserrat(
          letterSpacing: 1,
        ),
        filled: true,
        fillColor: context.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: GeneralConstants.instance.borderRadius,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
