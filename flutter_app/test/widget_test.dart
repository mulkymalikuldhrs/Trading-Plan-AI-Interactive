import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/services/emotional_lockout_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => EmotionalLockoutService(),
        child: MyApp(),
      ),
    );

    // Verify that the entry page is shown
    expect(find.text('Entry'), findsWidgets);
    expect(find.text('Journal'), findsWidgets);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Intel'), findsWidgets);
  });
}
