import 'package:flutter/material.dart';

class RiskCalculator extends StatefulWidget {
  @override
  _RiskCalculatorState createState() => _RiskCalculatorState();
}

class _RiskCalculatorState extends State<RiskCalculator> {
  final _balanceController = TextEditingController(text: "10000");
  final _riskPercentController = TextEditingController(text: "1");
  final _stopLossController = TextEditingController(text: "20");
  double _lotSize = 0;

  void _calculate() {
    double balance = double.tryParse(_balanceController.text) ?? 0;
    double riskPercent = double.tryParse(_riskPercentController.text) ?? 0;
    double stopLossPips = double.tryParse(_stopLossController.text) ?? 0;

    if (stopLossPips > 0) {
      double riskAmount = balance * (riskPercent / 100);
      setState(() {
        _lotSize = riskAmount / (stopLossPips * 10);
      });
    }
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Risk Calculator", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            SizedBox(height: 16),
            TextField(
              controller: _balanceController,
              decoration: InputDecoration(labelText: "Account Balance (\$)", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _riskPercentController,
              decoration: InputDecoration(labelText: "Risk %", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _stopLossController,
              decoration: InputDecoration(labelText: "Stop Loss (pips)", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: _calculate,
              child: Text("CALCULATE LOT SIZE")
            ),
            if (_lotSize > 0) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  "Recommended Lot Size: ${_lotSize.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                  textAlign: TextAlign.center,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
