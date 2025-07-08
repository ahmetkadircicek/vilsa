import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_formatter.dart';
import 'package:vilsa/core/init/network/debounce_service.dart';
import 'package:vilsa/features/add_stock/view/add_stock_view.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';
import 'package:vilsa/features/home/widget/chart_section_widget.dart';
import 'package:vilsa/features/home/widget/date_range_picker_widget.dart';
import 'package:vilsa/features/home/widget/shares_section_widget.dart';
import 'package:vilsa/features/stock/viewmodel/stock_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer2<HomeViewModel, StockViewModel>(
        builder: (context, homeViewModel, stockViewModel, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceSection(context, homeViewModel),
                  _bodySection(context, homeViewModel, stockViewModel),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DebounceService().execute(
            'add_stock_fab',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddStockView(),
              ),
            ),
          );
        },
        backgroundColor: context.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _bodySection(BuildContext context, HomeViewModel homeViewModel,
      StockViewModel stockViewModel) {
    return Padding(
      padding: PaddingConstants.pagePadding,
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateRangePickerWidget(),
          ChartSectionWidget(),
          SharesSectionWidget(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.primary,
      title: const Highlight(text: 'Anasayfa', color: AppColors.white),
    );
  }

  Widget _buildBalanceSection(BuildContext context, HomeViewModel viewModel) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: context.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: GeneralConstants.instance.borderRadius.bottomLeft,
          bottomRight: GeneralConstants.instance.borderRadius.bottomRight,
        ),
      ),
      padding: PaddingConstants.symmetricHorizontalMedium +
          PaddingConstants.onlyBottomLarge,
      child: _buildBalanceInfo(context, viewModel),
    );
  }

  Widget _buildBalanceInfo(BuildContext context, HomeViewModel viewModel) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label(text: 'Toplam Bakiye', color: context.onPrimary),
            Headline(
                text: viewModel.totalBalance.toPrice(),
                isBold: true,
                color: context.onPrimary),
            Label(
              text: 'Toplam Temettü: ${viewModel.totalDividends.toPrice()}',
              color: context.onPrimary.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}
