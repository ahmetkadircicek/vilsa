import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/init/navigation/navigation_service.dart';
import 'package:vilsa/features/home/view/home_view.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';
import 'package:vilsa/features/portfolio/viewmodel/portfolio_view.dart.dart';
import 'package:vilsa/features/stock/viewmodel/stock_view_model.dart';

class SplashViewModel extends ChangeNotifier {
  SplashViewModel();

  Future<void> checkConnectivityAndPreloadData(BuildContext context) async {
    // Fetching the data
    await _fetchData(context);

    // Delaying the navigation
    await Future.delayed(const Duration(milliseconds: 2500));

    // Navigating to the home view
    NavigationService.instance.replace(const HomeView());
  }

  Future<void> _fetchData(BuildContext context) async {
    // Fetching the stocks with transactions
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    await homeViewModel.fetchStocksWithTransactions();

    // Fetching the stocks
    final portfolioViewModel =
        Provider.of<PortfolioViewModel>(context, listen: false);
    await portfolioViewModel.fetchStocks();

    // Fetching the stocks
    final stockViewModel = Provider.of<StockViewModel>(context, listen: false);
    await stockViewModel.fetchStocks();
  }
}
