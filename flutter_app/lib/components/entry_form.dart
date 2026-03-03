import 'package:flutter/material.dart';
import '../services/gpt_service.dart';
import '../services/api_service.dart';
import './mood_selector.dart';
import './animated_button.dart';
import './trading_view_embed.dart';

class EntryForm extends StatefulWidget {
  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _assetController = TextEditingController(text: "EURUSD");
  final _entryController = TextEditingController();
  final _slController = TextEditingController();
  final _tpController = TextEditingController();
  final _setupController = TextEditingController();

  @override
  void dispose() {
    _assetController.dispose();
    _entryController.dispose();
    _slController.dispose();
    _tpController.dispose();
    _setupController.dispose();
    super.dispose();
  }

  String _direction = 'BUY';
  String _mood = 'Focused';
  bool _isLoading = false;
  Map<String, dynamic>? _gptFeedback;

  bool _showChart = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _assetController,
              decoration: InputDecoration(labelText: 'Asset/Pair (e.g., FX:EURUSD)'),
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _direction,
              onChanged: (val) => setState(() => _direction = val!),
              items: ['BUY', 'SELL'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              decoration: InputDecoration(labelText: 'Direction'),
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _entryController,
                    decoration: InputDecoration(labelText: 'Entry Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _slController,
                    decoration: InputDecoration(labelText: 'Stop Loss'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _tpController,
                    decoration: InputDecoration(labelText: 'Take Profit'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _setupController,
              decoration: InputDecoration(labelText: 'Setup Name (e.g., H4 Breakout)'),
            ),
            SizedBox(height: 16),

            MoodSelector(onMoodSelected: (mood) => _mood = mood),
            SizedBox(height: 24),

            AnimatedButton(
              text: _showChart ? 'Hide Chart' : '📊 Show Live Chart',
              onPressed: () => setState(() => _showChart = !_showChart),
            ),

            if (_showChart)
              Container(
                height: 450,
                margin: const EdgeInsets.only(top: 16),
                child: TradingViewEmbed(symbol: _assetController.text),
              ),

            SizedBox(height: 32),

            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submitForm,
                child: Text('Validate with AI', style: TextStyle(fontSize: 18)),
              ),

            if (_gptFeedback != null) _buildGptFeedbackCard(),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _gptFeedback = null;
      });

      final tradeData = {
        'Pair': _assetController.text,
        'Arah': _direction,
        'Entry': _entryController.text,
        'SL': _slController.text,
        'TP': _tpController.text,
        'Mood': _mood,
        'Setup': _setupController.text,
      };

      try {
        final feedback = await GptService.getValidation(tradeData);
        setState(() {
          _gptFeedback = feedback;
          _isLoading = false;
        });

        // If valid, log the trade to the journal
        if (feedback['is_valid_setup'] == true) {
           await ApiService.post('logTrade', {
             'pair': _assetController.text,
             'direction': _direction,
             'entry': _entryController.text,
             'sl': _slController.text,
             'tp': _tpController.text,
             'rrr': 'To be calc', // We could calculate this
             'setup': _setupController.text,
             'mood': _mood,
             'ai_status': 'VALIDATED',
             'result': 'PENDING',
             'emotion_after': 'N/A',
             'gpt_comment': feedback['tough_love_feedback'],
           });
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Trade Logged Successfully!")));
        }

      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Widget _buildGptFeedbackCard() {
    return Card(
      margin: EdgeInsets.only(top: 24),
      color: Colors.blueGrey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("🧠 AI Feedback", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("Score: ${_gptFeedback!['validation_score']}/10", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(color: Colors.white24),
            Text("Verdict:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            Text(
              _gptFeedback!['is_valid_setup'] ? "✅ HIGH CONVICTION" : "❌ AVOID THIS TRADE",
              style: TextStyle(fontSize: 16, color: _gptFeedback!['is_valid_setup'] ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text("Tough Love:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            Text(_gptFeedback!['tough_love_feedback'] ?? "No feedback provided.", style: TextStyle(color: Colors.white)),
            SizedBox(height: 12),
            if (_gptFeedback!['rule_violations'] != null && (_gptFeedback!['rule_violations'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rule Violations:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ...(_gptFeedback!['rule_violations'] as List).map((v) => Text("• $v", style: TextStyle(color: Colors.white))),
                  SizedBox(height: 12),
                ],
              ),
            Text("Explanation:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            Text(_gptFeedback!['detailed_explanation'] ?? "", style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
