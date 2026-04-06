import 'package:flutter/material.dart';
import '../../services/gpt_summarizer.dart';

class IntelTab extends StatefulWidget {
  const IntelTab({super.key});

  @override
  State<IntelTab> createState() => _IntelTabState();
}

class _IntelTabState extends State<IntelTab> {
  final String _selectedSymbol = "EURUSD";
  Map<String, dynamic>? _aiSummary;
  List<Map<String, String>>? _news;
  Map<String, dynamic>? _cotSummary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarketIntel();
  }

  Future<void> _fetchMarketIntel() async {
    setState(() => _isLoading = true);
    try {
      final summary = await GptSummarizer.getAiMasterSummary(_selectedSymbol);

      // The backend 'getAiMasterSummary' in GAS now returns both the analysis
      // AND the rawData (technicals, news, COT) used for that analysis.
      // We map this for UI backward compatibility if needed, or update the UI.
      setState(() {
        _aiSummary = summary;
        // Map raw data from summary if present, otherwise handle gracefully
        if (summary.containsKey('rawData')) {
          final raw = summary['rawData'];
          _news = (raw['news_headlines'] as List?)?.map((h) => {'title': h.toString(), 'source': 'Finnhub'}).toList();
          _cotSummary = {
            'bias': raw['cot_report']?['bias'] ?? 'Neutral',
            'netPosition': raw['cot_report']?['signal'] ?? 'N/A'
          };
        }
      });
    } catch (e) {
      debugPrint("Error fetching intel: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🧠 Market Intel Hub"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchMarketIntel,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildNewsSection(),
                SizedBox(height: 24),
                _buildCotSummary(),
                SizedBox(height: 24),
                _buildAiMasterSummary(),
              ],
            ),
    );
  }

  Widget _buildNewsSection() {
    return _buildIntelCard(
      title: "🌐 Top News",
      child: Column(
        children: _news?.map((item) => ListTile(
          title: Text(item['title']!),
          subtitle: Text(item['source']!),
          dense: true,
        )).toList() ?? [Text("No news found.")],
      ),
    );
  }

  Widget _buildCotSummary() {
    return _buildIntelCard(
      title: "🧠 COT Summary",
      child: ListTile(
        title: Text("Institutional Bias: ${_cotSummary?['bias']}"),
        subtitle: Text("Net Position: ${_cotSummary?['netPosition']}"),
        trailing: Icon(
          _cotSummary?['bias'] == 'Bullish' ? Icons.arrow_upward : Icons.arrow_downward,
          color: _cotSummary?['bias'] == 'Bullish' ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildAiMasterSummary() {
    bool hasSignal = _aiSummary?['signal']?['active'] ?? false;
    return _buildIntelCard(
      title: "🎯 AI Master Summary",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bias: ${_aiSummary?['final_bias']} (Confidence: ${_aiSummary?['confidence_score']}/10)", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Technical: ${_aiSummary?['technical_thesis']}"),
          Text("Fundamental: ${_aiSummary?['fundamental_thesis']}"),
          Text("Positional: ${_aiSummary?['positional_thesis']}"),
          if(hasSignal) ...[
            SizedBox(height: 16),
            Text("Recommended Signal:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
            Text("Entry: ${_aiSummary?['signal']['entry']}"),
            Text("SL: ${_aiSummary?['signal']['stop_loss']}"),
            Text("TP: ${_aiSummary?['signal']['take_profit']}"),
          ]
        ],
      ),
    );
  }

  Widget _buildIntelCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      color: Colors.blueGrey[900]?.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
