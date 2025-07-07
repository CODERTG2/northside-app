import 'package:flutter_test/flutter_test.dart';
import 'package:stampede/main.dart' as app;

void main() {
  testWidgets('App starts and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(app.MyApp());
    // TODO: Replace 'Northside' with a widget/text from your home screen
    expect(find.text('Northside'), findsOneWidget);
  });
}
