import 'package:flutter_test/flutter_test.dart';
import 'package:pop_count/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PopCountApp());

    // Verify that the app starts.
    expect(find.byType(PopCountApp), findsOneWidget);
  });
}
