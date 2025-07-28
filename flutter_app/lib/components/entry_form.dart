import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EntryForm extends StatefulWidget {
  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _assetController = TextEditingController();
  final _entryPriceController = TextEditingController();
  final _stopLossController = TextEditingController();
  final _takeProfitController = TextEditingController();
  final _justificationController = TextEditingController();

  String _direction = 'LONG';
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
        'asset': _assetController.text,
        'direction': _direction,
        'strategy_name': 'London Breakout', // Example, this would be dynamic
        'entry_price': _entryPriceController.text,
        'stop_loss': _stopLossController.text,
        'take_profit': _takeProfitController.text,
        'rrr': '2.5', // Example, this would be calculated
        'mood': _mood,
        'justification': _justificationController.text,
      };

      try {
        final response = await ApiService.getGptFeedback('EntryValidation', 'temp-ref', tradeData);
        setState(() {
          _gptResponse = response;
        });
      } catch (e) {
        // Show error dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _assetController,
              decoration: InputDecoration(labelText: 'Asset (e.g., EURUSD)'),
              validator: (value) => value!.isEmpty ? 'Please enter an asset' : null,
            ),
            // ... other text form fields for entry, sl, tp, justification

            DropdownButtonFormField<String>(
              value: _direction,
              onChanged: (String? newValue) {
                setState(() {
                  _direction = newValue!;
                });
              },
              items: <String>['LONG', 'SHORT'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Direction'),
            ),

            // ... Mood dropdown

            SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Validate Setup'),
              ),

            if (_gptResponse != null) ...[
              SizedBox(height: 20),
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
      color: isValid ? Colors.green.shade100 : Colors.red.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Mentor Says: ${feedback['tough_love_feedback']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(feedback['detailed_explanation']),
            // ... display other feedback parts
          ],
        ),
      ),
    );
  }
}
