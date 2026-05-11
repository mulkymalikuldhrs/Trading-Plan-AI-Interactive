import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../components/forecast_chart.dart';

class ForecastTab extends StatefulWidget {
  @override
  _ForecastTabState createState() => _ForecastTabState();
}

class _ForecastTabState extends State<ForecastTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text("🔮 AI Probabilistic Forecast", style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 20),
          ForecastChart(
            spots: const [
              FlSpot(0, 1.0850),
              FlSpot(1, 1.0865),
              FlSpot(2, 1.0855),
              FlSpot(3, 1.0870),
              FlSpot(4, 1.0880),
            ],
            label: 'EURUSD H4',
          ),
          // Other forecast details...
        ],
      ),
    );
  }
}
