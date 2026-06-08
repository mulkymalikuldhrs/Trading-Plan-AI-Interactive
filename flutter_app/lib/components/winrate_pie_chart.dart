import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WinRatePieChart extends StatefulWidget {
  const WinRatePieChart({super.key});

  @override
  _WinRatePieChartState createState() => _WinRatePieChartState();
}

class _WinRatePieChartState extends State<WinRatePieChart> {
  int wins = 0;
  int losses = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final List<dynamic> journal = await ApiService.exportSheet('Journal');
      int w = 0;
      int l = 0;
      for (var trade in journal) {
        if (trade['Result'] == 'WIN') w++;
        if (trade['Result'] == 'LOSS') l++;
      }
      setState(() {
        wins = w;
        losses = l;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading winrate data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(color: Colors.greenAccent, value: wins.toDouble(), title: 'Wins', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              PieChartSectionData(color: Colors.redAccent, value: losses.toDouble(), title: 'Losses', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
