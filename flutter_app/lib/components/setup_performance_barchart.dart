import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class SetupPerformanceBarChart extends StatefulWidget {
  @override
  _SetupPerformanceBarChartState createState() => _SetupPerformanceBarChartState();
}

class _SetupPerformanceBarChartState extends State<SetupPerformanceBarChart> {
  Map<String, int> setupStats = {};
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
      Map<String, int> stats = {};
      for (var trade in journal) {
        String setup = trade['setup'] ?? 'Unknown';
        if (trade['result'] == 'WIN') {
          stats[setup] = (stats[setup] ?? 0) + 1;
        }
      }
      setState(() {
        setupStats = stats;
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (setupStats.isEmpty) return Center(child: Text("No win data by setup"));

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
    List<String> setups = setupStats.keys.toList();
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: setupStats.values.fold(0, (prev, element) => element > prev ? element : prev).toDouble() + 1,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < setups.length) {
                return Text(setups[value.toInt()], style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10));
              }
              return Text('');
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(setups.length, (index) {
        return makeGroupData(index, setupStats[setups[index]]!.toDouble(), barColor: Colors.primaries[index % Colors.primaries.length]);
      }),
      gridData: FlGridData(show: false),
    );
  }

  BarChartGroupData makeGroupData(int x, double y, {Color barColor = Colors.white}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: 22,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
