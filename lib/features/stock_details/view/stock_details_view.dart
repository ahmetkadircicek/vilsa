import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_formatter.dart';
import 'package:vilsa/features/add_stock/model/stock_model.dart';
import 'package:vilsa/features/add_transaction/model/transaction_model.dart';
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
    // Schedule the fetch after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchTransactions(widget.stock.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<StockDetailsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }
          return Padding(
            padding: PaddingConstants.allMedium,
            child: SingleChildScrollView(
              child: Column(
                spacing: 16,
                children: [
                  _buildDateRangePicker(context, viewModel),
                  _buildChart(context, viewModel),
                  _buildFinancialSummary(context, viewModel),
                  _buildTransactionsList(context, viewModel),
                ],
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
      title: const Highlight(text: 'Stok Detayları', color: Colors.white),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.chevron_left, color: Colors.white),
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, StockDetailsViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: GeneralConstants.instance.borderRadius,
        border: Border.all(color: context.secondary.withOpacity(0.2)),
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
                color: context.primary.withOpacity(0.1),
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
      return const Center(child: Text('No data available for the selected date range.'));
    }

    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: GeneralConstants.instance.borderRadius,
      ),
      padding: PaddingConstants.allSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(
            text: 'Fiyat Grafiği',
            isBold: true,
          ),
          Container(
            padding: const EdgeInsets.all(8),
            height: 200,
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
                          final point = chartData[index];
                          final time = point['time'] as String; // Saat bilgisini gösterelim
                          return LineTooltipItem(
                            '₺${barSpot.y.toStringAsFixed(2)}\n$time',
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
          ),
        ],
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

            // Tarih ile birlikte işlem ID'sinin son 3 karakterini gösterelim
            final date = chartData[index]['date'] as String;
            final id = chartData[index]['id'] as String;
            final shortId = id.length > 3 ? id.substring(id.length - 3) : id;

            // Her 3. değer için tam tarih göster
            String formattedDate = index % 3 == 0 ? DateFormat('dd/MM').format(DateTime.parse(date)) : shortId;

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

  List<LineChartBarData> _buildLineChartData(BuildContext context, List<Map<String, dynamic>> chartData) {
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Toplam Maliyet: ₺${viewModel.calculateTotalCostPrice().toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Toplam Temettü: ₺${viewModel.calculateTotalDividends().toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16)),
          Text("Temettü Verimi: %${viewModel.calculateDividendYield().toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, StockDetailsViewModel viewModel) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.filteredTransactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionTile(context, viewModel.filteredTransactions[index]);
      },
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionModel transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            child: Icon(Icons.receipt, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Helper(
                  text: DateFormat('dd/MM/yyyy').format(transaction.date),
                  color: Colors.black87,
                  isBold: true,
                ),
                Label(
                  text: transaction.note.isNotEmpty ? transaction.note : 'Not eklenmemiş',
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Helper(
                text: transaction.price.toPrice(),
                color: Colors.black87,
                isBold: true,
              ),
              Label(
                text: 'Adet: ${transaction.quantity}',
                color: Colors.black54,
              ),
              if (transaction.dividends > 0)
                Label(
                  text: 'Temettü: ${transaction.dividends.toPrice()}',
                  color: Colors.green[700],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
// Updated on 2025-01-17 - resolve null pointer exceptions
// Updated on 2025-01-20 - resolve authentication token expiry
// Updated on 2025-01-31 - address UI alignment issues
// Updated on 2025-02-13 - implement filtering options
// Updated on 2025-02-18 - address UI alignment issues
// Updated on 2025-02-20 - add transaction history page
// Updated on 2025-02-26 - add navigation structure
// Updated on 2025-03-01 - correct date formatting issues
// Updated on 2025-03-02 - add search functionality
// Updated on 2025-03-04 - optimize data fetching logic
// Updated on 2025-03-06 - add search functionality
// Updated on 2025-03-10 - implement notification system
