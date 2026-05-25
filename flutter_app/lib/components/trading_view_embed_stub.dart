import 'package:flutter/material.dart';

/// Stub implementation for mobile platforms.
/// This file is used when dart:html is not available.
Widget buildTradingViewWebEmbed(String symbol) {
  // This should never be called on mobile, but provide a fallback
  return Center(
    child: Text(
      'Chart not available on this platform',
      style: TextStyle(color: Colors.white54),
    ),
  );
}
