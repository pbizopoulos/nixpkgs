import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_postgres/main.dart'; // Adjust name based on pubspec
void main() {
  testWidgets('Hello World test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Hello World!'), findsOneWidget);
  });
}
