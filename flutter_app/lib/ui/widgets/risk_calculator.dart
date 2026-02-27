import 'package:flutter/material.dart';

class RiskCalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Risk Calculator", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            Text("Coming Soon!"),
          ],
        ),
      ),
    );
  }
}
