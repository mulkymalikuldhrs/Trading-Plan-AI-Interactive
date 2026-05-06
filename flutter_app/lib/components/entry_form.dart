import 'package:flutter/material.dart';
import '../services/gpt_service.dart';
import '../services/sheet_api.dart';
import './animated_button.dart';
import './trading_view_embed.dart';
import './mood_selector.dart';

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

  String _direction = 'BUY';
  String _setupType = 'FVG';
  String _mood = 'Calm';
  bool _showChart = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _gptFeedback;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final tradeData = {
      'Pair': _assetController.text,
      'Arah': _direction,
      'Entry': _entryController.text,
      'SL': _slController.text,
      'TP': _tpController.text,
      'Setup': _setupType,
      'Mood': _mood,
    };

    try {
      final feedback = await GptService.getValidation(tradeData);
      setState(() => _gptFeedback = feedback);

      if (feedback['is_valid_setup'] == true) {
         await SheetApi.logTrade({
           'pair': _assetController.text,
           'direction': _direction,
           'entry': double.parse(_entryController.text),
           'sl': double.parse(_slController.text),
           'tp': double.parse(_tpController.text),
           'rrr': (double.parse(_tpController.text) - double.parse(_entryController.text)).abs() / (double.parse(_entryController.text) - double.parse(_slController.text)).abs(),
           'setup': _setupType,
           'mood': _mood,
           'ai_status': 'Validated',
           'result': 'PENDING',
           'emotion_after': 'N/A',
           'gpt_comment': feedback['tough_love_feedback']
         });
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Trade Logged Successfully!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

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
              decoration: InputDecoration(labelText: 'Asset/Pair (e.g., EURUSD)', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _direction,
              decoration: InputDecoration(labelText: 'Direction', border: OutlineInputBorder()),
              items: ['BUY', 'SELL'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _direction = v!),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _entryController,
                    decoration: InputDecoration(labelText: 'Entry Price', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _slController,
                    decoration: InputDecoration(labelText: 'Stop Loss', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _tpController,
                    decoration: InputDecoration(labelText: 'Take Profit', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _setupType,
              decoration: InputDecoration(labelText: 'Setup Type', border: OutlineInputBorder()),
              items: ['FVG', 'BOS', 'CHoCH', 'S&D'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _setupType = v!),
            ),
            SizedBox(height: 16),
            MoodSelector(
              initialValue: _mood,
              onChanged: (v) => setState(() => _mood = v!),
            ),
            SizedBox(height: 24),
            AnimatedButton(
              text: _showChart ? 'Hide Chart' : '📊 Show Live Chart',
              onPressed: () => setState(() => _showChart = !_showChart),
            ),
            if (_showChart)
              Container(
                height: 400,
                margin: const EdgeInsets.only(top: 16),
                child: TradingViewEmbed(symbol: _assetController.text),
              ),
            SizedBox(height: 32),
            _isSubmitting
              ? Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.green),
                  onPressed: _submitForm,
                  child: Text("VALIDATE & LOG TRADE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
            if (_gptFeedback != null) _buildFeedbackCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Card(
      margin: EdgeInsets.only(top: 24),
      color: _gptFeedback!['is_valid_setup'] ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("AI FEEDBACK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Divider(),
            Text("Score: ${_gptFeedback!['validation_score']}/10", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(_gptFeedback!['tough_love_feedback'] ?? "No feedback provided."),
          ],
        ),
      ),
    );
  }
}
