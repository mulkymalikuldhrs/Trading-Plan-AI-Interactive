import 'package:flutter/material.dart';
import '../../services/gpt_summarizer.dart';

class IntelTab extends StatefulWidget {
  @override
  _IntelTabState createState() => _IntelTabState();
}

class _IntelTabState extends State<IntelTab> {
  String _selectedSymbol = "EURUSD";
  Map<String, dynamic>? _aiSummary;
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
      if (mounted) {
        setState(() {
          _aiSummary = summary;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching market intel: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    final List<dynamic> newsHeadlines = _aiSummary?['news_headlines'] ?? [];

    return _buildIntelCard(
      title: "🌐 Top News",
      child: Column(
        children: newsHeadlines.isNotEmpty
            ? newsHeadlines.map((item) {
                final text = item.toString();
                final sourceMatch = RegExp(r'\[(.*?)\]').firstMatch(text);
                final source = sourceMatch?.group(1) ?? "News";
                final title = text.replaceFirst(RegExp(r'\[.*?\]\s*'), '');

                return ListTile(
                  title: Text(title),
                  subtitle: Text(source),
                  dense: true,
                );
              }).toList()
            : [Text("No news found.")],
      ),
    );
  }

  Widget _buildCotSummary() {
    final cotBias = _aiSummary?['final_bias'] ?? 'Neutral';
    final netPosition = _aiSummary?['positional_thesis'] ?? 'N/A';

    return _buildIntelCard(
      title: "🧠 COT Summary",
      child: ListTile(
        title: Text("Institutional Bias: $cotBias"),
        subtitle: Text("Thesis: $netPosition"),
        trailing: Icon(
          cotBias.toString().toUpperCase() == 'BULLISH' ? Icons.arrow_upward : (cotBias.toString().toUpperCase() == 'BEARISH' ? Icons.arrow_downward : Icons.horizontal_rule),
          color: cotBias.toString().toUpperCase() == 'BULLISH' ? Colors.green : (cotBias.toString().toUpperCase() == 'BEARISH' ? Colors.red : Colors.grey),
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
      color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
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
