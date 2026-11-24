import 'package:flutter_test/flutter_test.dart';
import 'package:influncermarketing/main.dart';

void main() {
  testWidgets('Influencer Pulse smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CreatorPulseApp());
    expect(find.text('Influencer Pulse'), findsWidgets);
  });
}
