import 'package:flutter/material.dart';

class RiskCalculator extends StatelessWidget {
  const RiskCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Risk Calculator", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            const Text("Coming Soon!"),
          ],
        ),
      ),
    );
  }
}
