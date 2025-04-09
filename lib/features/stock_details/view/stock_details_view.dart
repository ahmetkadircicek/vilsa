import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/components/section_container.dart';
import 'package:vilsa/core/components/success_dialog.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_formatter.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
import 'package:vilsa/features/add_transaction/view/add_transaction_view.dart';
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

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<StockDetailsViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchTransactions(widget.stock.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni işlem ekleme sayfasına yönlendir
          print("İşlem ekleme butonuna basıldı: ${widget.stock.name} (${widget.stock.id})");
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddTransactionView(
                stock: widget.stock,
              ),
            ),
          );
        },
        backgroundColor: context.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: Consumer<StockDetailsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ViewModel'in başlatılması - ilk kez çalıştığında işlemleri yükle
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!viewModel.hasLoadedTransactions) {
              print("StockDetailsView: fetchTransactions çağrılıyor (ilk kez) - ${widget.stock.id}");
              viewModel.fetchTransactions(widget.stock.id);
            }
          });

          if (viewModel.transactions.isEmpty) {
            return const Center(child: Content(text: 'İşlem bulunamadı.', isCentred: true));
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Padding(
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.primary,
      title: Highlight(text: '${widget.stock.abbreviation} Hisse Detayları', color: AppColors.white),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.chevron_left, color: AppColors.white),
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, StockDetailsViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: GeneralConstants.instance.borderRadius,
        border: Border.all(color: context.secondary.withValues(alpha: 0.2)),
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
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(text: 'Tarih Aralığı:'),
          GestureDetector(
            onTap: () => _selectDateRange(context, viewModel),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Content(
                    text:
                        '${DateFormat('dd/MM/yyyy').format(viewModel.startDate)} - ${DateFormat('dd/MM/yyyy').format(viewModel.endDate)}',
                    color: context.onSurface,
                    fontSize: 14,
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.calendar_today, size: 16, color: context.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context, StockDetailsViewModel viewModel) async {
    final initialDateRange = DateTimeRange(
      start: viewModel.startDate,
      end: viewModel.endDate,
    );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
    );

    if (newDateRange != null) {
      viewModel.setDateRange(newDateRange.start, newDateRange.end);
    }
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
      title: "Fiyat Grafiği",
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
          minY: chartData.map((data) => data['price'] as double).reduce((a, b) => a < b ? a : b) * 0.9,
          maxY: chartData.map((data) => data['price'] as double).reduce((a, b) => a > b ? a : b) * 1.1,
          lineBarsData: _buildLineChartData(context, chartData),
        ),
      ),
    );
  }

  FlTitlesData _buildChartTitles(BuildContext context, List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty) return FlTitlesData(show: false);

    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: chartData.length > 10 ? (chartData.length / 5).floorToDouble() : 1,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index < 0 || index >= chartData.length) {
              return const SizedBox.shrink();
            }

            // Sadece başlangıç ve bitiş noktalarında tam tarih göster
            final date = chartData[index]['date'] as String;
            DateTime parsedDate = DateTime.parse(date);

            // Sadece başlangıç, orta ve son noktalarda tarih göster
            if (index == 0 || index == chartData.length - 1 || index == chartData.length ~/ 2) {
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

  List<LineChartBarData> _buildLineChartData(BuildContext context, List<Map<String, dynamic>> chartData) {
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

  Widget _buildFinancialSummary(BuildContext context, StockDetailsViewModel viewModel) {
    final double averageCost = viewModel.calculateAverageCostPerShare();
    final int totalShares = viewModel.getTotalSharesCount();
    final double totalCost = viewModel.calculateTotalCostPrice();
    final double totalDividends = viewModel.calculateTotalDividends();
    final double dividendYield = viewModel.calculateDividendYield();

    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionWithRows(
          title: "Portföy Bilgileri",
          rows: [
            {"Toplam Maliyet": "₺${totalCost.toStringAsFixed(2)}"},
            if (totalShares > 0) {"Ortalama Maliyet": "₺${averageCost.toStringAsFixed(2)} / adet"},
            {"Elinizdeki Toplam Adet": totalShares.toString()},
          ],
        ),

        // Temettü Bilgileri Container
        SectionWithRows(
          title: "Temettü Bilgileri",
          rows: [
            {"Toplam Temettü": "₺${totalDividends.toStringAsFixed(2)}"},
            {"Temettü Verimi": "%${dividendYield.toStringAsFixed(2)}"},
            {"Adet Başına Temettü": "₺${viewModel.currentStock?.dividends.toStringAsFixed(2) ?? '0.00'}"},
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionsSection(BuildContext context, StockDetailsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionContainer(
          title: "İşlemler",
          headerColor: context.primary.withValues(alpha: 0.1),
          content: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.filteredTransactions.length,
            itemBuilder: (context, index) {
              return _buildTransactionTile(context, viewModel, viewModel.filteredTransactions[index]);
            },
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(BuildContext context, StockDetailsViewModel viewModel, TransactionModel transaction) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Slidable(
        key: Key(transaction.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _editTransaction(context, transaction),
              backgroundColor: context.primary,
              foregroundColor: AppColors.white,
              icon: Icons.edit,
            ),
            SlidableAction(
              onPressed: (context) => _deleteTransaction(context, viewModel, transaction),
              backgroundColor: context.error,
              foregroundColor: AppColors.white,
              icon: Icons.delete,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
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
                  if (transaction.dividends > 0)
                    Label(
                      text: 'Temettü: ${transaction.dividends.toPrice()}',
                      color: AppColors.dividendGreen,
                      overflow: true,
                      fontSize: 10,
                    ),
                ],
              ),
            ],
          ),
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
      case TransactionType.dividend:
        return Icon(Icons.monetization_on, color: AppColors.dividendGreen, size: 24);
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

  void _deleteTransaction(BuildContext context, StockDetailsViewModel viewModel, TransactionModel transaction) {
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
                  // Dialog'un kendi otomatik kapanma mekanizması yerine, elle kapatacağız
                  duration: const Duration(days: 1), // Çok uzun süre ayarlıyoruz
                ),
              );

              // Dialog gösterdikten sonra bekleme süresi
              Future.delayed(const Duration(milliseconds: 1500), () {
                // Dialog'u kapat
                Navigator.of(context).pop();
              });
            },
            child: Content(text: 'Sil', color: context.error),
          ),
        ],
      ),
    );
  }
}
