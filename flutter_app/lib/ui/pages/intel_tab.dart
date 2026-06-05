import 'package:flutter/material.dart';
import '../../services/gpt_summarizer.dart';

class IntelTab extends StatefulWidget {
  @override
  _IntelTabState createState() => _IntelTabState();
}

class _IntelTabState extends State<IntelTab> {
  String _selectedSymbol = "EURUSD";
  Map<String, dynamic>? _aiMasterSummary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarketIntel();
  }

  Future<void> _fetchMarketIntel() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final summary = await GptSummarizer.getAiMasterSummary(_selectedSymbol);
      if (mounted) {
        setState(() {
          _aiMasterSummary = summary;
        });
      }
    } catch (e) {
      debugPrint("Error fetching market intel: $e");
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
    // Assuming the backend returns news_headlines or similar in the master summary
    // If not explicitly there, we default to N/A or empty
    final headlines = _aiMasterSummary?['news_headlines'] as List?;

    return _buildIntelCard(
      title: "🌐 Top News",
      child: Column(
        children: headlines?.map((item) {
          final String headline = item.toString();
          final String source = headline.contains('[') && headline.contains(']')
              ? headline.substring(headline.indexOf('[') + 1, headline.indexOf(']'))
              : 'News';
          final String title = headline.contains(']')
              ? headline.substring(headline.indexOf(']') + 1).trim()
              : headline;

          return ListTile(
            title: Text(title),
            subtitle: Text(source),
            dense: true,
          );
        }).toList() ?? [Text("No news found.")],
      ),
    );
  }

  Widget _buildCotSummary() {
    final cot = _aiMasterSummary?['cot_raw'];
    final bias = _aiMasterSummary?['positional_thesis'] ?? 'N/A';

    return _buildIntelCard(
      title: "📊 COT Intelligence",
      child: ListTile(
        title: Text("Bias: $bias"),
        subtitle: Text("Longs: ${cot?['nonCommercialLong'] ?? 0} | Shorts: ${cot?['nonCommercialShort'] ?? 0}"),
        trailing: Icon(
          bias.toString().toLowerCase().contains('bullish') ? Icons.arrow_upward : Icons.arrow_downward,
          color: bias.toString().toLowerCase().contains('bullish') ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildAiMasterSummary() {
    bool hasSignal = _aiMasterSummary?['signal']?['active'] ?? false;
    return _buildIntelCard(
      title: "🎯 AI Master Summary",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Final Bias: ${_aiMasterSummary?['final_bias'] ?? 'N/A'} (Confidence: ${_aiMasterSummary?['confidence_score'] ?? 0}/10)",
               style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Technical Thesis: ${_aiMasterSummary?['technical_thesis'] ?? 'N/A'}"),
          SizedBox(height: 4),
          Text("Fundamental Thesis: ${_aiMasterSummary?['fundamental_thesis'] ?? 'N/A'}"),
          if(hasSignal) ...[
            SizedBox(height: 16),
            Text("Recommended Signal:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
            Text("Entry: ${_aiMasterSummary?['signal']['entry'] ?? 'N/A'}"),
            Text("SL: ${_aiMasterSummary?['signal']['stop_loss'] ?? 'N/A'}"),
            Text("TP: ${_aiMasterSummary?['signal']['take_profit'] ?? 'N/A'}"),
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
