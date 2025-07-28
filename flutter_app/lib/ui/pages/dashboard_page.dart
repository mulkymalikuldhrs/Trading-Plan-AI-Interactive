import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart'; // Placeholder for charts

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📊 Performance Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Win Rate", style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 10),
            // Placeholder for Win Rate Chart
            Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(child: Text("Win Rate Chart - Coming Soon")),
            ),
            SizedBox(height: 20),
            Text("Equity Curve", style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 10),
            // Placeholder for Equity Curve Chart
            Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(child: Text("Equity Curve - Coming Soon")),
            ),
            SizedBox(height: 20),
            Text("Mood Tracker", style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 10),
            // Placeholder for Mood Tracker
            Container(
              height: 100,
              color: Colors.grey[300],
              child: Center(child: Text("Mood Tracker - Coming Soon")),
            ),
          ],
        ),
      ),
    );
  }
}
