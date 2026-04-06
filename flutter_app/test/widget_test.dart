import 'package:flutter_test/flutter_test.dart';
import 'package:dhaher_trading_plan_ai/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Basic check to see if the app starts
    expect(find.byType(MyApp), findsOneWidget);
  });
}
