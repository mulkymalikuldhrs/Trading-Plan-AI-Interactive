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
        color: Colors.blueGrey[900]?.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            mainBarData(),
            swapAnimationDuration: Duration(milliseconds: 250),
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
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0: return 'FVG';
              case 1: return 'BOS';
              case 2: return 'CHoCH';
              default: return '';
            }
          },
        ),
        leftTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        rightTitles: SideTitles(showTitles: false),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
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
          y: y,
          colors: [barColor.withOpacity(0.6), barColor],
          width: 22,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
