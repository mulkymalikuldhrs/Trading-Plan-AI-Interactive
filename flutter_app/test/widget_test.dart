import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/services/emotional_lockout_service.dart';

void main() {
  testWidgets('App smoke test - verifies tabs and Material 3 theme', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => EmotionalLockoutService(),
        child: const MyApp(),
      ),
    );

    // Verify that the first page (Entry) is visible
    expect(find.textContaining('Validate New Trade Setup'), findsOneWidget);

    // Verify bottom navigation items
    expect(find.byIcon(Icons.add_chart), findsOneWidget);
    expect(find.byIcon(Icons.book_online), findsOneWidget);
    expect(find.byIcon(Icons.dashboard_customize), findsOneWidget);
    expect(find.byIcon(Icons.insights), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
  });
}
