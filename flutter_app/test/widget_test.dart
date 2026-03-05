import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('App should load and show title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is present (it's in the MaterialApp title, but we can check for UI elements)
    // Since we don't have a counter, we just check if the MainPage loads.
    expect(find.byType(MainPage), findsOneWidget);
  });
}
