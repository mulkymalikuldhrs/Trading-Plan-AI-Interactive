import 'package:flutter/material.dart';

class RiskCalculator extends StatefulWidget {
  @override
  _RiskCalculatorState createState() => _RiskCalculatorState();
}

class _RiskCalculatorState extends State<RiskCalculator> {
  double _accountSize = 10000;
  double _riskPercentage = 1;
  double _stopLossPips = 20;

  double get _riskAmount => _accountSize * (_riskPercentage / 100);
  double get _positionSize {
    if (_stopLossPips == 0) return 0;
    // Standard Forex calculation for 0.10/pip on 1 lot
    return (_riskAmount / _stopLossPips) / 10;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("⚖️ Position Sizer", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            SizedBox(height: 20),
            _buildInputField("Account Size", (val) => setState(() => _accountSize = double.tryParse(val) ?? 0), _accountSize.toString()),
            SizedBox(height: 12),
            _buildInputField("Risk (%)", (val) => setState(() => _riskPercentage = double.tryParse(val) ?? 0), _riskPercentage.toString()),
            SizedBox(height: 12),
            _buildInputField("Stop Loss (Pips)", (val) => setState(() => _stopLossPips = double.tryParse(val) ?? 0), _stopLossPips.toString()),
            SizedBox(height: 24),
            Divider(color: Colors.white24),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Risk Amount:", style: TextStyle(color: Colors.white70)),
                Text("\$${_riskAmount.toStringAsFixed(2)}", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Lot Size:", style: TextStyle(color: Colors.white70)),
                Text("${_positionSize.toStringAsFixed(2)} Lots", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, Function(String) onChanged, String initialValue) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
      ),
      onChanged: onChanged,
    );
  }
}
