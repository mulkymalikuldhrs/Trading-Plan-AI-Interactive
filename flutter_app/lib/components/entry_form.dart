import 'package:flutter/material.dart';
import './animated_button.dart';
import './trading_view_embed.dart';
import './mood_selector.dart';
import '../services/sheet_api.dart';
import '../services/gpt_service.dart';

class EntryForm extends StatefulWidget {
  const EntryForm({super.key});

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _assetController = TextEditingController(text: "EURUSD");
  final _directionController = TextEditingController();
  final _entryPriceController = TextEditingController();
  final _stopLossController = TextEditingController();
  final _takeProfitController = TextEditingController();
  final _setupController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedMood = 'Focused';
  String _selectedDirection = 'BUY';
  bool _showChart = false;
  bool _isSubmitting = false;
  bool _showAiFeedback = false;
  Map<String, dynamic>? _aiFeedback;

  final List<String> _directions = ['BUY', 'SELL'];

  void _onMoodSelected(String mood) {
    setState(() => _selectedMood = mood);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final tradeData = {
        'pair': _assetController.text.toUpperCase(),
        'direction': _selectedDirection,
        'entry': double.tryParse(_entryPriceController.text) ?? 0.0,
        'sl': double.tryParse(_stopLossController.text) ?? 0.0,
        'tp': double.tryParse(_takeProfitController.text) ?? 0.0,
        'setup': _setupController.text,
        'mood': _selectedMood,
        'ai_status': 'PENDING',
        'notes': _notesController.text,
      };

      // Calculate RRR
      final entry = double.tryParse(_entryPriceController.text) ?? 0.0;
      final sl = double.tryParse(_stopLossController.text) ?? 0.0;
      final tp = double.tryParse(_takeProfitController.text) ?? 0.0;
      final risk = (entry - sl).abs();
      final reward = (tp - entry).abs();
      final rrr = risk > 0 ? (reward / risk).toStringAsFixed(1) : '0.0';
      tradeData['rrr'] = rrr;

      await SheetApi.logTradeFromMap(tradeData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trade logged successfully! RRR: $rrr'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _showAiFeedback = false;
          _aiFeedback = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging trade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _getAiValidation() async {
    setState(() => _isSubmitting = true);
    try {
      final data = {
        'Pair': _assetController.text,
        'Direction': _selectedDirection,
        'Entry': _entryPriceController.text,
        'SL': _stopLossController.text,
        'TP': _takeProfitController.text,
        'Mood': _selectedMood,
        'Setup': _setupController.text,
      };
      final response = await GptService.getValidation(data);
      setState(() {
        _aiFeedback = response is Map<String, dynamic> ? response : {'feedback': response.toString()};
        _showAiFeedback = true;
      });
    } catch (e) {
      setState(() {
        _aiFeedback = {'error': 'Could not get AI validation. Check your connection.'};
        _showAiFeedback = true;
      });
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _assetController.dispose();
    _directionController.dispose();
    _entryPriceController.dispose();
    _stopLossController.dispose();
    _takeProfitController.dispose();
    _setupController.dispose();
    _notesController.dispose();
    super.dispose();
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
            // Asset/Pair
            TextFormField(
              controller: _assetController,
              decoration: const InputDecoration(
                labelText: 'Asset/Pair (e.g., FX:EURUSD)',
                prefixIcon: Icon(Icons.show_chart),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Enter asset pair' : null,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Direction
            DropdownButtonFormField<String>(
              value: _selectedDirection,
              decoration: const InputDecoration(
                labelText: 'Direction',
                prefixIcon: Icon(Icons.swap_vert),
              ),
              items: _directions
                  .map((dir) => DropdownMenuItem(
                        value: dir,
                        child: Text(dir),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedDirection = value!),
            ),
            const SizedBox(height: 16),

            // Entry Price
            TextFormField(
              controller: _entryPriceController,
              decoration: const InputDecoration(
                labelText: 'Entry Price',
                prefixIcon: Icon(Icons.trending_flat),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) => value == null || value.isEmpty ? 'Enter entry price' : null,
            ),
            const SizedBox(height: 16),

            // SL and TP in a row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stopLossController,
                    decoration: const InputDecoration(
                      labelText: 'Stop Loss',
                      prefixIcon: Icon(Icons.arrow_downward, color: Colors.red),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => value == null || value.isEmpty ? 'Enter SL' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _takeProfitController,
                    decoration: const InputDecoration(
                      labelText: 'Take Profit',
                      prefixIcon: Icon(Icons.arrow_upward, color: Colors.green),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => value == null || value.isEmpty ? 'Enter TP' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // RRR Display
            if (_entryPriceController.text.isNotEmpty &&
                _stopLossController.text.isNotEmpty &&
                _takeProfitController.text.isNotEmpty)
              _buildRrrCard(),
            const SizedBox(height: 16),

            // Setup Type
            TextFormField(
              controller: _setupController,
              decoration: const InputDecoration(
                labelText: 'Setup Type (e.g., Breakout, Pullback)',
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),

            // Mood Selector
            MoodSelector(onMoodSelected: _onMoodSelected),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes / Rationale',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Show Chart Button
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

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _getAiValidation,
                    icon: const Icon(Icons.psychology),
                    label: const Text('AI Validate'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: const Icon(Icons.save),
                    label: const Text('Log Trade'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            if (_isSubmitting)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (_showAiFeedback && _aiFeedback != null)
              _buildGptFeedbackCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildRrrCard() {
    final entry = double.tryParse(_entryPriceController.text) ?? 0.0;
    final sl = double.tryParse(_stopLossController.text) ?? 0.0;
    final tp = double.tryParse(_takeProfitController.text) ?? 0.0;
    final risk = (entry - sl).abs();
    final reward = (tp - entry).abs();
    final rrr = risk > 0 ? reward / risk : 0.0;

    return Card(
      color: rrr >= 2.0
          ? Colors.green.shade900.withValues(alpha: 0.3)
          : Colors.red.shade900.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Risk: ${risk.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent)),
            Text('Reward: ${reward.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent)),
            Text('RRR: ${rrr.toStringAsFixed(1)}', style: TextStyle(
              color: rrr >= 2.0 ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildGptFeedbackCard() {
    return Card(
      margin: const EdgeInsets.only(top: 24),
      elevation: 4,
      color: Colors.blueGrey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'AI Validation Feedback',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_aiFeedback!['error'] != null)
              Text(
                _aiFeedback!['error'],
                style: const TextStyle(color: Colors.redAccent),
              )
            else
              ..._aiFeedback!.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(color: Colors.white70),
                ),
              )),
          ],
        ),
      ),
    );
  }
}


