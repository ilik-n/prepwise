import 'package:flutter_test/flutter_test.dart';
import 'package:flash_prepositions/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PrepWiseApp());
    expect(find.text('PrepWise'), findsOneWidget);
  });
}
