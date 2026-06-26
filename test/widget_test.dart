import 'package:flutter_test/flutter_test.dart';
import 'package:hlms_mobile/main.dart';

void main() {
  testWidgets('App renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MolangApp());
    // Verify app renders without error
    expect(find.byType(MolangApp), findsOneWidget);
  });
}
