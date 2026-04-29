import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SetupPerformanceBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: const Color(0xff2c4260),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 20,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10);
                      String text;
                      switch (value.toInt()) {
                        case 0: text = 'S1'; break;
                        case 1: text = 'S2'; break;
                        case 2: text = 'S3'; break;
                        default: text = ''; break;
                      }
                      return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.lightBlueAccent)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.lightBlueAccent)]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.lightBlueAccent)]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
