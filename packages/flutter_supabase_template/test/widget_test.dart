import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_supabase_template/main.dart';
void main() {
  testWidgets('Hello World test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Hello World!'), findsOneWidget);
  });
}
