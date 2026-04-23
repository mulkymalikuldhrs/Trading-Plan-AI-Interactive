import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SetupPerformanceBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            mainBarData(),
            swapAnimationDuration: const Duration(milliseconds: 250),
          ),
        ),
      ),
    );
  }

  BarChartData mainBarData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 100,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) {
              String text;
              switch (value.toInt()) {
                case 0: text = 'FVG'; break;
                case 1: text = 'BOS'; break;
                case 2: text = 'CHoCH'; break;
                default: text = ''; break;
              }
              return Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14));
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  List<BarChartGroupData> showingGroups() => [
    makeGroupData(0, 65, barColor: Colors.cyan),
    makeGroupData(1, 45, barColor: Colors.amber),
    makeGroupData(2, 30, barColor: Colors.purpleAccent),
  ];

  BarChartGroupData makeGroupData(int x, double y, {Color barColor = Colors.white}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(colors: [barColor.withValues(alpha: 0.6), barColor], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          width: 22,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
