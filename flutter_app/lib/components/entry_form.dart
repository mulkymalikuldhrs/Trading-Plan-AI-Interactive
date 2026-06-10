import 'package:flutter/material.dart';
import '../services/sheet_api.dart';
import '../services/gpt_summarizer.dart';
import '../services/emotional_lockout_service.dart';
import 'package:provider/provider.dart';
import 'mood_selector.dart';
import 'trading_view_embed.dart';

class EntryForm extends StatefulWidget {
  const EntryForm({super.key});

  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _pairController = TextEditingController(text: "EURUSD");
  final _entryController = TextEditingController();
  final _slController = TextEditingController();
  final _tpController = TextEditingController();
  final _notesController = TextEditingController();
  String _direction = "BUY";
  String _setup = "Breakout";
  String _mood = "Neutral";
  bool _isValidating = false;
  String _aiFeedback = "";
  bool _showChart = false;

  Future<void> _validateWithAI() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isValidating = true;
      _aiFeedback = "AI is analyzing your setup...";
    });

    try {
      final feedback = await GptSummarizer.validateTrade(
        pair: _pairController.text,
        direction: _direction,
        entry: _entryController.text,
        sl: _slController.text,
        tp: _tpController.text,
        setup: _setup,
        mood: _mood,
      );

      setState(() {
        _aiFeedback = feedback['analysis'] ?? "No analysis provided.";
      });
    } catch (e) {
      setState(() {
        _aiFeedback = "AI Validation failed. Check connection.";
      });
    } finally {
      setState(() => _isValidating = false);
    }
  }

  Future<void> _submitTrade() async {
    final lockout = Provider.of<EmotionalLockoutService>(context, listen: false);
    if (lockout.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚨 LOCKOUT ACTIVE: You cannot trade right now."), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    try {
      await SheetApi.logTradeFromMap({
        'pair': _pairController.text,
        'direction': _direction,
        'entry': _entryController.text,
        'sl': _slController.text,
        'tp': _tpController.text,
        'setup': _setup,
        'mood': _mood,
        'ai_status': _aiFeedback.isNotEmpty ? "Validated" : "Self-Entry",
        'gpt_comment': _aiFeedback,
        'notes': _notesController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Trade logged successfully!"), backgroundColor: Colors.green),
        );
      }
      _formKey.currentState!.reset();
      setState(() {
        _aiFeedback = "";
        _pairController.text = "EURUSD";
        _direction = "BUY";
        _setup = "Breakout";
        _mood = "Neutral";
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to log trade."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Validate New Trade Setup", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pairController,
                    decoration: const InputDecoration(labelText: "Asset Pair", border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _direction,
                    items: ["BUY", "SELL"].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setState(() => _direction = v!),
                    decoration: const InputDecoration(labelText: "Direction", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _entryController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Entry Price", border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _slController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Stop Loss", border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _tpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Take Profit", border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _setup,
              items: ["Breakout", "Retest", "Trendline", "Scalp", "News"]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _setup = v!),
              decoration: const InputDecoration(labelText: "Setup Type", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            MoodSelector(
              currentMood: _mood,
              onMoodChanged: (m) => setState(() => _mood = m),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: "Trade Notes", border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isValidating ? null : _validateWithAI,
              icon: _isValidating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.psychology),
              label: const Text("GET AI VALIDATION"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.deepPurple),
            ),
            if (_aiFeedback.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.deepPurple)),
                child: Text(_aiFeedback, style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showChart = !_showChart),
                    child: Text(_showChart ? "HIDE CHART" : "SHOW CHART"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitTrade,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("LOG TRADE"),
                  ),
                ),
              ],
            ),
            if (_showChart) ...[
              const SizedBox(height: 20),
              SizedBox(
                height: 400,
                child: TradingViewEmbed(symbol: _pairController.text),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
