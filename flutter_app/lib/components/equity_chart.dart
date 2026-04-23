import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EquityCurveChart extends StatelessWidget {
  final List<FlSpot> spots = const [
    FlSpot(0, 10000),
    FlSpot(1, 10100),
    FlSpot(2, 10050),
    FlSpot(3, 10250),
    FlSpot(4, 10350),
    FlSpot(5, 10300),
    FlSpot(6, 10450),
    FlSpot(7, 10600),
  ];

  final List<int> winningTradesIndices = [1, 3, 4, 6, 7];

  @override
  Widget build(BuildContext context) {
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
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.white10, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Colors.white10, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) => Text('Day ${value.toInt() + 1}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white10)),
      minX: 0,
      maxX: spots.length.toDouble() - 1,
      minY: 9800,
      maxY: 10800,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: const LinearGradient(colors: [Colors.cyan, Colors.blueAccent]),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              if (winningTradesIndices.contains(index)) {
                return FlDotCirclePainter(radius: 6, color: Colors.greenAccent, strokeWidth: 2, strokeColor: Colors.white);
              } else {
                return FlDotCirclePainter(radius: 6, color: Colors.redAccent, strokeWidth: 2, strokeColor: Colors.white);
              }
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.cyan.withValues(alpha: 0.3), Colors.blueAccent.withValues(alpha: 0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
