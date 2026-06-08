import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../components/forecast_chart.dart';
import '../../services/forecast_service.dart';

class ForecastTab extends StatefulWidget {
  const ForecastTab({super.key});

  @override
  _ForecastTabState createState() => _ForecastTabState();
}

class _ForecastTabState extends State<ForecastTab> {
  List<FlSpot> _forecastSpots = [];
  Map<String, dynamic>? _forecastData;
  bool _isLoading = false;
  String _selectedPair = 'EURUSD';
  String? _error;

  final List<String> _pairs = ['EURUSD', 'GBPUSD', 'USDJPY', 'XAUUSD', 'AUDUSD'];

  Future<void> _loadForecast() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final forecast = await ForecastService.getForecast(
        pair: _selectedPair,
        timeframe: 'H4',
        days: 7,
      );

      if (forecast['error'] != null) {
        setState(() {
          _error = forecast['error'];
          _isLoading = false;
        });
        return;
      }

      // Parse forecast data into chart spots
      List<FlSpot> spots = [];
      if (forecast['price_points'] != null) {
        final List<dynamic> points = forecast['price_points'];
        for (int i = 0; i < points.length; i++) {
          final double price = (points[i] as num).toDouble();
          spots.add(FlSpot(i.toDouble(), price));
        }
      }

      // If no price points, derive from entry_zone and bias
      if (spots.isEmpty && forecast['entry_zone'] != null) {
        final entryStr = forecast['entry_zone'].toString();
        final entryPrice = double.tryParse(entryStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 1.0850;
        final bias = forecast['bias']?.toString().toUpperCase() ?? 'NEUTRAL';
        final direction = bias == 'BULLISH' ? 1 : bias == 'BEARISH' ? -1 : 0;
        for (int i = 0; i < 7; i++) {
          spots.add(FlSpot(i.toDouble(), entryPrice + direction * 0.001 * i));
        }
      }

      setState(() {
        _forecastData = forecast;
        _forecastSpots = spots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load forecast data.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🔮 AI Probabilistic Forecast", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          // Pair selector
          DropdownButtonFormField<String>(
            initialValue: _selectedPair,
            decoration: const InputDecoration(
              labelText: 'Select Pair',
              border: OutlineInputBorder(),
            ),
            items: _pairs.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPair = value);
              }
            },
          ),
          const SizedBox(height: 16),

          // Load forecast button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadForecast,
              icon: const Icon(Icons.refresh),
              label: const Text('Load Forecast'),
            ),
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            _buildErrorState()
          else if (_forecastSpots.isNotEmpty)
            _buildForecastChart()
          else
            _buildEmptyState(),

          if (_forecastData != null) ...[
            const SizedBox(height: 20),
            _buildForecastDetails(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.query_stats, size: 48, color: Colors.white38),
            SizedBox(height: 16),
            Text(
              'Select a pair and click "Load Forecast" to view AI predictions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Card(
      color: Colors.red.shade900.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_error ?? 'An error occurred', textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_selectedPair H4 Forecast',
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ForecastChart(
          spots: _forecastSpots,
          label: '$_selectedPair H4',
        ),
      ],
    );
  }

  Widget _buildForecastDetails() {
    final data = _forecastData!;
    return Card(
      color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Forecast Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16)),
            const SizedBox(height: 12),
            _buildDetailRow('Bias', data['bias']?.toString() ?? 'N/A'),
            _buildDetailRow('Probability', '${data['probability'] ?? 'N/A'}%'),
            _buildDetailRow('Entry Zone', data['entry_zone']?.toString() ?? 'N/A'),
            _buildDetailRow('Stop Loss', data['stop_loss']?.toString() ?? 'N/A'),
            _buildDetailRow('Take Profit', data['take_profit']?.toString() ?? 'N/A'),
            _buildDetailRow('Tradeable', data['is_tradeable'] == true ? 'Yes ✅' : 'No ❌'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
