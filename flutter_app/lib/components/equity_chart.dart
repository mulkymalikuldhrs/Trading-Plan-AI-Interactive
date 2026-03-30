import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EquityCurveChart extends StatefulWidget {
  const EquityCurveChart({super.key});

  @override
  State<EquityCurveChart> createState() => _EquityCurveChartState();
}

class _EquityCurveChartState extends State<EquityCurveChart> {
  List<FlSpot> spots = [];
  List<int> winningTradesIndices = [];
  bool isLoading = true;
  double minY = 9800;
  double maxY = 10200;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final data = await ApiService.fetchJournalData();
      double currentEquity = 10000; // Starting balance
      List<FlSpot> newSpots = [FlSpot(0, currentEquity)];
      List<int> wins = [];

      for (int i = 0; i < data.length; i++) {
        final trade = data[i];
        double pnl = 0.0;

        if (trade['PnL'] != null && trade['PnL'] is num && trade['PnL'] != 0) {
          pnl = (trade['PnL'] as num).toDouble();
        } else {
          // Fallback to simplified profit/loss if PnL is not recorded
          if (trade['Result'] == 'WIN') {
            pnl = 200.0;
          } else if (trade['Result'] == 'LOSS') {
            pnl = -100.0;
          }
        }

        currentEquity += pnl;
        if (trade['Result'] == 'WIN') {
          wins.add(i + 1);
        }
        newSpots.add(FlSpot((i + 1).toDouble(), currentEquity));
      }

      setState(() {
        spots = newSpots;
        winningTradesIndices = wins;
        isLoading = false;

        if (spots.isNotEmpty) {
           double min = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
           double max = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
           minY = min - 200;
           maxY = max + 200;
        }
      });
    } catch (e) {
      debugPrint("Error loading equity data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (spots.isEmpty) return Center(child: Text("No trade data available", style: TextStyle(color: Colors.white)));

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            mainData(),
          ),
        ),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
        getDrawingVerticalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) => Text(value % 1 == 0 ? 'T${value.toInt()}' : '', style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ),
          )
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white10)),
      minX: 0,
      maxX: spots.length.toDouble() - 1,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.cyan,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              if (index == 0) return FlDotCirclePainter(radius: 0);
              if (winningTradesIndices.contains(index)) {
                return FlDotCirclePainter(radius: 4, color: Colors.greenAccent, strokeWidth: 1, strokeColor: Colors.white);
              } else {
                return FlDotCirclePainter(radius: 4, color: Colors.redAccent, strokeWidth: 1, strokeColor: Colors.white);
              }
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.cyan.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}
