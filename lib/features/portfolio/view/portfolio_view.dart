import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_formatter.dart';
import 'package:vilsa/core/init/navigation/navigation_service.dart';
import 'package:vilsa/features/add_stock/view/add_stock_view.dart';
import 'package:vilsa/features/portfolio/viewmodel/portfolio_view.dart.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';
import 'package:vilsa/features/stock_details/view/stock_details_view.dart';
import 'package:vilsa/features/stock_details/viewmodel/stock_details_view_model.dart';

class PortfolioView extends StatelessWidget {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return viewModel.stocks.isNotEmpty ? _buildStockList(context, viewModel) : const SizedBox.shrink();
      },
    );
  }

  Widget _buildStockList(BuildContext context, PortfolioViewModel viewModel) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.stocks.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return _buildStockItem(context, viewModel.stocks[index]);
      },
    );
  }

  Widget _buildStockItem(BuildContext context, StockModel stock) {
    // Calculate average price and total value
    double averagePrice = 0.0;
    int totalQuantity = 0;
    double totalValue = 0.0;

    if (stock.transactions.isNotEmpty) {
      double totalCost = 0.0;
      for (var transaction in stock.transactions) {
        totalCost += transaction.price * transaction.quantity;
        totalQuantity += transaction.quantity;
      }

      if (totalQuantity > 0) {
        averagePrice = totalCost / totalQuantity;
        totalValue = averagePrice * totalQuantity;
      }
    }

    return Padding(
      padding: PaddingConstants.onlyBottomSmall,
      child: GestureDetector(
        onTap: () async {
          await Provider.of<StockDetailsViewModel>(context, listen: false).fetchTransactions(stock.id);
          NavigationService.instance.navigateTo(StockDetailsView(stock: stock));
        },
        child: Slidable(
          key: Key(stock.id),
          endActionPane: _buildSlidableActions(context, stock),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: GeneralConstants.instance.borderRadius,
              color: context.surfaceContainer,
              border: Border.all(color: context.secondary.withValues(alpha: 0.3)),
            ),
            padding: PaddingConstants.allSmall,
            child: Column(
              children: [
                Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: context.primary.withValues(alpha: 0.2),
                      child: _getStockIcon(context, 'stock'),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Helper(
                            text: stock.name,
                            overflow: true,
                            isBold: true,
                          ),
                          Label(
                            text: stock.abbreviation,
                            overflow: true,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ),
                    if (totalQuantity > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Helper(
                            text: averagePrice.toPrice(),
                            color: context.onSurface,
                            overflow: true,
                            isBold: true,
                          ),
                          Label(
                            text: 'Toplam: ${totalValue.toPrice()}',
                            color: context.onSurface.withValues(alpha: 0.7),
                            overflow: true,
                          ),
                          Label(
                            text: 'Adet: $totalQuantity',
                            color: context.onSurface.withValues(alpha: 0.5),
                            overflow: true,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    Icon(Icons.chevron_right, color: context.secondary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ActionPane _buildSlidableActions(BuildContext context, StockModel stock) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          onPressed: (context) => _onPressedEdit(context, stock),
          backgroundColor: context.primary,
          foregroundColor: Colors.white,
          icon: Icons.edit,
        ),
        SlidableAction(
          onPressed: (context) => _onPressedDelete(context, stock),
          backgroundColor: context.error,
          foregroundColor: Colors.white,
          icon: Icons.delete,
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
        ),
      ],
    );
  }

  void _onPressedEdit(BuildContext context, StockModel stock) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddStockView(
          stock: stock,
        ),
      ),
    );
  }

  void _onPressedDelete(BuildContext context, StockModel stock) {
    context.read<PortfolioViewModel>().removeStock(stock.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(
          '${stock.name} silindi',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _getStockIcon(BuildContext context, String type) {
    switch (type) {
      case 'cash':
        return Icon(Icons.currency_exchange, color: context.primary, size: 30);
      case 'gold':
        return Icon(Icons.adjust, color: context.primary, size: 30);
      case 'stock':
        return Icon(Icons.pages, color: context.primary, size: 30);
      default:
        return Icon(Icons.pages, color: context.primary, size: 30);
    }
  }
}
// Updated on 2025-01-03 - create settings page
// Updated on 2025-01-08 - resolve authentication token expiry
// Updated on 2025-01-21 - enhance visual hierarchy
// Updated on 2025-01-29 - refine animation transitions
// Updated on 2025-02-10 - enhance performance of list rendering
// Updated on 2025-02-20 - add navigation structure
// Updated on 2025-02-21 - implement login screen UI
// Updated on 2025-03-03 - update icon designs
// Updated on 2025-03-04 - add user preferences storage
// Updated on 2025-03-06 - update navigation menu styling
// Updated on 2025-03-11 - enhance performance of list rendering
// Updated on 2025-03-20 - add search functionality
// Updated on 2025-03-22 - correct data loading problems
