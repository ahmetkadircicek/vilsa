import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/custom_date_picker.dart';
import 'package:vilsa/core/components/general_button.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/components/section_container.dart'
    show SectionContainer;
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.setTransactionToEdit(widget.transaction!);
      });
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
                Expanded(
                    child: SingleChildScrollView(
                        child: _buildAddForm(viewModel, context))),
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
      title: Highlight(
          text: widget.transaction != null ? 'Düzenle' : 'Ekle',
          color: Colors.white),
    );
  }

  Widget _buildAddForm(
      AddTransactionViewModel viewModel, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: PaddingConstants.symmetricHorizontalMedium +
                PaddingConstants.onlyTopMedium,
            child: Column(
              spacing: 16,
              children: [
                _buildMarketItem(context),
                _buildDateRangePicker(context, viewModel),
                _buildPriceField(viewModel, context),
                _buildQuantityField(viewModel, context),
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
        debounceKey: 'add_transaction_button',
        onPressed: () async {
          await viewModel.sendData(
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

  Widget _buildMarketItem(BuildContext context) {
    return SectionContainer(
      title: Label(
        text: "Hisse Bilgileri",
        isBold: true,
        fontSize: 14,
        color: context.primary,
      ),
      content: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.trending_up,
              color: context.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Helper(
                  text: widget.stock.name,
                  isBold: true,
                  fontSize: 16,
                  color: context.onSurface,
                ),
                const SizedBox(height: 4),
                Label(
                  text: widget.stock.abbreviation,
                  color: context.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker(
      BuildContext context, AddTransactionViewModel viewModel) {
    return SectionContainer(
      title: Label(
        text: "Tarih Seçimi",
        isBold: true,
        fontSize: 14,
        color: context.primary,
      ),
      content: CustomDatePicker(
        title: 'İşlem Tarihi',
        selectedDate: viewModel.selectedDate,
        onDateSelected: (date) => viewModel.setSelectedDate(date),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      ),
    );
  }

  Widget _buildPriceField(
      AddTransactionViewModel viewModel, BuildContext context) {
    return TextField(
      inputFormatters: [PriceInputFormatter()],
      controller: viewModel.priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: '27,65 veya 127,4500',
        suffixText: '₺',
        suffixStyle: TextStyle(
          color: context.primary,
          fontWeight: FontWeight.bold,
        ),
        hintStyle: GoogleFonts.montserrat(
          letterSpacing: 1,
          color: Colors.grey.withOpacity(0.6),
        ),
        filled: true,
        fillColor: context.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: GeneralConstants.instance.borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: GeneralConstants.instance.borderRadius,
          borderSide: BorderSide(color: context.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildQuantityField(
      AddTransactionViewModel viewModel, BuildContext context) {
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

  Widget _buildNoteField(
      AddTransactionViewModel viewModel, BuildContext context) {
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
