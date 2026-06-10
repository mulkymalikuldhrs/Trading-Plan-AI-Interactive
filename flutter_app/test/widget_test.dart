import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/services/emotional_lockout_service.dart';

void main() {
  testWidgets('App smoke test - renders main navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => EmotionalLockoutService(),
        child: const MyApp(),
      ),
    );

    // Verify that the first page (Entry) is shown by looking for its title.
    expect(find.text('Validate New Trade Setup'), findsOneWidget);

    // Verify navigation bar exists
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
