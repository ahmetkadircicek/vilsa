import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/section_container.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';
import 'package:vilsa/core/enums/stock_filter_type_enum.dart';
import 'package:vilsa/core/enums/stock_sort_type_enum.dart';
import 'package:vilsa/features/portfolio/view/portfolio_view.dart';
import 'package:vilsa/features/portfolio/viewmodel/portfolio_view.dart.dart';

class SharesSectionWidget extends StatelessWidget {
  const SharesSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PortfolioViewModel>.value(
          value: Provider.of<PortfolioViewModel>(context, listen: false),
        ),
      ],
      child: SectionContainer(
        title: Expanded(
          child: TextField(
            controller: viewModel.searchController,
            decoration: InputDecoration(
              filled: false,
              prefixIcon: Icon(Icons.search_rounded),
              prefixIconColor: context.primary,
              prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 0),
              hintText: 'Hisse Adı Girin',
              hintStyle: TextStyle(color: context.primary),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              alignLabelWithHint: true,
            ),
          ),
        ),
        trailing: PopupMenuButton<dynamic>(
          icon: Icon(
            Icons.filter_list_rounded,
            color: viewModel.stockFilterType != StockFilterTypeEnum.all ||
                    viewModel.stockSortType != StockSortTypeEnum.alphabetical
                ? context.primary
                : context.onSurface.withValues(alpha: 0.5),
          ),
          onSelected: (value) {
            if (value is StockFilterTypeEnum) {
              viewModel.setStockFilterType(value);
            } else if (value is StockSortTypeEnum) {
              viewModel.setStockSortType(value);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: StockFilterTypeEnum.all,
              child: Row(
                children: [
                  Icon(
                    Icons.list_rounded,
                    color: viewModel.stockFilterType == StockFilterTypeEnum.all ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('Tüm Hisseler'),
                ],
              ),
            ),
            PopupMenuItem(
              value: StockFilterTypeEnum.traded,
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color:
                        viewModel.stockFilterType == StockFilterTypeEnum.traded ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('İşlem Yapılanlar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: StockFilterTypeEnum.untraded,
              child: Row(
                children: [
                  Icon(
                    Icons.trending_down_rounded,
                    color:
                        viewModel.stockFilterType == StockFilterTypeEnum.untraded ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('İşlem Yapılmayanlar'),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: StockSortTypeEnum.alphabetical,
              child: Row(
                children: [
                  Icon(
                    Icons.sort_by_alpha_rounded,
                    color:
                        viewModel.stockSortType == StockSortTypeEnum.alphabetical ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('Alfabetik Sırala'),
                ],
              ),
            ),
            PopupMenuItem(
              value: StockSortTypeEnum.quantity,
              child: Row(
                children: [
                  Icon(
                    Icons.numbers_rounded,
                    color: viewModel.stockSortType == StockSortTypeEnum.quantity ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('Adete Göre Sırala'),
                ],
              ),
            ),
            PopupMenuItem(
              value: StockSortTypeEnum.totalValue,
              child: Row(
                children: [
                  Icon(
                    Icons.attach_money_rounded,
                    color:
                        viewModel.stockSortType == StockSortTypeEnum.totalValue ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('Toplam Değere Göre Sırala'),
                ],
              ),
            ),
            PopupMenuItem(
              value: StockSortTypeEnum.averagePrice,
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    color:
                        viewModel.stockSortType == StockSortTypeEnum.averagePrice ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('Ortalama Fiyata Göre Sırala'),
                ],
              ),
            ),
          ],
        ),
        content: const PortfolioView(),
        contentPadding: EdgeInsets.zero,
        headerColor: context.primary.withValues(alpha: 0.1),
      ),
    );
  }
}
