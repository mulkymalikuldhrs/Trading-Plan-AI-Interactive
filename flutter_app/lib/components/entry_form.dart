import 'package:flutter/material.dart';
import '../services/gpt_service.dart';
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
  // ... other controllers

  bool _showChart = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ... all other form fields ...
          TextFormField(
            controller: _assetController,
            decoration: InputDecoration(labelText: 'Asset/Pair (e.g., FX:EURUSD)'),
            onChanged: (value) => setState(() {}), // Rebuild to update chart symbol
          ),
          SizedBox(height: 16),

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
          // ... rest of the form ...
        ],
      ),
    );
  }

  // ... _submitForm and _buildGptFeedbackCard methods ...
}
