import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class WinRatePieChart extends StatefulWidget {
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
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await ApiService.post('exportToJson', {'sheetName': 'Journal'});
      final List<dynamic> journal = (data is String) ? jsonDecode(data) : data;
      int w = 0;
      int l = 0;
      for (var trade in journal) {
        if (trade['result'] == 'WIN') w++;
        else if (trade['result'] == 'LOSS') l++;
      }
      setState(() {
        wins = w;
        losses = l;
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return CircularProgressIndicator();
    int total = wins + losses;
    if (total == 0) return Text("No trades yet");

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                color: Colors.greenAccent,
                value: wins.toDouble(),
                title: '${(wins/total*100).toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              PieChartSectionData(
                color: Colors.redAccent,
                value: losses.toDouble(),
                title: '${(losses/total*100).toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
