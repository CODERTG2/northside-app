import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Sample widget test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Text('Hello, test!')),
    ));
    expect(find.text('Hello, test!'), findsOneWidget);
  });
}
