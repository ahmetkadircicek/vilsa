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
import 'package:vilsa/features/add_stock/model/stock_model.dart';
import 'package:vilsa/features/add_transaction/viewmodel/add_transaction_view_model.dart';

class AddTransactionView extends StatelessWidget {
  final StockModel stock;
  const AddTransactionView({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<AddTransactionViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: _buildAddForm(viewModel, context),
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
        },
      ),
      title: const Highlight(text: 'Ekle', color: Colors.white),
    );
  }

  Widget _buildAddForm(AddTransactionViewModel viewModel, BuildContext context) {
    return Column(
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
              _buildNoteField(viewModel, context),
            ],
          ),
        ),
        Spacer(),
        _buildButton(context, viewModel),
      ],
    );
  }

  Widget _buildButton(BuildContext context, AddTransactionViewModel viewModel) {
    return Padding(
      padding: PaddingConstants.symmetricHorizontalMedium + PaddingConstants.onlyBottomMedium,
      child: GeneralButton(
        onPressed: () {
          if (viewModel.priceController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Content(
                  text: 'Lütfen fiyat alanını doldurun!',
                  isBold: true,
                  isCentred: true,
                ),
              ),
            );
            return;
          }

          if (viewModel.quantityController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Content(
                  text: 'Lütfen adet alanını doldurun!',
                  isBold: true,
                  isCentred: true,
                ),
              ),
            );
            return;
          }

          if (viewModel.selectedDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Content(
                  text: 'Lütfen tarih seçin!',
                  isBold: true,
                  isCentred: true,
                ),
              ),
            );
            return;
          }
          viewModel.sendData(stock);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: context.primary,
              content: Content(
                text: 'İşlem güncellendi!',
                isBold: true,
                isCentred: true,
              ),
            ),
          );

          Navigator.pop(context);
        },
        text: 'Ekle',
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
                  text: stock.name,
                  color: context.surface,
                  isBold: true,
                  overflow: true,
                ),
                Label(
                  text: stock.abbreviation,
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
        border: Border.all(color: context.secondary.withOpacity(0.2)),
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
                color: context.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(viewModel.selectedDate ?? DateTime.now()),
                    style: TextStyle(
                      fontSize: 14,
                      color: context.onSurface,
                    ),
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
      initialDate: viewModel.selectedDate ?? DateTime.now(),
    );

    if (newDate != null) {
      viewModel.setSelectedDate(newDate);
    }
  }

  Widget _buildPriceField(AddTransactionViewModel viewModel, BuildContext context) {
    return TextField(
      inputFormatters: [CurrencyInputFormatter()],
      controller: viewModel.priceController,
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
// Updated on 2025-01-10 - correct sorting algorithm
// Updated on 2025-02-02 - enhance performance of list rendering
// Updated on 2025-02-14 - add stock detail screen
// Updated on 2025-02-21 - implement sorting options
// Updated on 2025-03-05 - implement filtering options
