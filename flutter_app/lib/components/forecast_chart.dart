import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ForecastChartWidget extends StatelessWidget {
  // Dummy data for demonstration
  final List<FlSpot> historicalSpots = const [
    FlSpot(0, 1.0850), FlSpot(1, 1.0865), FlSpot(2, 1.0855),
    FlSpot(3, 1.0870), FlSpot(4, 1.0880),
  ];

  final List<FlSpot> forecastSpots = const [
    FlSpot(4, 1.0880), // Start from last historical point
    FlSpot(5, 1.0875), FlSpot(6, 1.0860), FlSpot(7, 1.0840),
    FlSpot(8, 1.0820), FlSpot(9, 1.0800),
  ];

  final double stopLoss = 1.0905;
  final double takeProfit = 1.0780;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        forecastChartData(),
      ),
    );
  }

  LineChartData forecastChartData() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: true),
      gridData: FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24, width: 1)),
      lineBarsData: [
        // Historical Data
        LineChartBarData(
          spots: historicalSpots,
          isCurved: true,
          color: Colors.white,
          barWidth: 3,
          dotData: FlDotData(show: false),
        ),
        // Forecast Data
        LineChartBarData(
          spots: forecastSpots,
          isCurved: true,
          color: Colors.cyan.withValues(alpha: 0.5),
          barWidth: 3,
          dotData: FlDotData(show: false),
          dashArray: [5, 5], // Dashed line for forecast
        ),
      ],
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: stopLoss,
            color: Colors.redAccent.withValues(alpha: 0.8),
            strokeWidth: 2,
            dashArray: [10, 2],
            label: HorizontalLineLabel(
              show: true,
              labelResolver: (line) => 'SL 🔐 ${line.y}',
              alignment: Alignment.topRight,
              style: TextStyle(color: Colors.white, backgroundColor: Colors.red),
            ),
          ),
          HorizontalLine(
            y: takeProfit,
            color: Colors.greenAccent.withValues(alpha: 0.8),
            strokeWidth: 2,
            dashArray: [10, 2],
            label: HorizontalLineLabel(
              show: true,
              labelResolver: (line) => 'TP 🎯 ${line.y}',
              alignment: Alignment.bottomRight,
              style: TextStyle(color: Colors.white, backgroundColor: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
