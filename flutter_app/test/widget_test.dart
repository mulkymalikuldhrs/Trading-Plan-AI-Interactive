import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/services/emotional_lockout_service.dart';

void main() {
  testWidgets('Smoke test - App starts', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => EmotionalLockoutService(),
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MainPage), findsOneWidget);
  });
}
