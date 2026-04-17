import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SetupPerformanceBarChart extends StatefulWidget {
  const SetupPerformanceBarChart({super.key});

  @override
  State<SetupPerformanceBarChart> createState() => _SetupPerformanceBarChartState();
}

class _SetupPerformanceBarChartState extends State<SetupPerformanceBarChart> {
  Map<String, int> setupWins = {};
  List<String> setupNames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final data = await ApiService.fetchJournalData();
      Map<String, int> wins = {};
      for (var trade in data) {
        String setup = trade['Setup'] ?? 'Unknown';
        if (trade['Result'] == 'WIN') {
          wins[setup] = (wins[setup] ?? 0) + 1;
        }
      }
      setState(() {
        setupWins = wins;
        setupNames = wins.keys.toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading setup performance data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (setupNames.isEmpty) return Center(child: Text("No setup performance data", style: TextStyle(color: Colors.white70)));

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
          ),
        ),
      ),
    );
  }

  BarChartData mainBarData() {
    double maxWins = setupWins.values.isEmpty ? 10 : setupWins.values.reduce((a, b) => a > b ? a : b).toDouble() + 1;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxWins,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (double value, TitleMeta meta) {
              int index = value.toInt();
              if (index >= 0 && index < setupNames.length) {
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(setupNames[index], style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10)),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 10));
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(setupNames.length, (i) {
        return makeGroupData(i, setupWins[setupNames[i]]!.toDouble(), barColor: Colors.cyanAccent);
      }),
      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white10)),
    );
  }

  BarChartGroupData makeGroupData(int x, double y, {Color barColor = Colors.white}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
