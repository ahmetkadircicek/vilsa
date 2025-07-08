import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/confirm_dialog.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/components/success_dialog.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_formatter.dart';
import 'package:vilsa/core/init/navigation/navigation_service.dart';
import 'package:vilsa/core/init/network/debounce_service.dart';
import 'package:vilsa/features/add_stock/view/add_stock_view.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';
import 'package:vilsa/features/portfolio/viewmodel/portfolio_view.dart.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';
import 'package:vilsa/features/stock/viewmodel/stock_view_model.dart';
import 'package:vilsa/features/stock_details/view/stock_details_view.dart';
import 'package:vilsa/features/stock_details/viewmodel/stock_details_view_model.dart';

class PortfolioView extends StatefulWidget {
  const PortfolioView({super.key});

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimations = List.generate(10, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.05,
          0.5 + index * 0.05,
          curve: Curves.easeOut,
        ),
      ));
    });

    _slideAnimations = List.generate(10, (index) {
      return Tween<Offset>(
        begin: const Offset(0.2, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.05,
          0.5 + index * 0.05,
          curve: Curves.easeOut,
        ),
      ));
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Padding(
            padding: PaddingConstants.allLarge,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return viewModel.stocks.isNotEmpty
            ? _buildStockList(context, viewModel)
            : Center(
                child: Content(
                  text: 'Portföyünüzde hisse bulunmamaktadır.',
                  isCentred: true,
                ),
              );
      },
    );
  }

  Widget _buildStockList(BuildContext context, PortfolioViewModel viewModel) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: true);
    final stocks = homeViewModel.filteredStocks;

    if (stocks.isEmpty) {
      return _buildEmptyState(context, homeViewModel);
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: stocks.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimations[index % 10],
              child: SlideTransition(
                position: _slideAnimations[index % 10],
                child: _buildStockItem(context, stocks[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeViewModel homeViewModel) {
    String message;
    IconData icon;

    if (homeViewModel.searchController.text.isNotEmpty) {
      message =
          'Aradığınız "${homeViewModel.searchController.text}" hissesi bulunamadı.';
      icon = Icons.search_off;
    } else {
      switch (homeViewModel.stockFilterType.name) {
        case 'traded':
          message = 'İşlem yapılan hisse bulunmamaktadır.';
          icon = Icons.trending_down;
          break;
        case 'untraded':
          message = 'İşlem yapılmayan hisse bulunmamaktadır.';
          icon = Icons.trending_up;
          break;
        default:
          message = 'Portföyünüzde hisse bulunmamaktadır.';
          icon = Icons.pie_chart;
      }
    }

    return Padding(
      padding: PaddingConstants.allLarge,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Content(
              text: message,
              isCentred: true,
              color: Colors.grey[600],
            ),
            if (homeViewModel.searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  homeViewModel.searchController.clear();
                },
                child: Text(
                  'Aramayı Temizle',
                  style: TextStyle(color: context.primary),
                ),
              ),
            ],
          ],
        ),
      ),
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

    return GestureDetector(
      onTap: () {
        DebounceService().execute(
          'stock_details_${stock.id}',
          () async {
            await Provider.of<StockDetailsViewModel>(context, listen: false)
                .fetchTransactions(stock.id);
            NavigationService.instance
                .navigateTo(StockDetailsView(stock: stock));
          },
        );
      },
      child: Slidable(
        key: Key(stock.id),
        endActionPane: _buildSlidableActions(context, stock),
        child: Container(
          padding: PaddingConstants.allMedium,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.white,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: context.primary.withValues(alpha: 0.1),
                radius: 20,
                child: _getStockIcon(context, 'stock'),
              ),
              const SizedBox(width: 12),
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
                      fontSize: 12,
                      color: AppColors.black54,
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
                      fontSize: 12,
                    ),
                    Label(
                      text: 'Adet: $totalQuantity',
                      color: context.onSurface.withValues(alpha: 0.5),
                      overflow: true,
                      fontSize: 10,
                    ),
                  ],
                ),
              context.spacerWidthFixed(8),
              if (stock.transactions.isNotEmpty)
                Icon(
                  Icons.arrow_forward_ios,
                  color: context.onSurface.withValues(alpha: 0.1),
                ),
              if (stock.transactions.isEmpty)
                Icon(
                  Icons.add,
                  size: 30,
                  color: context.onSurface.withValues(alpha: 0.1),
                ),
            ],
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
          onPressed: (context) {
            DebounceService().execute(
              'edit_stock_${stock.id}',
              () => _onPressedEdit(context, stock),
            );
          },
          backgroundColor: context.primary,
          foregroundColor: AppColors.white,
          icon: Icons.edit,
        ),
        SlidableAction(
          onPressed: (context) {
            DebounceService().execute(
              'delete_stock_${stock.id}',
              () => _onPressedDelete(context, stock),
            );
          },
          backgroundColor: context.error,
          foregroundColor: AppColors.white,
          icon: Icons.delete,
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(8)),
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

  void _onPressedDelete(BuildContext context, StockModel stock) async {
    // Global context'i NavigationService üzerinden al - bu daha uzun ömürlü
    final globalContext =
        NavigationService.instance.navigatorKey.currentContext;

    // Silmeden önce ViewModel referanslarını al
    final portfolioViewModel =
        Provider.of<PortfolioViewModel>(context, listen: false);
    HomeViewModel? homeViewModel;
    StockViewModel? stockViewModel;

    try {
      homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    } catch (e) {
      print('HomeViewModel erişilemedi: $e');
    }

    // Onay dialogu göster
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'Hisse Silme',
        message: '${stock.name} hissesini silmek istediğinize emin misiniz?',
        confirmText: 'Sil',
        cancelText: 'İptal',
        icon: Icons.delete_forever_rounded,
      ),
    );

    if (confirm == true) {
      try {
        // Silme işlemini gerçekleştir
        await portfolioViewModel.removeStock(stock.id);

        // Silme işlemi başarılı oldu - şimdi güvenli şekilde UI'ı güncelle

        // Önce state'leri güncelle
        if (homeViewModel != null) {
          homeViewModel.fetchStocks();
          homeViewModel.refreshStocksList();
        }

        portfolioViewModel.refreshStocks();

        // Başarı mesajını göster - global context'i kullan
        if (globalContext != null && globalContext.mounted) {
          // Dialog dışında başka bir yöntemle bildirim göster
          showDialog(
            context: globalContext,
            barrierDismissible: false,
            builder: (context) => SuccessDialog(
              message: '${stock.name} hissesi başarıyla silindi!',
              backgroundColor: AppColors.dividendGreen,
              icon: Icons.delete_outline_rounded,
              iconColor: Colors.white,
            ),
          );
        }

        // Widget hala mount edilmiş mi kontrol et ve state'i güncelle
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        print('Hisse silme hatası: $e');

        // Hata bildirimini göster - global context kullan
        if (globalContext != null && globalContext.mounted) {
          showDialog(
            context: globalContext,
            barrierDismissible: false,
            builder: (context) => SuccessDialog(
              message: 'Hisse silinirken bir hata oluştu!',
              icon: Icons.error_outline_rounded,
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Widget _getStockIcon(BuildContext context, String type) {
    switch (type) {
      case 'cash':
        return Icon(Icons.currency_exchange, color: context.primary, size: 24);
      case 'gold':
        return Icon(Icons.adjust, color: context.primary, size: 24);
      case 'stock':
        return Icon(Icons.pages, color: context.primary, size: 24);
      default:
        return Icon(Icons.pages, color: context.primary, size: 24);
    }
  }
}
