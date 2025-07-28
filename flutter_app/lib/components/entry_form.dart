import 'package:flutter/material.dart';
import '../services/gpt_service.dart';
import '../components/mood_selector.dart';
import '../components/animated_button.dart';

class EntryForm extends StatefulWidget {
  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _assetController = TextEditingController(text: "XAU/USD");
  final _entryPriceController = TextEditingController(text: "2300.50");
  final _stopLossController = TextEditingController(text: "2295.50");
  final _takeProfitController = TextEditingController(text: "2315.50");
  final _setupController = TextEditingController(text: "FVG + BOS");

  String _direction = 'Buy';
  String _mood = 'Focused';
  bool _isLoading = false;
  Map<String, dynamic>? _gptResponse;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _gptResponse = null;
      });

      final tradeData = {
        'Pair': _assetController.text,
        'Arah': _direction,
        'SL': _stopLossController.text,
        'TP': _takeProfitController.text,
        'Mood': _mood,
        'Setup': _setupController.text,
      };

      try {
        final response = await GptService.getValidation(tradeData);
        setState(() {
          _gptResponse = response;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(controller: _assetController, decoration: InputDecoration(labelText: 'Asset/Pair')),
            TextFormField(controller: _entryPriceController, decoration: InputDecoration(labelText: 'Entry Price'), keyboardType: TextInputType.number),
            TextFormField(controller: _stopLossController, decoration: InputDecoration(labelText: 'Stop Loss'), keyboardType: TextInputType.number),
            TextFormField(controller: _takeProfitController, decoration: InputDecoration(labelText: 'Take Profit'), keyboardType: TextInputType.number),
            TextFormField(controller: _setupController, decoration: InputDecoration(labelText: 'Setup Confluence')),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _direction,
              onChanged: (v) => setState(() => _direction = v!),
              items: ['Buy', 'Sell'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            ),
            SizedBox(height: 16),
            MoodSelector(onMoodSelected: (mood) => setState(() => _mood = mood)),
            SizedBox(height: 32),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              AnimatedButton(text: 'Validate with AI Coach', onPressed: _submitForm),
            if (_gptResponse != null) ...[
              SizedBox(height: 24),
              _buildGptFeedbackCard(_gptResponse!),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildGptFeedbackCard(Map<String, dynamic> feedback) {
    bool isValid = feedback['is_valid_setup'] ?? false;
    return Card(
      color: isValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isValid ? Colors.green : Colors.red, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🤖 AI Mentor Says:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text('"${feedback['tough_love_feedback']}"', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white70)),
            SizedBox(height: 12),
            Text(feedback['detailed_explanation'], style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Chip(label: Text('Score: ${feedback['validation_score']}/10')),
          ],
        ),
      ),
    );
  }
}
