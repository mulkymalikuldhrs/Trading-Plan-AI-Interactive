import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ForecastChart extends StatelessWidget {
  final List<FlSpot> spots;
  final String label;
  final Color color;

  const ForecastChart({
    Key? key,
    required this.spots,
    this.label = 'Forecast',
    this.color = Colors.orange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots.isNotEmpty ? spots : [FlSpot(0, 0)],
              isCurved: true,
              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.5)]),
              barWidth: 4,
              dotData: FlDotData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(2),
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  'D${value.toInt()}',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
            getDrawingVerticalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white10),
          ),
        ),
      ),
    );
  }
}
