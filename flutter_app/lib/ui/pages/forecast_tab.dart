import 'package:flutter/material.dart';
import '../../services/forecast_service.dart';
import '../../components/forecast_chart.dart';

class ForecastTab extends StatefulWidget {
  @override
  _ForecastTabState createState() => _ForecastTabState();
}

class _ForecastTabState extends State<ForecastTab> {
  final String _selectedPair = 'EURUSD';
  Map<String, dynamic>? _forecastData;
  bool _isLoading = false;

  void _getForecast() async {
    setState(() => _isLoading = true);
    try {
      final data = await ForecastService.getForecast(_selectedPair);
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
        ElevatedButton.icon(
          icon: Icon(Icons.show_chart),
          label: Text("Forecast"),
          onPressed: _getForecast,
        )
      ],
    );
  }

  Widget _buildForecastDisplay() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ForecastChartWidget(),
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
