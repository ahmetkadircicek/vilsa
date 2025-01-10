import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:vilsa/features/add_transaction/viewmodel/add_transaction_view_model.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';
import 'package:vilsa/features/main/viewmodel/main_view_model.dart';
import 'package:vilsa/features/portfolio/viewmodel/portfolio_view.dart.dart';
import 'package:vilsa/features/stock/viewmodel/stock_view_model.dart';
import 'package:vilsa/features/stock_details/viewmodel/stock_details_view_model.dart';

class ProviderManager {
  static ProviderManager? _instance;
  static ProviderManager get instance {
    _instance ??= ProviderManager._init();
    return _instance!;
  }

  ProviderManager._init();

  List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (context) => MainViewModel()),
    ChangeNotifierProvider(create: (context) => AddTransactionViewModel()),
    ChangeNotifierProvider(create: (context) => HomeViewModel()),
    ChangeNotifierProvider(create: (context) => StockViewModel()),
    ChangeNotifierProvider(create: (context) => StockDetailsViewModel()),
    ChangeNotifierProvider(create: (context) => PortfolioViewModel()),
  ];
}
