import 'package:flutter/material.dart';
import '../responsive.dart';
import '../../components/equity_chart.dart';
import '../../components/winrate_pie_chart.dart';
import '../../components/setup_performance_barchart.dart';
import '../../components/consistency_streak_calendar.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📈 Dashboard of Discipline™"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Responsive(
        mobile: DashboardMobileLayout(),
        tablet: DashboardTabletLayout(),
        desktop: DashboardDesktopLayout(),
      ),
    );
  }
}

// --- Layouts ---

class DashboardMobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Equity Curve", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
          SizedBox(height: 16),
          EquityCurveChart(),
          SizedBox(height: 24),
          WinRatePieChart(),
          SizedBox(height: 24),
          Text("Setup Performance", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
          SizedBox(height: 16),
          SetupPerformanceBarChart(),
          SizedBox(height: 24),
          ConsistencyStreakCalendar(),
        ],
      ),
    );
  }
}

class DashboardTabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text("Equity Curve", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
          SizedBox(height: 16),
          EquityCurveChart(),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: WinRatePieChart()),
              SizedBox(width: 24),
              Expanded(child: SetupPerformanceBarChart()),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardDesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text("Equity Curve", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                SizedBox(height: 16),
                Expanded(child: EquityCurveChart()),
              ],
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  WinRatePieChart(),
                  SizedBox(height: 24),
                  SetupPerformanceBarChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
