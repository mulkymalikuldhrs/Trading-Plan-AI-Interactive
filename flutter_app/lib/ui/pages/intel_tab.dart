import 'package:flutter/material.dart';
import '../../services/gpt_summarizer.dart';

class IntelTab extends StatefulWidget {
  const IntelTab({super.key});

  @override
  State<IntelTab> createState() => _IntelTabState();
}

class _IntelTabState extends State<IntelTab> {
  final String _selectedSymbol = "EURUSD";
  Map<String, dynamic>? _aiMasterData;
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
          _aiMasterData = summary;
        });
      }
    } catch (e) {
      debugPrint('IntelTab Error: $e');
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
                _buildNewsSection(),
                const SizedBox(height: 24),
                _buildCotSummary(),
                const SizedBox(height: 24),
                _buildAiMasterSummary(),
              ],
            ),
    );
  }

  Widget _buildNewsSection() {
    final newsHeadlines = _aiMasterData?['market_data']?['news_headlines'] as List<dynamic>?;

    return _buildIntelCard(
      title: "🌐 Top News",
      child: Column(
        children: newsHeadlines?.map((item) {
          final headline = item.toString();
          String source = 'News';
          String title = headline;

          if (headline.startsWith('[') && headline.contains(']')) {
            source = headline.substring(1, headline.indexOf(']'));
            title = headline.substring(headline.indexOf(']') + 1).trim();
          }

          return ListTile(
            title: Text(title),
            subtitle: Text(source),
            dense: true,
          );
        }).toList() ?? [const Text("No news found.")],
      ),
    );
  }

  Widget _buildCotSummary() {
    final cot = _aiMasterData?['market_data']?['cot_report'];
    final bias = cot?['bias'] ?? 'N/A';
    final netPosition = cot?['netPosition']?.toString() ?? '0';

    return _buildIntelCard(
      title: "📊 COT Intelligence",
      child: ListTile(
        title: Text("Institutional Bias: $bias"),
        subtitle: Text("Net Position: $netPosition"),
        trailing: Icon(
          bias.toString().toUpperCase() == 'BULLISH' ? Icons.arrow_upward : Icons.arrow_downward,
          color: bias.toString().toUpperCase() == 'BULLISH' ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildAiMasterSummary() {
    bool hasSignal = _aiMasterData?['signal']?['active'] ?? false;
    final confidence = _aiMasterData?['confidence_score'] ?? '0';
    final bias = _aiMasterData?['final_bias'] ?? 'NEUTRAL';

    return _buildIntelCard(
      title: "🎯 AI Master Summary",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bias: $bias (Confidence: $confidence/10)", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Technical: ${_aiMasterData?['technical_thesis'] ?? 'N/A'}"),
          Text("Fundamental: ${_aiMasterData?['fundamental_thesis'] ?? 'N/A'}"),
          Text("Positional: ${_aiMasterData?['positional_thesis'] ?? 'N/A'}"),
          if(hasSignal) ...[
            const SizedBox(height: 16),
            const Text("Recommended Signal:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
            Text("Entry: ${_aiMasterData?['signal']['entry'] ?? 'N/A'}"),
            Text("SL: ${_aiMasterData?['signal']['stop_loss'] ?? 'N/A'}"),
            Text("TP: ${_aiMasterData?['signal']['take_profit'] ?? 'N/A'}"),
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
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
