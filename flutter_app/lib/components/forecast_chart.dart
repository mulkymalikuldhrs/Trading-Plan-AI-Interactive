import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ForecastChartWidget extends StatelessWidget {
  final List<FlSpot> historicalSpots = const [
    FlSpot(0, 1.0850), FlSpot(1, 1.0865), FlSpot(2, 1.0855),
    FlSpot(3, 1.0870), FlSpot(4, 1.0880),
  ];

  final List<FlSpot> forecastSpots = const [
    FlSpot(4, 1.0880),
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
      lineTouchData: const LineTouchData(enabled: true),
      gridData: const FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: true),
      titlesData: const FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40))
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24, width: 1)),
      lineBarsData: [
        LineChartBarData(
          spots: historicalSpots,
          isCurved: true,
          color: Colors.white,
          barWidth: 3,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: forecastSpots,
          isCurved: true,
          color: Colors.cyan.withValues(alpha: 0.5),
          barWidth: 3,
          dotData: const FlDotData(show: false),
          dashArray: [5, 5],
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
              style: const TextStyle(color: Colors.white, backgroundColor: Colors.red),
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
              style: const TextStyle(color: Colors.white, backgroundColor: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
