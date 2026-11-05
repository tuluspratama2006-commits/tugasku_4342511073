import 'package:flutter_test/flutter_test.dart';
import 'package:tugasku_4342511073/main.dart';

void main() {
  testWidgets('TugasKuApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TugasKuAppRoot());

    // Verify that TugasKu splash screen loads
    expect(find.text('TugasKu'), findsOneWidget);
  });
}
