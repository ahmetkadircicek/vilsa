import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/components/section_container.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_formatter.dart';
import 'package:vilsa/features/add_stock/view/add_stock_view.dart';
import 'package:vilsa/features/home/model/chart_data_point_model.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';
import 'package:vilsa/features/portfolio/view/portfolio_view.dart';
import 'package:vilsa/features/portfolio/viewmodel/portfolio_view.dart.dart';
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddStockView(),
            ),
          );
        },
        backgroundColor: context.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _bodySection(BuildContext context, HomeViewModel homeViewModel, StockViewModel stockViewModel) {
    return Padding(
      padding: PaddingConstants.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangePicker(context, homeViewModel),
          const SizedBox(height: 16),
          _buildChartSection(context, homeViewModel),
          const SizedBox(height: 16),
          _buildSharesSection(context, homeViewModel),
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
      padding: PaddingConstants.symmetricHorizontalMedium + PaddingConstants.onlyBottomLarge,
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
            Headline(text: viewModel.totalBalance.toPrice(), isBold: true, color: context.onPrimary),
            Label(
              text: 'Toplam Temettü: ${viewModel.totalDividends.toPrice()}',
              color: context.onPrimary.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, HomeViewModel viewModel) {
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
          Helper(text: 'Tarih Aralığı:'),
          GestureDetector(
            onTap: () => _selectDateRange(context, viewModel),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                spacing: 8,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: context.primary),
                  Content(
                    text:
                        '${DateFormat('dd/MM/yyyy').format(viewModel.startDate)} - ${DateFormat('dd/MM/yyyy').format(viewModel.endDate)}',
                    color: context.onSurface,
                    fontSize: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context, HomeViewModel viewModel) async {
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

  Widget _buildChartSection(BuildContext context, HomeViewModel viewModel) {
    final chartData = viewModel.getChartData();

    if (chartData.isEmpty) {
      return Center(
        child: Content(
          text: 'Bu tarih aralığında veri bulunmamaktadır.',
          isCentred: true,
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ChartSectionContainer(
        key: ValueKey(chartData.length),
        title: "Grafik",
        trailing: _buildChartTypeSelector(context, viewModel),
        chart: _buildChartWithData(context, viewModel),
      ),
    );
  }

  Widget _buildChartTypeSelector(BuildContext context, HomeViewModel viewModel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.bar_chart_rounded,
            color: viewModel.chartType == ChartType.daily ? context.primary : context.onSurface.withValues(alpha: 0.5),
          ),
          onPressed: () => viewModel.setChartType(ChartType.daily),
          tooltip: 'Günlük Değerler',
        ),
        IconButton(
          icon: Icon(
            Icons.trending_up_rounded,
            color: viewModel.chartType == ChartType.total ? context.primary : context.onSurface.withValues(alpha: 0.5),
          ),
          onPressed: () => viewModel.setChartType(ChartType.total),
          tooltip: 'Toplam Değerler',
        ),
      ],
    );
  }

  Widget _buildChartWithData(BuildContext context, HomeViewModel viewModel) {
    final chartData = viewModel.getChartData();

    if (chartData.isEmpty) {
      return Center(
        child: Content(
          text: 'Bu tarih aralığında veri bulunmamaktadır.',
          isCentred: true,
        ),
      );
    }

    return Padding(
      padding: PaddingConstants.symmetricHorizontalMedium +
          PaddingConstants.onlyTopMedium +
          PaddingConstants.onlyBottomMedium,
      child: LineChart(
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
                    final datePoint = chartData[index];
                    final formattedDate = DateFormat('dd/MM/yy').format(datePoint.date);
                    final value =
                        viewModel.chartType == ChartType.total ? datePoint.value.toPrice() : datePoint.value.toPrice();

                    return LineTooltipItem(
                      '$formattedDate\n$value',
                      TextStyle(
                        color: context.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  }

                  return LineTooltipItem(
                    barSpot.y.toPrice(),
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
          titlesData: _buildChartTitles(context, viewModel, chartData),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          lineBarsData: _buildLineChartData(context, chartData),
        ),
      ),
    );
  }

  FlTitlesData _buildChartTitles(BuildContext context, HomeViewModel viewModel, List<ChartDataPoint> chartData) {
    if (chartData.isEmpty) return FlTitlesData(show: false);

    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 2,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index < 0 || index >= chartData.length) {
              return const SizedBox.shrink();
            }

            DateTime date = chartData[index].date;

            if (index == 0 || index == chartData.length - 1 || index == chartData.length ~/ 2) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  DateFormat('dd/MM/yy').format(date),
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

  List<LineChartBarData> _buildLineChartData(BuildContext context, List<ChartDataPoint> chartData) {
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

  List<FlSpot> _generateSpots(List<ChartDataPoint> chartData) {
    if (chartData.isEmpty) return [];
    List<FlSpot> spots = [];
    for (int i = 0; i < chartData.length; i++) {
      ChartDataPoint data = chartData[i];
      double x = i.toDouble();
      double y = data.value;
      spots.add(FlSpot(x, y));
    }

    return spots;
  }

  Widget _buildSharesSection(BuildContext context, HomeViewModel viewModel) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PortfolioViewModel>.value(
          value: Provider.of<PortfolioViewModel>(context, listen: false),
        ),
      ],
      child: SectionContainer(
        title: "Hisselerim",
        trailing: PopupMenuButton<dynamic>(
          icon: Icon(
            Icons.filter_list_rounded,
            color: viewModel.stockFilterType != StockFilterType.all ||
                    viewModel.stockSortType != StockSortType.alphabetical
                ? context.primary
                : context.onSurface.withValues(alpha: 0.5),
          ),
          onSelected: (value) {
            if (value is StockFilterType) {
              viewModel.setStockFilterType(value);
            } else if (value is StockSortType) {
              viewModel.setStockSortType(value);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: StockFilterType.all,
              child: Row(
                children: [
                  Icon(
                    Icons.list_rounded,
                    color: viewModel.stockFilterType == StockFilterType.all ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('Tüm Hisseler'),
                ],
              ),
            ),
            PopupMenuItem(
              value: StockFilterType.traded,
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: viewModel.stockFilterType == StockFilterType.traded ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('İşlem Yapılanlar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: StockFilterType.untraded,
              child: Row(
                children: [
                  Icon(
                    Icons.trending_down_rounded,
                    color: viewModel.stockFilterType == StockFilterType.untraded ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('İşlem Yapılmayanlar'),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: StockSortType.alphabetical,
              child: Row(
                children: [
                  Icon(
                    Icons.sort_by_alpha_rounded,
                    color: viewModel.stockSortType == StockSortType.alphabetical ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('Alfabetik Sırala'),
                ],
              ),
            ),
            PopupMenuItem(
              value: StockSortType.quantity,
              child: Row(
                children: [
                  Icon(
                    Icons.numbers_rounded,
                    color: viewModel.stockSortType == StockSortType.quantity ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('Adete Göre Sırala'),
                ],
              ),
            ),
            PopupMenuItem(
              value: StockSortType.totalValue,
              child: Row(
                children: [
                  Icon(
                    Icons.attach_money_rounded,
                    color: viewModel.stockSortType == StockSortType.totalValue ? context.primary : context.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text('Toplam Değere Göre Sırala'),
                ],
              ),
            ),
            PopupMenuItem(
              value: StockSortType.averagePrice,
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    color: viewModel.stockSortType == StockSortType.averagePrice ? context.primary : context.onSurface,
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
