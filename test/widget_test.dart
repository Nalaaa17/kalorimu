import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalorimu/main.dart';

void main() {
  testWidgets('Kalorimu app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KalorimuApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
