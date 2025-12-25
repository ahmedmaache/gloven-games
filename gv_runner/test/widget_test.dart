import 'package:flutter_test/flutter_test.dart';
import 'package:gv_runner/main.dart';

void main() {
  testWidgets('App starts and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GVRunnerApp());

    // Verify that the title text is present
    expect(find.textContaining('RUNNER'), findsOneWidget);
  });
}
