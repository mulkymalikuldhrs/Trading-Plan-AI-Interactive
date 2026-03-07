import 'package:flutter/material.dart';

class RiskCalculator extends StatefulWidget {
  const RiskCalculator({super.key});

  @override
  State<RiskCalculator> createState() => _RiskCalculatorState();
}

class _RiskCalculatorState extends State<RiskCalculator> {
  final _balanceController = TextEditingController(text: "10000");
  final _riskPctController = TextEditingController(text: "1");
  final _stopLossPipsController = TextEditingController(text: "20");

  double _positionSize = 0.0;
  double _amountAtRisk = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateRisk();
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _riskPctController.dispose();
    _stopLossPipsController.dispose();
    super.dispose();
  }

  void _calculateRisk() {
    double balance = double.tryParse(_balanceController.text) ?? 0.0;
    double riskPct = double.tryParse(_riskPctController.text) ?? 0.0;
    double slPips = double.tryParse(_stopLossPipsController.text) ?? 0.0;

    if (balance > 0 && riskPct > 0 && slPips > 0) {
      setState(() {
        _amountAtRisk = balance * (riskPct / 100);
        // Position size for standard lots (1 lot = $10 per pip for EURUSD)
        // formula: position_size = amount_at_risk / (sl_pips * pip_value)
        _positionSize = _amountAtRisk / (slPips * 10);
      });
    } else {
      setState(() {
        _amountAtRisk = 0.0;
        _positionSize = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "⚖️ Position Sizer",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            TextFormField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Account Balance (\$)",
                prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.white70),
              ),
              onChanged: (_) => _calculateRisk(),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _riskPctController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Risk Percentage (%)",
                prefixIcon: Icon(Icons.percent, color: Colors.white70),
              ),
              onChanged: (_) => _calculateRisk(),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _stopLossPipsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Stop Loss (Pips)",
                prefixIcon: Icon(Icons.straighten, color: Colors.white70),
              ),
              onChanged: (_) => _calculateRisk(),
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  _buildResultRow("Amount at Risk", "\$${_amountAtRisk.toStringAsFixed(2)}", Colors.redAccent),
                  Divider(color: Colors.white10, height: 24),
                  _buildResultRow("Position Size", "${_positionSize.toStringAsFixed(2)} Lots", Colors.greenAccent),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              "*Calculation assumes 1 Standard Lot = \$10/pip (e.g., EUR/USD)",
              style: TextStyle(color: Colors.white54, fontSize: 10, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 16)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
