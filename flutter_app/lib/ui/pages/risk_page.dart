import 'package:flutter/material.dart';

class RiskPage extends StatelessWidget {
  const RiskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⚖️ Risk Engine"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: const Center(
        child: Text("Risk Page - Coming Soon!"),
      ),
    );
  }
}
