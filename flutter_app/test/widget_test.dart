import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/services/emotional_lockout_service.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => EmotionalLockoutService(),
        child: MyApp(),
      ),
    );

    // Verify that the bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify specific navigation items exist
    expect(find.text('Entry'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Intel'), findsOneWidget);
    expect(find.text('AI Chat'), findsOneWidget);
  });
}
