import 'package:flutter/material.dart';
import '../widgets/risk_calculator.dart';

class RiskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("⚖️ Risk Engine"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            RiskCalculator(),
            SizedBox(height: 24),
            _buildRuleCard(
              context,
              "Discipline Rules",
              [
                "Maximum 1% risk per trade.",
                "Maximum 3 concurrent open positions.",
                "Mandatory break after 3 consecutive losses.",
                "No trading during high-impact red folder news.",
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, String title, List<String> rules) {
    return Card(
      color: Colors.blueGrey[900]?.withValues(alpha: 0.3),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.amber)),
            SizedBox(height: 12),
            ...rules.map((rule) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: Colors.greenAccent),
                  SizedBox(width: 8),
                  Expanded(child: Text(rule, style: TextStyle(color: Colors.white70))),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
