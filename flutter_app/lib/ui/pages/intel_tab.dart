import 'package:flutter/material.dart';
import '../../services/gpt_summarizer.dart';
import '../../services/news_fetcher.dart';
import '../../services/cot_service.dart';

class IntelTab extends StatefulWidget {
  @override
  _IntelTabState createState() => _IntelTabState();
}

class _IntelTabState extends State<IntelTab> {
  String _selectedSymbol = "EURUSD";
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
      setState(() {
        _aiSummary = summary;
        // In this version, news and COT data are aggregated by the AI
        // and presented in the Master Summary for a more cohesive experience.
        _news = null;
        _cotSummary = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching intelligence: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🧠 Market Intel Hub"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMarketIntel,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAiMasterSummary(),
                const SizedBox(height: 24),
                if (_news != null) _buildNewsSection(),
                if (_cotSummary != null) ...[
                  const SizedBox(height: 24),
                  _buildCotSummary(),
                ],
              ],
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
            Text(title, style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white)),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
