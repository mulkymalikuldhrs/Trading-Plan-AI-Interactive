import 'package:flutter/material.dart';
import '../../services/forecast_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ForecastTab extends StatefulWidget {
  const ForecastTab({super.key});

  @override
  _ForecastTabState createState() => _ForecastTabState();
}

class _ForecastTabState extends State<ForecastTab> {
  List<dynamic> _forecasts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForecasts();
  }

  Future<void> _loadForecasts() async {
    setState(() => _isLoading = true);
    try {
      final data = await ForecastService.getRecentForecasts();
      setState(() {
        _forecasts = data;
      });
    } catch (e) {
      debugPrint("Forecast Load Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🔮 AI Price Forecasts")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _forecasts.isEmpty
              ? const Center(child: Text("No forecasts available."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _forecasts.length,
                  itemBuilder: (context, index) {
                    final f = _forecasts[index];
                    return _buildForecastCard(f);
                  },
                ),
    );
  }

  Widget _buildForecastCard(Map<String, dynamic> f) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blueGrey[900]?.withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(f['Pair'] ?? 'Unknown', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text("${f['Probability']}% Prob", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            Text("Bias: ${f['Bias']}", style: const TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceCol("Entry", f['Entry'].toString()),
                _buildPriceCol("SL", f['SL'].toString(), color: Colors.redAccent),
                _buildPriceCol("TP", f['TP'].toString(), color: Colors.greenAccent),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: LineChart(_buildPreviewChart()),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCol(String label, String value, {Color color = Colors.white70}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  LineChartData _buildPreviewChart() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 1),
            FlSpot(1, 1.5),
            FlSpot(2, 1.4),
            FlSpot(3, 2),
            FlSpot(4, 1.8),
            FlSpot(5, 2.5),
          ],
          isCurved: true,
          color: Colors.blueAccent,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withValues(alpha: 0.1)),
        ),
      ],
    );
  }
}
