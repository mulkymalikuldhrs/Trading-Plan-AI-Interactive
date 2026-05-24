import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ForecastChart extends StatelessWidget {
  final List<FlSpot>? spots;

  ForecastChart({this.spots});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> effectiveSpots = spots ?? const [
      FlSpot(0, 1.0850),
      FlSpot(1, 1.0875),
      FlSpot(2, 1.0860),
      FlSpot(3, 1.0890),
      FlSpot(4, 1.0910),
    ];

    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text('D${value.toInt()}', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(4), style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: effectiveSpots,
                  isCurved: true,
                  color: Colors.orangeAccent,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.orangeAccent.withValues(alpha: 0.1),
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
