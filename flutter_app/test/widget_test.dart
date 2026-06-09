import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/services/emotional_lockout_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('MainPage smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider<EmotionalLockoutService>(
        create: (_) => EmotionalLockoutService(),
        child: const MaterialApp(home: MainPage()),
      ),
    );

    // Give it time to settle
    await tester.pumpAndSettle();

    // Verify Bottom Navigation exists
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Check for some tab text
    expect(find.text('Entry'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
  });
}
