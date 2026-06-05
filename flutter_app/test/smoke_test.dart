import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/services/emotional_lockout_service.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Smoke test - App starts', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => EmotionalLockoutService(),
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    // Search for widgets that might contain the text, or check title in MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(MainPage), findsOneWidget);
  });
}
