import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculator_app/main.dart';

void main() {
  testWidgets('Calculator computes 2 + 3 = 5', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    final display = find.byKey(const Key('calculator_display'));
    expect(display, findsOneWidget);
    expect(
      tester.widget<Text>(display).data,
      '0',
    );

    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();

    expect(tester.widget<Text>(display).data, '5');
  });
}
