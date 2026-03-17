import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WinRatePieChart extends StatefulWidget {
  const WinRatePieChart({super.key});

  @override
  State<WinRatePieChart> createState() => _WinRatePieChartState();
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

  void _loadData() async {
    try {
      final data = await ApiService.fetchJournalData();
      int w = 0;
      int l = 0;
      for (var trade in data) {
        if (trade['Result'] == 'WIN') {
          w++;
        } else if (trade['Result'] == 'LOSS') {
          l++;
        }
      }
      setState(() {
        wins = w;
        losses = l;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading winrate data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    int total = wins + losses;
    if (total == 0) return Center(child: Text("No trade data", style: TextStyle(color: Colors.white70)));

    double winPct = (wins / total) * 100;
    double lossPct = (losses / total) * 100;

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 18),
            Text("Win/Loss Distribution", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.greenAccent,
                        value: wins.toDouble(),
                        title: '${winPct.toStringAsFixed(1)}%',
                        radius: 50,
                        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: Colors.redAccent,
                        value: losses.toDouble(),
                        title: '${lossPct.toStringAsFixed(1)}%',
                        radius: 50,
                        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Indicator(color: Colors.greenAccent, text: 'Wins ($wins)', isSquare: true),
                  SizedBox(width: 12),
                  Indicator(color: Colors.redAccent, text: 'Losses ($losses)', isSquare: true),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;

  const Indicator({
    super.key,
    required this.color,
    required this.text,
    this.isSquare = true,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
        )
      ],
    );
  }
}
