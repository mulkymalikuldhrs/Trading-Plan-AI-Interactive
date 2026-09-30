import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SetupPerformanceBarChart extends StatefulWidget {
  const SetupPerformanceBarChart({super.key});

  @override
  @override
  State<SetupPerformanceBarChart> createState() => _SetupPerformanceBarChartState();
}

class _SetupPerformanceBarChartState extends State<SetupPerformanceBarChart> {
  Map<String, int> setupCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final List<dynamic> journal = await ApiService.exportSheet('Journal');
      Map<String, int> counts = {};
      for (var trade in journal) {
        String setup = trade['Setup'] ?? 'Unknown';
        counts[setup] = (counts[setup] ?? 0) + 1;
      }
      setState(() {
        setupCounts = counts;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading setup performance data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final List<String> setups = setupCounts.keys.toList();
    final List<BarChartGroupData> barGroups = List.generate(setups.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: setupCounts[setups[i]]!.toDouble(),
            color: Colors.lightBlueAccent,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    });

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (setupCounts.values.isEmpty ? 10 : setupCounts.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < 0 || value.toInt() >= setups.length) return Container();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4,
                        child: Text(
                          setups[value.toInt()],
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ),
    );
  }
}
