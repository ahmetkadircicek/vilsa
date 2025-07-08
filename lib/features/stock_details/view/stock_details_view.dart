import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/confirm_dialog.dart';
import 'package:vilsa/core/components/custom_date_picker.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/components/section_container.dart';
import 'package:vilsa/core/components/success_dialog.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_formatter.dart';
import 'package:vilsa/core/init/network/debounce_service.dart';
import 'package:vilsa/features/add_dividend/view/add_dividend_view.dart';
import 'package:vilsa/features/add_stock/view/add_stock_view.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/add_transaction/view/add_transaction_view.dart';
import 'package:vilsa/features/stock/model/dividend_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';
import 'package:vilsa/features/stock_details/viewmodel/stock_details_view_model.dart';

class StockDetailsView extends StatefulWidget {
  final StockModel stock;
  const StockDetailsView({super.key, required this.stock});

  @override
  State<StockDetailsView> createState() => _StockDetailsViewState();
}

class _StockDetailsViewState extends State<StockDetailsView> {
  late StockDetailsViewModel viewModel;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<StockDetailsViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchTransactions(widget.stock.id);
    });
  }

  void _closeOverlayMenu() {
    setState(() {
      _isMenuOpen = false;
    });
  }

  void _toggleOverlayMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockDetailsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildAppBar(context),
          floatingActionButton: Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isMenuOpen) _buildMenuOverlay(context),
              _buildMultiOptionFAB(context),
            ],
          ),
          body: Stack(
            children: [
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Padding(
                  padding: PaddingConstants.pagePadding,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    child: Column(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateRangePicker(context, viewModel),
                        _buildChart(context, viewModel),
                        _buildFinancialSummary(context, viewModel),
                        _buildTransactionsSection(context, viewModel),
                        _buildDividendSection(context, viewModel),
                        const SizedBox(height: 80), // Space for FAB
                      ],
                    ),
                  ),
                ),
              // Overlay background - only when menu is open
              if (_isMenuOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeOverlayMenu,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              // Menu overlay - positioned above the background
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.primary,
      title: Highlight(
          text: '${widget.stock.abbreviation} Hisse Detayları',
          color: AppColors.white),
      leading: IconButton(
        onPressed: () {
          DebounceService().execute(
            'back_button',
            () => Navigator.pop(context),
          );
        },
        icon: const Icon(Icons.chevron_left, color: AppColors.white),
      ),
      actions: [
        IconButton(
          onPressed: () {
            DebounceService().execute(
              'edit_stock_button',
              () => _editStock(context),
            );
          },
          icon: const Icon(Icons.edit, color: AppColors.white),
        ),
      ],
    );
  }

  Widget _buildDateRangePicker(
      BuildContext context, StockDetailsViewModel viewModel) {
    return SectionContainer(
      title: Label(
        text: "Tarih Seçimi",
        isBold: true,
        fontSize: 14,
        color: context.primary,
      ),
      content: CustomDateRangePicker(
        title: 'Tarih Aralığı',
        startDate: viewModel.startDate,
        endDate: viewModel.endDate,
        onDateRangeSelected: (start, end) {
          viewModel.setDateRange(start, end);
        },
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      ),
    );
  }

  Widget _buildChart(BuildContext context, StockDetailsViewModel viewModel) {
    final chartData = viewModel.getChartData();

    if (chartData.isEmpty) {
      return Center(
        child: Content(
          text: 'Seçilen tarih aralığında veri bulunmamaktadır.',
          isCentred: true,
        ),
      );
    }

    return ChartSectionContainer(
      title: Label(
        text: "Fiyat Grafiği",
        isBold: true,
        fontSize: 14,
        color: context.primary,
      ),
      chart: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) {
                return context.primary;
              },
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.x.toInt();
                  if (index >= 0 && index < chartData.length) {
                    return LineTooltipItem(
                      '₺${barSpot.y.toStringAsFixed(2)}',
                      TextStyle(
                        color: context.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  }
                  return LineTooltipItem(
                    '₺${barSpot.y.toStringAsFixed(2)}',
                    TextStyle(
                      color: context.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          clipData: FlClipData.none(),
          titlesData: _buildChartTitles(context, chartData),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          minX: 0,
          maxX: (chartData.length - 1).toDouble(),
          minY: chartData
                  .map((data) => data['price'] as double)
                  .reduce((a, b) => a < b ? a : b) *
              0.9,
          maxY: chartData
                  .map((data) => data['price'] as double)
                  .reduce((a, b) => a > b ? a : b) *
              1.1,
          lineBarsData: _buildLineChartData(context, chartData),
        ),
      ),
    );
  }

  FlTitlesData _buildChartTitles(
      BuildContext context, List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty) return FlTitlesData(show: false);

    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: chartData.length > 10
              ? (chartData.length / 5).floorToDouble()
              : 1,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index < 0 || index >= chartData.length) {
              return const SizedBox.shrink();
            }

            // Sadece başlangıç ve bitiş noktalarında tam tarih göster
            final date = chartData[index]['date'] as String;
            DateTime parsedDate = DateTime.parse(date);

            // Sadece başlangıç, orta ve son noktalarda tarih göster
            if (index == 0 ||
                index == chartData.length - 1 ||
                index == chartData.length ~/ 2) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  DateFormat('dd/MM').format(parsedDate),
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<LineChartBarData> _buildLineChartData(
      BuildContext context, List<Map<String, dynamic>> chartData) {
    return [
      LineChartBarData(
        isCurved: false,
        color: AppColors.chartLine,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.chartGradientStart.withValues(alpha: 0.5),
              AppColors.white.withValues(alpha: 0.1),
            ],
          ),
        ),
        spots: _generateSpots(chartData),
      ),
    ];
  }

  List<FlSpot> _generateSpots(List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty) return [];
    // chartData artık view model'de sıralandığı için burada tekrar sıralamaya gerek yok
    List<FlSpot> spots = [];
    for (int i = 0; i < chartData.length; i++) {
      Map<String, dynamic> data = chartData[i];
      double x = i.toDouble();
      double y = data['price'] as double;
      spots.add(FlSpot(x, y));
    }

    return spots;
  }

  Widget _buildFinancialSummary(
      BuildContext context, StockDetailsViewModel viewModel) {
    final double averageCost = viewModel.calculateAverageCostPerShare();
    final int totalShares = viewModel.getTotalSharesCount();
    final double totalCost = viewModel.calculateTotalCostPrice();
    final double totalDividends = viewModel.calculateTotalDividends();
    final double dividendYield = viewModel.calculateDividendYield();
    final double currentMarketValue = viewModel.calculateCurrentMarketValue();
    final double profitLoss = viewModel.calculateProfitLoss();
    final double profitLossPercentage =
        viewModel.calculateProfitLossPercentage();
    final bool hasCurrentPrice = viewModel.hasCurrentPrice;

    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionWithRows(
          title: Label(
            text: "Portföy Bilgileri",
            isBold: true,
            fontSize: 14,
            color: context.primary,
          ),
          rows: [
            {"Toplam Maliyet": "₺${totalCost.toStringAsFixed(2)}"},
            if (totalShares > 0)
              {"Ortalama Maliyet": "₺${averageCost.toStringAsFixed(2)} / adet"},
            {"Elinizdeki Toplam Adet": totalShares.toString()},
            if (hasCurrentPrice) ...[
              {
                "Güncel Fiyat":
                    "₺${viewModel.currentStock!.currentPrice.toStringAsFixed(2)} / adet"
              },
              {"Güncel Değer": "₺${currentMarketValue.toStringAsFixed(2)}"},
            ]
          ],
        ),

        // Kar/Zarar Bilgileri (sadece güncel fiyat varsa göster)
        if (hasCurrentPrice)
          Container(
            decoration: BoxDecoration(
              color: context.onPrimary,
              borderRadius: GeneralConstants.instance.borderRadius,
              border:
                  Border.all(color: context.secondary.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: PaddingConstants.allSmall,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label(
                  text: "Kar/Zarar Durumu",
                  isBold: true,
                  fontSize: 14,
                  color: context.primary,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Label(text: "Kar/Zarar"),
                    Content(
                      text:
                          "${profitLoss >= 0 ? '+' : ''}₺${profitLoss.toStringAsFixed(2)}",
                      color: profitLoss >= 0
                          ? AppColors.dividendGreen
                          : context.error,
                      isBold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Label(text: "Kar/Zarar Oranı"),
                    Content(
                      text:
                          "${profitLoss >= 0 ? '+' : ''}%${profitLossPercentage.toStringAsFixed(2)}",
                      color: profitLoss >= 0
                          ? AppColors.dividendGreen
                          : context.error,
                      isBold: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Temettü Bilgileri Container
        SectionWithRows(
          title: Label(
            text: "Temettü Bilgileri",
            isBold: true,
            fontSize: 14,
            color: context.primary,
          ),
          rows: [
            {"Toplam Temettü": "₺${totalDividends.toStringAsFixed(2)}"},
            {"Temettü Verimi": "%${dividendYield.toStringAsFixed(2)}"},
            {"Toplam Temettü Sayısı": "${viewModel.dividends.length}"},
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionsSection(
      BuildContext context, StockDetailsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionContainer(
          title: Label(
            text: "İşlemler",
            isBold: true,
            fontSize: 14,
            color: context.primary,
          ),
          headerColor: context.primary.withValues(alpha: 0.1),
          content: viewModel.filteredTransactions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Label(
                          text: "Henüz işlem eklenmemiş",
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: viewModel.filteredTransactions.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionTile(context, viewModel,
                        viewModel.filteredTransactions[index]);
                  },
                ),
          contentPadding: PaddingConstants.zeroPadding,
        ),
      ],
    );
  }

  Widget _buildTransactionTile(BuildContext context,
      StockDetailsViewModel viewModel, TransactionModel transaction) {
    return Slidable(
      key: Key(transaction.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              DebounceService().execute(
                'edit_transaction_${transaction.id}',
                () => _editTransaction(context, transaction),
              );
            },
            backgroundColor: context.primary,
            foregroundColor: AppColors.white,
            icon: Icons.edit,
          ),
          SlidableAction(
            onPressed: (context) {
              DebounceService().execute(
                'delete_transaction_${transaction.id}',
                () => _deleteTransaction(context, viewModel, transaction),
              );
            },
            backgroundColor: context.error,
            foregroundColor: AppColors.white,
            icon: Icons.delete,
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(8)),
          ),
        ],
      ),
      child: Container(
        padding: PaddingConstants.allSmall,
        child: Row(
          children: [
            // İşlem tipi göstergesi (Tasarım birliği için circle avatar kullanıyoruz)
            CircleAvatar(
              backgroundColor: context.primary.withValues(alpha: 0.1),
              radius: 20,
              child: _getTransactionIcon(context, transaction.type),
            ),
            const SizedBox(width: 12),
            // İşlem detayı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Helper(
                    text: DateFormat('dd/MM/yyyy').format(transaction.date),
                    overflow: true,
                    isBold: true,
                  ),
                  if (transaction.note.isNotEmpty)
                    Label(
                      text: transaction.note,
                      overflow: true,
                      fontSize: 12,
                      color: AppColors.black54,
                    )
                  else
                    Label(
                      text: 'Not eklenmemiş',
                      overflow: true,
                      fontSize: 12,
                      color: AppColors.black38,
                    ),
                ],
              ),
            ),
            // İşlem tutarı ve miktar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Helper(
                  text: transaction.price.toPrice(),
                  color: context.onSurface,
                  overflow: true,
                  isBold: true,
                ),
                Label(
                  text: 'Adet: ${transaction.quantity}',
                  color: context.onSurface.withValues(alpha: 0.7),
                  overflow: true,
                  fontSize: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTransactionIcon(BuildContext context, TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Icon(Icons.add_circle, color: context.primary, size: 24);
      case TransactionType.sell:
        return Icon(Icons.remove_circle, color: context.error, size: 24);
    }
  }

  void _editTransaction(BuildContext context, TransactionModel transaction) {
    // İşlem düzenleme ekranını aç
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionView(
          stock: transaction.stock!,
          transaction: transaction,
        ),
      ),
    );
  }

  void _deleteTransaction(BuildContext context, StockDetailsViewModel viewModel,
      TransactionModel transaction) {
    // Onay dialogu göster
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Headline(text: 'İşlemi Sil', fontSize: 20),
        content: Content(text: 'Bu işlemi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Content(text: 'İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteTransaction(transaction.id);

              // Silme işlemi başarılı oldu, başarı dialogu göster
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => SuccessDialog(
                  message: 'İşlem başarıyla silindi',
                  icon: Icons.delete_outline_rounded,
                  backgroundColor: AppColors.dividendGreen,
                  iconColor: AppColors.white,
                  // Normal otomatik kapanma süresi
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Content(text: 'Sil', color: context.error),
          ),
        ],
      ),
    );
  }

  void _editStock(BuildContext context) {
    // Navigate to edit stock page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddStockView(stock: widget.stock),
      ),
    );
  }

  Widget _buildMenuOverlay(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            icon: Icons.monetization_on,
            title: 'Temettü Ekle',
            subtitle: 'Yeni temettü kaydı oluştur',
            color: AppColors.dividendGreen,
            onTap: () {
              _closeOverlayMenu();
              DebounceService().execute(
                'add_dividend_overlay',
                () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddDividendView(stock: widget.stock),
                    ),
                  )
                      .then((_) {
                    context
                        .read<StockDetailsViewModel>()
                        .fetchTransactions(widget.stock.id);
                  });
                },
              );
            },
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          _buildMenuItem(
            icon: Icons.add_shopping_cart,
            title: 'İşlem Ekle',
            subtitle: 'Alım/satım işlemi kaydet',
            color: context.primary,
            onTap: () {
              _closeOverlayMenu();
              DebounceService().execute(
                'add_transaction_overlay',
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddTransactionView(stock: widget.stock),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMultiOptionFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: _toggleOverlayMenu,
      backgroundColor: context.primary,
      child: Icon(
        _isMenuOpen ? Icons.close : Icons.add,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: 280,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDividendSection(
      BuildContext context, StockDetailsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionContainer(
          title: Label(
            text: "Temettüler",
            isBold: true,
            fontSize: 14,
            color: context.primary,
          ),
          headerColor: context.primary.withValues(alpha: 0.1),
          content: viewModel.dividends.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.monetization_on_outlined,
                          color: Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Label(
                          text: "Henüz temettü eklenmemiş",
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: viewModel.dividends.length,
                  itemBuilder: (context, index) {
                    return _buildDividendTile(
                        context, viewModel, viewModel.dividends[index]);
                  },
                ),
          contentPadding: PaddingConstants.zeroPadding,
        ),
      ],
    );
  }

  Widget _buildDividendTile(BuildContext context,
      StockDetailsViewModel viewModel, DividendModel dividend) {
    return Slidable(
      key: Key(dividend.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              DebounceService().execute(
                'edit_dividend_${dividend.id}',
                () => _editDividend(context, dividend),
              );
            },
            backgroundColor: context.primary,
            foregroundColor: AppColors.white,
            icon: Icons.edit,
          ),
          SlidableAction(
            onPressed: (context) {
              DebounceService().execute(
                'delete_dividend_${dividend.id}',
                () => _deleteDividend(context, viewModel, dividend),
              );
            },
            backgroundColor: context.error,
            foregroundColor: AppColors.white,
            icon: Icons.delete,
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(8)),
          ),
        ],
      ),
      child: Container(
        padding: PaddingConstants.allSmall,
        child: Row(
          children: [
            // Temettü göstergesi (Tasarım birliği için circle avatar kullanıyoruz)
            CircleAvatar(
              backgroundColor: context.primary.withValues(alpha: 0.1),
              radius: 20,
              child: Icon(
                Icons.monetization_on,
                color: context.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Temettü detayı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Helper(
                    text: DateFormat('dd/MM/yyyy').format(dividend.date),
                    overflow: true,
                    isBold: true,
                  ),
                  if (dividend.note.isNotEmpty)
                    Label(
                      text: dividend.note,
                      overflow: true,
                      fontSize: 12,
                      color: AppColors.black54,
                    )
                  else
                    Label(
                      text: 'Not eklenmemiş',
                      overflow: true,
                      fontSize: 12,
                      color: AppColors.black38,
                    ),
                ],
              ),
            ),
            // Temettü tutarı
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Helper(
                  text: dividend.totalAmount.toPrice(),
                  color: context.onSurface,
                  overflow: true,
                  isBold: true,
                ),
                Label(
                  text: 'Temettü',
                  color: context.onSurface.withValues(alpha: 0.7),
                  overflow: true,
                  fontSize: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editDividend(BuildContext context, DividendModel dividend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDividendView(
          stock: widget.stock,
          dividend: dividend,
        ),
      ),
    ).then((_) {
      // Refresh dividends after editing
      Provider.of<StockDetailsViewModel>(context, listen: false)
          .fetchTransactions(widget.stock.id);
    });
  }

  void _deleteDividend(BuildContext context, StockDetailsViewModel viewModel,
      DividendModel dividend) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'Temettü Sil',
        message: 'Bu temettü kaydını silmek istediğinizden emin misiniz?',
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        await viewModel.deleteDividend(dividend.id);

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SuccessDialog(
            message: 'Temettü başarıyla silindi!',
            backgroundColor: AppColors.error,
            icon: Icons.check_circle_outline_rounded,
            iconColor: Colors.white,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
