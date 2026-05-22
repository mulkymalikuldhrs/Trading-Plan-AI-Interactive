import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class EquityCurveChart extends StatefulWidget {
  @override
  _EquityCurveChartState createState() => _EquityCurveChartState();
}

class _EquityCurveChartState extends State<EquityCurveChart> {
  List<FlSpot> spots = [];
  List<int> winningTradesIndices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await ApiService.post('exportToJson', {'sheetName': 'Journal'});
      final List<dynamic> journal = (data is String) ? jsonDecode(data) : data;

      double balance = 10000; // Starting balance
      List<FlSpot> fetchedSpots = [FlSpot(0, balance)];
      List<int> wins = [];

      for (int i = 0; i < journal.length; i++) {
        final trade = journal[i];
        final pnl = double.tryParse(trade['pnl']?.toString() ?? '0') ?? 0;
        balance += pnl;
        fetchedSpots.add(FlSpot((i + 1).toDouble(), balance));
        if (trade['result'] == 'WIN') {
          wins.add(i + 1);
        }
      }

      setState(() {
        spots = fetchedSpots;
        winningTradesIndices = wins;
        isLoading = false;
      });
    } catch (e) {
      print('EquityCurveChart Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (spots.isEmpty) return Center(child: Text("No trade data available"));

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.blueGrey[900]?.withOpacity(0.5),
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
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) => Text('T${value.toInt()}', style: TextStyle(color: Colors.white70, fontSize: 10)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0), style: TextStyle(color: Colors.white70, fontSize: 10)),
            ),
          )
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white10)),
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
              bool isWin = winningTradesIndices.contains(index);
              return FlDotCirclePainter(radius: 4, color: isWin ? Colors.greenAccent : Colors.redAccent, strokeWidth: 1, strokeColor: Colors.white);
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.cyan.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
