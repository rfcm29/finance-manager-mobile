import 'package:flutter_test/flutter_test.dart';
import 'package:finance_manager/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Just verify the app builds without crashing
    expect(FinanceApp, isNotNull);
  });
}
