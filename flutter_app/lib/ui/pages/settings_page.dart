import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("⚙️ System Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Account Configuration"),
          _buildSettingsTile(Icons.link, "API Endpoint", "Google Apps Script"),
          _buildSettingsTile(Icons.key, "Master API Key", "****"),
          _buildSettingsTile(Icons.phone, "WhatsApp Notification", "6285322624048"),
          SizedBox(height: 24),
          _buildSectionHeader("Trading Preferences"),
          _buildSettingsTile(Icons.currency_exchange, "Primary Pair", "EURUSD"),
          _buildSettingsTile(Icons.timer, "Preferred Timeframe", "H4"),
          SizedBox(height: 24),
          _buildSectionHeader("AI Intelligence"),
          _buildSettingsTile(Icons.auto_awesome, "Autonomous Signal Scanner", "Enabled"),
          _buildSettingsTile(Icons.psychology, "Emotional Lockout Threshold", "3 Violations"),
          SizedBox(height: 40),
          Center(
            child: Text(
              "v10.5.8-hardened",
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(value, style: TextStyle(color: Colors.white38)),
      trailing: Icon(Icons.chevron_right, color: Colors.white24),
      onTap: () {},
    );
  }
}
