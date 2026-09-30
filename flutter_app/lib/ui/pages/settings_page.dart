import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⚙️ Settings"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: const Center(
        child: Text("Settings Page - Coming Soon!"),
      ),
    );
  }
}
