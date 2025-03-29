import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/init/navigation/navigation_service.dart';
import 'package:vilsa/features/add_stock/view/add_stock_view.dart'; // Added import for AddStockView
import 'package:vilsa/features/add_transaction/view/add_transaction_view.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';
import 'package:vilsa/features/stock/viewmodel/stock_view_model.dart';

class StockView extends StatelessWidget {
  const StockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<StockViewModel>(
        builder: (context, viewModel, child) {
          return _buildStockList(viewModel);
        },
      ),
    );
  }

  Widget _buildStockList(StockViewModel viewModel) {
    return Padding(
      padding: PaddingConstants.pagePadding,
      child: ListView.builder(
        itemCount: viewModel.stocks.length,
        itemBuilder: (context, index) {
          return _buildGeneralListTile(context, viewModel.stocks[index]);
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.primary,
      actions: [
        IconButton(
          icon: Icon(Icons.add, color: context.onPrimary),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddStockView()),
            );
          },
        ),
      ],
      title: const Highlight(text: 'Hisseler', color: Colors.white),
    );
  }

  Widget _buildGeneralListTile(BuildContext context, StockModel stock) {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.navigateTo(AddTransactionView(stock: stock));
      },
      child: Container(
        margin: PaddingConstants.onlyBottomSmall,
        padding: PaddingConstants.allSmall,
        decoration: BoxDecoration(
          borderRadius: GeneralConstants.instance.borderRadius,
          color: context.surfaceContainer,
          border: Border.all(color: context.secondary.withValues(alpha: 0.3)),
        ),
        child: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: context.primary.withValues(alpha: 0.2),
              child: Icon(Icons.wallet, color: context.primary),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Helper(
                    text: stock.name,
                    color: context.onSurface,
                    overflow: true,
                  ),
                  Label(
                    text: stock.abbreviation,
                    color: context.onSurface.withValues(alpha: 0.6),
                    overflow: true,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.secondary),
          ],
        ),
      ),
    );
  }
}
// Updated on 2025-01-24 - fix API response handling
// Updated on 2025-01-30 - fix layout on smaller screens
// Updated on 2025-02-03 - enhance performance of list rendering
// Updated on 2025-02-06 - implement dark mode support
// Updated on 2025-02-07 - enhance component reusability
// Updated on 2025-02-08 - implement dark mode support
// Updated on 2025-03-14 - resolve authentication token expiry
