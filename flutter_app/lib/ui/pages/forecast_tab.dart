import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../services/forecast_service.dart';
import '../../components/forecast_chart.dart';

class ForecastTab extends StatefulWidget {
  const ForecastTab({super.key});

  @override
  State<ForecastTab> createState() => _ForecastTabState();
}

class _ForecastTabState extends State<ForecastTab> {
  final String _selectedPair = 'EURUSD';
  final String _selectedTf = 'H4';
  final int _selectedDays = 7;
  Map<String, dynamic>? _forecastData;
  bool _isLoading = false;

  void _getForecast() async {
    setState(() => _isLoading = true);
    try {
      final data = await ForecastService.getForecast(
        pair: _selectedPair,
        timeframe: _selectedTf,
        days: _selectedDays,
      );
      setState(() => _forecastData = data);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🔮 Forecast Center™"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildControls(),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _forecastData != null
                    ? Expanded(child: _buildForecastDisplay())
                    : Text("Press 'Forecast' to begin."),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Dropdowns for pair, timeframe, days would go here
        ElevatedButton.icon(
          icon: Icon(Icons.show_chart),
          label: Text("Forecast"),
          onPressed: _getForecast,
        )
      ],
    );
  }

  Widget _buildForecastDisplay() {
    final forecast = _forecastData!;
    // In a real app, these would be parsed from a 'price_path' in the AI response
    // For now, we derive a simple visual path based on the bias and SL/TP
    final double entry = 1.0850; // Mock entry for visualization
    final double sl = double.tryParse(forecast['stop_loss'].toString()) ?? 0;
    final double tp = double.tryParse(forecast['take_profit'].toString()) ?? 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          ForecastChartWidget(
            historicalSpots: const [
              FlSpot(0, 1.0840),
              FlSpot(1, 1.0855),
              FlSpot(2, 1.0850),
            ],
            forecastSpots: [
              FlSpot(2, 1.0850),
              FlSpot(3, (entry + tp) / 2),
              FlSpot(4, tp),
            ],
            stopLoss: sl,
            takeProfit: tp,
          ),
          SizedBox(height: 24),
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final forecast = _forecastData!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("AI Forecast Summary", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text("Bias: ${forecast['bias']}"),
            Text("Entry Zone: ${forecast['entry_zone']}"),
            Text("Confirmation: ${forecast['confirmation']}"),
            Text("Stop Loss: ${forecast['stop_loss']}"),
            Text("Take Profit: ${forecast['take_profit']}"),
            Text("Probability: ${forecast['probability']}%"),
            Text("Tradeable: ${forecast['is_tradeable']}"),
          ],
        ),
      ),
    );
  }
}
