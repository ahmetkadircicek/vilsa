import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/custom_date_picker.dart';
import 'package:vilsa/core/components/general_button.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/components/section_container.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_input_formatter.dart';
import 'package:vilsa/core/init/network/debounce_service.dart';
import 'package:vilsa/features/add_dividend/viewmodel/add_dividend_view_model.dart';
import 'package:vilsa/features/stock/model/dividend_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';

class AddDividendView extends StatefulWidget {
  final StockModel stock;
  final DividendModel? dividend; // For editing existing dividends

  const AddDividendView({
    super.key,
    required this.stock,
    this.dividend,
  });

  @override
  State<AddDividendView> createState() => _AddDividendViewState();
}

class _AddDividendViewState extends State<AddDividendView> {
  late AddDividendViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<AddDividendViewModel>(context, listen: false);

    // If editing, load the dividend data
    if (widget.dividend != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.setDividendToEdit(widget.dividend!);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.resetForm();
        viewModel.initializeForStock(widget.stock.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      appBar: _buildAppBar(context),
      body: Consumer<AddDividendViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: PaddingConstants.pagePadding,
                    child: Column(
                      spacing: 16,
                      children: [
                        _buildStockInfoSection(),
                        _buildDateSection(context, viewModel),
                        _buildLotStatusSection(viewModel),
                        _buildDividendInputSection(viewModel, context),
                        _buildCalculationSection(viewModel),
                        _buildNoteSection(viewModel, context),
                        const SizedBox(height: 80), // Space for button
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomButton(context, viewModel),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.primary,
      title: Highlight(
        text: widget.dividend != null ? 'Temettü Düzenle' : 'Temettü Ekle',
        color: AppColors.white,
      ),
      leading: IconButton(
        onPressed: () {
          DebounceService().execute(
            'back_button',
            () => Navigator.pop(context),
          );
        },
        icon: const Icon(Icons.chevron_left, color: AppColors.white),
      ),
      elevation: 0,
    );
  }

  Widget _buildStockInfoSection() {
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

  Widget _buildDateSection(
      BuildContext context, AddDividendViewModel viewModel) {
    return SectionContainer(
      title: Label(
        text: "Tarih Seçimi",
        isBold: true,
        fontSize: 14,
        color: context.primary,
      ),
      content: CustomDatePicker(
        title: 'Temettü Tarihi',
        selectedDate: viewModel.selectedDate,
        onDateSelected: (date) => viewModel.setSelectedDate(date),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      ),
    );
  }

  Widget _buildLotStatusSection(AddDividendViewModel viewModel) {
    final hasLots = viewModel.currentLotCount > 0;

    return SectionContainer(
      title: Label(
        text: "Lot Durumu",
        isBold: true,
        fontSize: 14,
        color: context.primary,
      ),
      headerColor: hasLots
          ? AppColors.dividendGreen.withValues(alpha: 0.1)
          : AppColors.error.withValues(alpha: 0.1),
      borderColor: hasLots
          ? AppColors.dividendGreen.withValues(alpha: 0.3)
          : AppColors.error.withValues(alpha: 0.3),
      content: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasLots
                  ? AppColors.dividendGreen.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasLots ? Icons.check_circle : Icons.warning_amber_rounded,
              color: hasLots ? AppColors.dividendGreen : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Helper(
                  text: hasLots
                      ? '${viewModel.currentLotCount} Lot Mevcut'
                      : 'Lot Bulunamadı',
                  isBold: true,
                  color: hasLots ? AppColors.dividendGreen : AppColors.error,
                ),
                const SizedBox(height: 4),
                Content(
                  text: hasLots
                      ? 'Bu tarihe kadar ${viewModel.currentLotCount} lot hisseniz bulunuyor'
                      : 'Bu tarihe kadar hiç lot işleminiz bulunmuyor. Önce hisse alımı yapmalısınız.',
                  color: context.onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDividendInputSection(
      AddDividendViewModel viewModel, BuildContext context) {
    return SectionContainer(
      title: Label(
        text: "Temettü Bilgileri",
        isBold: true,
        fontSize: 14,
        color: context.primary,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(
            text: 'Hisse Başına Temettü Tutarı',
            color: context.onSurface.withValues(alpha: 0.8),
            fontSize: 12,
          ),
          const SizedBox(height: 8),
          TextField(
            inputFormatters: [PriceInputFormatter()],
            controller: viewModel.perShareAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0,5000 veya 2,75',
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
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationSection(AddDividendViewModel viewModel) {
    final totalAmount = viewModel.totalDividendAmount;
    final perShareAmount =
        viewModel.parseCurrencyValue(viewModel.perShareAmountController.text) ??
            0.0;

    return SectionContainer(
      title: Label(
        text: "Hesaplama",
        isBold: true,
        fontSize: 14,
        color: context.primary,
      ),
      headerColor: AppColors.dividendGreen.withValues(alpha: 0.1),
      borderColor: AppColors.dividendGreen.withValues(alpha: 0.3),
      content: Column(
        children: [
          _buildCalculationRow(
              'Hisse Başına Tutar:', '₺${perShareAmount.toStringAsFixed(4)}'),
          const SizedBox(height: 8),
          _buildCalculationRow(
              'Toplam Lot Sayısı:', '${viewModel.currentLotCount}'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 1,
            color: context.secondary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          _buildCalculationRow(
            'Toplam Temettü:',
            '₺${totalAmount.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Label(
          text: label,
          color: context.onSurface.withValues(alpha: 0.8),
          isBold: isTotal,
          fontSize: isTotal ? 14 : 12,
        ),
        Helper(
          text: value,
          color: isTotal ? AppColors.dividendGreen : context.onSurface,
          isBold: true,
          fontSize: isTotal ? 16 : 14,
        ),
      ],
    );
  }

  Widget _buildNoteSection(
      AddDividendViewModel viewModel, BuildContext context) {
    return SectionContainer(
      title: Label(
        text: "Notlar",
        isBold: true,
        fontSize: 14,
        color: context.primary,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(
            text: 'Not (opsiyonel)',
            color: context.onSurface.withValues(alpha: 0.8),
            fontSize: 12,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: viewModel.noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Temettü ile ilgili notunuzu buraya yazabilirsiniz...',
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
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(
      BuildContext context, AddDividendViewModel viewModel) {
    return Container(
      width: double.infinity,
      color: context.surface,
      padding: PaddingConstants.symmetricHorizontalMedium +
          PaddingConstants.onlyBottomMedium +
          PaddingConstants.onlyTopSmall,
      child: GeneralButton(
        debounceKey: 'add_dividend_button',
        text: widget.dividend != null ? 'Temettü Güncelle' : 'Temettü Ekle',
        textColor: context.onPrimary,
        backgroundColor: context.primary,
        onPressed: () async {
          await viewModel.saveDividend(
            widget.stock,
            context: context,
            existingDividend: widget.dividend,
          );
        },
      ),
    );
  }
}
