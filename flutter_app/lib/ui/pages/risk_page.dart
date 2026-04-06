import 'package:flutter/material.dart';
import '../widgets/risk_calculator.dart';

class RiskPage extends StatelessWidget {
  const RiskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("⚖️ Risk Engine"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
             RiskCalculator(),
             SizedBox(height: 32),
             _buildTipCard(
               "Why Position Sizing Matters",
               "Using a fixed percentage (e.g., 1-2% per trade) ensures that you don't blow your account during a losing streak. The AI will monitor your risk and activate a lockout if you break these rules.",
               Icons.info_outline
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String content, IconData icon) {
    return Card(
      color: Colors.blueGrey[900]?.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.cyanAccent),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  SizedBox(height: 8),
                  Text(content, style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
