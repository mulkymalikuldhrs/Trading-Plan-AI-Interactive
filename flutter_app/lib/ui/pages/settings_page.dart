import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("⚙️ Settings"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Center(
        child: Text("Settings Page - Coming Soon!"),
      ),
    );
  }
}
