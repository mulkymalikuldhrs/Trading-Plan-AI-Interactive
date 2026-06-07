import 'package:flutter/material.dart';
import '../../services/gpt_summarizer.dart';

class IntelTab extends StatefulWidget {
  @override
  _IntelTabState createState() => _IntelTabState();
}

class _IntelTabState extends State<IntelTab> {
  String _selectedSymbol = "EURUSD";
  Map<String, dynamic>? _marketIntel;
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
      final intel = await GptSummarizer.getAiMasterSummary(_selectedSymbol);
      if (mounted) {
        setState(() {
          _marketIntel = intel;
        });
      }
    } catch (e) {
      debugPrint('Error fetching market intel: $e');
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
    final List<dynamic> news = _marketIntel?['news_headlines'] ?? [];
    return _buildIntelCard(
      title: "🌐 Top News",
      child: Column(
        children: news.isNotEmpty
            ? news.map((item) {
                final headline = item.toString();
                final source = headline.contains('[') ? headline.split(']')[0].replaceAll('[', '') : 'News';
                return ListTile(
                  title: Text(headline),
                  subtitle: Text(source),
                  dense: true,
                );
              }).toList()
            : [Text("No news found.")],
      ),
    );
  }

  Widget _buildCotSummary() {
    final bias = _marketIntel?['final_bias'] ?? 'N/A';
    final netPosition = (_marketIntel?['positional_thesis'] ?? 'N/A').toString();

    return _buildIntelCard(
      title: "🧠 COT Summary",
      child: ListTile(
        title: Text("Institutional Bias: $bias"),
        subtitle: Text("Thesis: $netPosition"),
        trailing: Icon(
          bias.toString().toUpperCase().contains('BULL')
              ? Icons.arrow_upward
              : bias.toString().toUpperCase().contains('BEAR')
                  ? Icons.arrow_downward
                  : Icons.horizontal_rule,
          color: bias.toString().toUpperCase().contains('BULL')
              ? Colors.green
              : bias.toString().toUpperCase().contains('BEAR')
                  ? Colors.red
                  : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildAiMasterSummary() {
    bool hasSignal = _marketIntel?['signal']?['active'] ?? false;
    return _buildIntelCard(
      title: "🎯 AI Master Summary",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "Bias: ${_marketIntel?['final_bias'] ?? 'N/A'} (Confidence: ${_marketIntel?['confidence_score'] ?? '0'}/10)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Technical: ${_marketIntel?['technical_thesis'] ?? 'N/A'}"),
          Text("Fundamental: ${_marketIntel?['fundamental_thesis'] ?? 'N/A'}"),
          Text("Positional: ${_marketIntel?['positional_thesis'] ?? 'N/A'}"),
          if (hasSignal) ...[
            SizedBox(height: 16),
            Text("Recommended Signal:",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
            Text("Entry: ${_marketIntel?['signal']['entry']}"),
            Text("SL: ${_marketIntel?['signal']['stop_loss']}"),
            Text("TP: ${_marketIntel?['signal']['take_profit']}"),
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
