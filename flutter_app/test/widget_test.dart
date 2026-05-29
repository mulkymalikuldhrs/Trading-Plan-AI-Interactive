import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/services/emotional_lockout_service.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => EmotionalLockoutService(),
        child: MyApp(),
      ),
    );

    // Verify that our app title or a key widget exists
    expect(find.text('Dhaher Trading Plan AI'), findsNothing); // It's in MaterialApp title, not usually rendered as a widget
    expect(find.byType(MainPage), findsOneWidget);
  });
}
