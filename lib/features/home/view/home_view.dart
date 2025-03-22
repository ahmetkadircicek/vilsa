import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_formatter.dart';
import 'package:vilsa/features/home/model/chart_data_point_model.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';
import 'package:vilsa/features/portfolio/view/portfolio_view.dart';
import 'package:vilsa/features/stock/viewmodel/stock_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer2<HomeViewModel, StockViewModel>(
        builder: (context, homeViewModel, stockViewModel, child) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              spacing: 16,
              children: [
                _buildBalanceSection(context, homeViewModel),
                _bodySection(context, homeViewModel, stockViewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bodySection(BuildContext context, HomeViewModel homeViewModel, StockViewModel stockViewModel) {
    return Padding(
      padding: PaddingConstants.pagePadding,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 16, children: [
        _buildDateRangePicker(context, homeViewModel),
        _buildChartSection(context, homeViewModel),
        _buildSharesSection(context, stockViewModel),
      ]),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.primary,
      title: const Highlight(text: 'Anasayfa', color: Colors.white),
    );
  }

  Widget _buildBalanceSection(BuildContext context, HomeViewModel viewModel) {
    return Container(
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
    return SizedBox(
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
    );
  }

  Widget _buildDateRangePicker(BuildContext context, HomeViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: GeneralConstants.instance.borderRadius,
        border: Border.all(color: context.secondary.withValues(alpha: 0.2)),
      ),
      padding: PaddingConstants.allSmall,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(viewModel.startDate)} - ${DateFormat('dd/MM/yyyy').format(viewModel.endDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.onSurface,
                    ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Content(text: 'Grafik'),
        Container(
          decoration: BoxDecoration(
            color: context.onPrimary,
            borderRadius: GeneralConstants.instance.borderRadius,
          ),
          padding: PaddingConstants.allSmall,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                height: 200,
                child: _buildChartWithData(context, viewModel),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartWithData(BuildContext context, HomeViewModel viewModel) {
    final chartData = viewModel.getChartData();

    if (chartData.isEmpty) {
      return Center(
        child: Text('Bu tarih aralığında veri bulunmamaktadır.'),
      );
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) {
              return context.primary;
            },
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  viewModel.totalBalance.toPrice(),
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
            String formattedDate = viewModel.formatDisplayDate(date);

            return Label(
              text: formattedDate,
              fontSize: 10,
              color: Colors.grey,
              isBold: true,
            );
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
        color: const Color(0XFF534BE6),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0XFF534BE6).withOpacity(0.5),
              Colors.white.withOpacity(0.1),
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

  Widget _buildSharesSection(BuildContext context, StockViewModel stockViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Content(text: 'Portföy'),
        PortfolioView(),
      ],
    );
  }
}
// Updated on 2025-01-06 - add authentication module
// Updated on 2025-01-20 - add navigation structure
// Updated on 2025-01-29 - resolve null pointer exceptions
// Updated on 2025-02-03 - optimize image loading
// Updated on 2025-02-04 - improve loading indicator
// Updated on 2025-02-24 - implement user profile screen
// Updated on 2025-02-28 - improve error handling structure
// Updated on 2025-03-05 - refine animation transitions
// Updated on 2025-03-09 - improve error handling structure
// Updated on 2025-03-13 - improve button styling
