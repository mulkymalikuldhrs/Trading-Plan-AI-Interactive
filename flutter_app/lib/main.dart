import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart'; // Add this dependency
import 'services/emotional_lockout_service.dart';
import 'ui/pages/entry_page.dart';
import 'ui/pages/journal_page.dart';
import 'ui/pages/dashboard_page.dart';
import 'ui/pages/chat_page.dart';
import 'ui/pages/intel_tab.dart';
import 'ui/pages/risk_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EmotionalLockoutService(),
      child: MaterialApp(
        title: 'Dhaher Trading Plan AI',
        theme: ThemeData.dark(),
        home: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    EntryPage(),
    JournalPage(),
    DashboardPage(),
    IntelTab(),
    RiskPage(),
    ChatPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lockoutService = Provider.of<EmotionalLockoutService>(context);

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          if (lockoutService.isLocked)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 80, color: Colors.redAccent),
                      SizedBox(height: 20),
                      Text(
                        "Emotional Lockout Activated",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                      ),
                      Text(
                        "You've had 3 consecutive negative events. It's time for a break.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                       SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // In a real app, this would be more sophisticated
                          lockoutService.resetOverrides();
                          lockoutService.recordWin(); // Reset loss counter
                        },
                        child: Text("I Understand, Reset"),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.add_chart), label: 'Entry'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Intel'),
          BottomNavigationBarItem(icon: Icon(Icons.scale), label: 'Risk'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'AI Chat'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: lockoutService.isLocked ? Colors.grey : Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: lockoutService.isLocked ? null : _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey[900],
      ),
    );
  }
}
