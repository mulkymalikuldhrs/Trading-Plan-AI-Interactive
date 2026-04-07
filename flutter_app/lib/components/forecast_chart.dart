import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ForecastChartWidget extends StatelessWidget {
  final List<FlSpot> historicalSpots;
  final List<FlSpot> forecastSpots;
  final double stopLoss;
  final double takeProfit;

  const ForecastChartWidget({
    super.key,
    required this.historicalSpots,
    required this.forecastSpots,
    required this.stopLoss,
    required this.takeProfit,
  });

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
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                'Price: ${spot.y}\nDay: ${spot.x}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
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
          color: Colors.cyan.withOpacity(0.5),
          barWidth: 3,
          dotData: FlDotData(show: false),
          dashArray: [5, 5], // Dashed line for forecast
        ),
      ],
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: stopLoss,
            color: Colors.redAccent.withOpacity(0.8),
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
            color: Colors.greenAccent.withOpacity(0.8),
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
