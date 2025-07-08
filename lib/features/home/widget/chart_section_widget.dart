import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/components/section_container.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/enums/chart_type_enum.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_formatter.dart';
import 'package:vilsa/core/init/network/debounce_service.dart';
import 'package:vilsa/features/home/model/chart_data_point_model.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';

class ChartSectionWidget extends StatelessWidget {
  const ChartSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final chartData = homeViewModel.getChartData();

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
        title: Label(
          text: "Grafik",
          isBold: true,
          fontSize: 14,
          color: context.primary,
        ),
        trailing: _buildChartTypeSelector(context),
        chart: _buildChartWithData(context),
      ),
    );
  }

  Widget _buildChartTypeSelector(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.bar_chart_rounded,
            color: viewModel.chartType == ChartTypeEnum.daily
                ? context.primary
                : context.onSurface.withValues(alpha: 0.5),
          ),
          onPressed: () {
            DebounceService().execute(
              'chart_type_daily',
              () => viewModel.setChartType(ChartTypeEnum.daily),
            );
          },
          tooltip: 'Günlük Değerler',
        ),
        IconButton(
          icon: Icon(
            Icons.trending_up_rounded,
            color: viewModel.chartType == ChartTypeEnum.total
                ? context.primary
                : context.onSurface.withValues(alpha: 0.5),
          ),
          onPressed: () {
            DebounceService().execute(
              'chart_type_total',
              () => viewModel.setChartType(ChartTypeEnum.total),
            );
          },
          tooltip: 'Toplam Değerler',
        ),
      ],
    );
  }

  Widget _buildChartWithData(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
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
                    final formattedDate =
                        DateFormat('dd/MM/yy').format(datePoint.date);
                    final value = viewModel.chartType == ChartTypeEnum.total
                        ? datePoint.value.toPrice()
                        : datePoint.value.toPrice();

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
          titlesData: _buildChartTitles(context, chartData),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          lineBarsData: _buildLineChartData(chartData),
        ),
      ),
    );
  }

  FlTitlesData _buildChartTitles(
      BuildContext context, List<ChartDataPoint> chartData) {
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

            if (index == 0 ||
                index == chartData.length - 1 ||
                index == chartData.length ~/ 2) {
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

  List<LineChartBarData> _buildLineChartData(List<ChartDataPoint> chartData) {
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
}
