import 'package:flutter/material.dart';
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
          ForecastChart(),
          // Other forecast details...
        ],
      ),
    );
  }
}
