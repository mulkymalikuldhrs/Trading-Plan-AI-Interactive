import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EquityCurveChart extends StatefulWidget {
  const EquityCurveChart({super.key});

  @override
  State<EquityCurveChart> createState() => _EquityCurveChartState();
}

class _EquityCurveChartState extends State<EquityCurveChart> {
  List<FlSpot> spots = [const FlSpot(0, 0)];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final List<dynamic> journal = await ApiService.exportSheet('Journal');
      double balance = 10000; // Starting balance
      List<FlSpot> newSpots = [FlSpot(0, balance)];

      for (int i = 0; i < journal.length; i++) {
        final double pnl = (journal[i]['PnL'] ?? 0).toDouble();
        balance += pnl;
        newSpots.add(FlSpot((i + 1).toDouble(), balance));
      }

      setState(() {
        spots = newSpots;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading equity data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: true),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) => Text('T${value.toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                ),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.white10)),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: const LinearGradient(colors: [Colors.cyan, Colors.blueAccent]),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(colors: [Colors.cyan.withValues(alpha: 0.3), Colors.blueAccent.withValues(alpha: 0.1)]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
