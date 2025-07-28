import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../responsive.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: DashboardMobile(),
      tablet: DashboardMobile(), // For simplicity, tablet will use mobile layout
      desktop: DashboardDesktop(),
    );
  }
}

// --- Mobile Layout ---
class DashboardMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            EmotionalOrb(),
            SizedBox(height: 20),
            WinRateCard(),
            SizedBox(height: 20),
            EquityCurveCard(),
          ],
        ),
      ),
    );
  }
}

// --- Desktop Layout ---
class DashboardDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MULKY AI OS - Desktop Dashboard")),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: EmotionalOrb(),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  WinRateCard(),
                  SizedBox(height: 20),
                  EquityCurveCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// --- Reusable Widgets ---

class EmotionalOrb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for the Rive animation
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bubble_chart, size: 150, color: Colors.amber),
            SizedBox(height: 20),
            Text("Emotional Orb", style: Theme.of(context).textTheme.headline5),
          ],
        ),
      ),
    );
  }
}

class WinRateCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 200,
        child: Center(child: Text("Win Rate Chart")),
      ),
    );
  }
}

class EquityCurveCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 200,
        child: Center(child: Text("Equity Curve Chart")),
      ),
    );
  }
}
