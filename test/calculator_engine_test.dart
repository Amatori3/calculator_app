// Unit test suite for [CalculatorEngine], written purely against the
// documented behavior contract in `lib/logic/calculator_engine.dart`.
//
// NOTE: CalculatorEngine is currently an unimplemented stub (every method
// throws UnimplementedError). This suite is expected to fail until a real
// implementation lands from the parallel TDD workstream -- that is the
// intended state, not a bug in this test file.
//
// A number of behaviors are not fully pinned down by the doc comments. Each
// such spot is called out in a comment at the point of use, stating the
// interpretation this suite assumes. See also the written review handed
// back alongside this file for the consolidated list.

import 'package:flutter_test/flutter_test.dart';

import 'package:calculator_app/logic/calculator_engine.dart';

/// Feeds a plain numeric token (digits and at most one '.') into [engine]
/// via inputDigit/inputDecimalPoint, e.g. enter(engine, '12.5').
void enter(CalculatorEngine engine, String token) {
  for (final ch in token.split('')) {
    if (ch == '.') {
      engine.inputDecimalPoint();
    } else {
      engine.inputDigit(ch);
    }
  }
}

void main() {
  late CalculatorEngine engine;

  setUp(() {
    engine = CalculatorEngine();
  });

  group('initial state', () {
    test('display starts at "0"', () {
      expect(engine.display, '0');
    });
  });

  group('digit entry and leading-zero collapse', () {
    test('single digit is shown directly', () {
      engine.inputDigit('5');
      expect(engine.display, '5');
    });

    test('multiple digits accumulate in order', () {
      engine.inputDigit('1');
      engine.inputDigit('2');
      engine.inputDigit('3');
      expect(engine.display, '123');
    });

    test(
      'leading zero is collapsed when a nonzero digit follows: "0"+"5" -> "5"',
      () {
        // Explicitly given in the doc comment.
        engine.inputDigit('0');
        expect(engine.display, '0');
        engine.inputDigit('5');
        expect(engine.display, '5');
      },
    );

    test('repeated zero entry stays a single "0"', () {
      engine.inputDigit('0');
      engine.inputDigit('0');
      engine.inputDigit('0');
      expect(engine.display, '0');
    });

    test('zero in a non-leading position is kept: "5"+"0" -> "50"', () {
      engine.inputDigit('5');
      engine.inputDigit('0');
      expect(engine.display, '50');
    });
  });

  group('decimal point', () {
    test('adds a "." to the entry', () {
      engine.inputDigit('5');
      engine.inputDecimalPoint();
      engine.inputDigit('2');
      expect(engine.display, '5.2');
    });

    test('decimal point on a bare "0" entry produces "0."', () {
      engine.inputDecimalPoint();
      expect(engine.display, '0.');
    });

    test('a second decimal point is ignored ("." already present)', () {
      engine.inputDigit('3');
      engine.inputDecimalPoint();
      engine.inputDigit('1');
      engine.inputDecimalPoint();
      engine.inputDigit('4');
      expect(engine.display, '3.14');
    });

    // AMBIGUITY: the doc's leading-zero-collapse example only covers plain
    // digit entry ("0"+"5" -> "5"). It is not stated whether that collapse
    // still applies once a decimal point has been entered. This suite
    // assumes it does NOT -- i.e. "0." followed by "5" stays "0.5" rather
    // than becoming ".5" or "5" -- since collapsing "0" here would destroy
    // the decimal point itself.
    test(
      'leading zero before a decimal point is preserved: "0."+"5" -> "0.5"',
      () {
        engine.inputDecimalPoint();
        engine.inputDigit('5');
        expect(engine.display, '0.5');
      },
    );
  });

  group('single operators', () {
    test('addition', () {
      enter(engine, '2');
      engine.inputOperator('+');
      enter(engine, '3');
      engine.inputEquals();
      expect(engine.display, '5');
    });

    test('subtraction', () {
      enter(engine, '5');
      engine.inputOperator('-');
      enter(engine, '2');
      engine.inputEquals();
      expect(engine.display, '3');
    });

    test('multiplication', () {
      enter(engine, '4');
      engine.inputOperator('×');
      enter(engine, '5');
      engine.inputEquals();
      expect(engine.display, '20');
    });

    test('division', () {
      enter(engine, '10');
      engine.inputOperator('÷');
      enter(engine, '2');
      engine.inputEquals();
      expect(engine.display, '5');
    });

    test('0 divided by a nonzero number is 0, not an error', () {
      enter(engine, '0');
      engine.inputOperator('÷');
      enter(engine, '5');
      engine.inputEquals();
      expect(engine.display, '0');
    });
  });

  group(
    'chained operators (no operator precedence; left-to-right immediate execution)',
    () {
      // The doc's own worked example: "2 + 3 ×" evaluates "2+3=5" as soon as
      // the second operator is pressed (because an operand, "3", was entered
      // while "+" was pending), then queues "5 ×". So "2 + 3 × 4 =" must
      // yield (2+3)*4 = 20, NOT 2+(3*4) = 14. This is the crux of the
      // chaining rule and the main thing this suite pins down.
      test('2 + 3 × 4 = evaluates left-to-right: (2+3)×4 = 20', () {
        enter(engine, '2');
        engine.inputOperator('+');
        enter(engine, '3');
        engine.inputOperator('×');
        enter(engine, '4');
        engine.inputEquals();
        expect(engine.display, '20');
      });

      test('10 - 2 + 3 = evaluates left-to-right: (10-2)+3 = 11', () {
        enter(engine, '10');
        engine.inputOperator('-');
        enter(engine, '2');
        engine.inputOperator('+');
        enter(engine, '3');
        engine.inputEquals();
        expect(engine.display, '11');
      });

      test(
        'chained division: 100 ÷ 4 ÷ 5 = evaluates left-to-right: (100÷4)÷5 = 5',
        () {
          enter(engine, '100');
          engine.inputOperator('÷');
          enter(engine, '4');
          engine.inputOperator('÷');
          enter(engine, '5');
          engine.inputEquals();
          expect(engine.display, '5');
        },
      );

      // AMBIGUITY: the doc only specifies chaining for the case where "a new
      // operand has been entered" since the last operator. It does not say
      // what happens if an operator is pressed again with NO new operand
      // typed in between (e.g. pressing "+" then immediately "-"). This
      // suite assumes the pending operator is simply replaced/updated in
      // that case, without triggering an evaluation (since there is nothing
      // new to evaluate).
      test(
        'pressing an operator twice with no operand in between replaces the pending operator',
        () {
          enter(engine, '5');
          engine.inputOperator('+');
          engine.inputOperator(
            '-',
          ); // no digits typed since '+' -> should just swap to '-'
          enter(engine, '3');
          engine.inputEquals();
          expect(engine.display, '2'); // 5 - 3, not 5 + 3
        },
      );

      // AMBIGUITY: the doc doesn't say what operand is used if inputOperator
      // is called before any digit has been entered at all. This suite
      // assumes the current display value (the initial "0") is used as the
      // left operand, matching how [display] is documented to "always
      // reflect what should be shown".
      test(
        'operator pressed before any digit entry uses the current display ("0") as the operand',
        () {
          engine.inputOperator('+');
          enter(engine, '5');
          engine.inputEquals();
          expect(engine.display, '5'); // 0 + 5
        },
      );
    },
  );

  group('equals and repeat-equals', () {
    test('plain equals evaluates the pending operation', () {
      enter(engine, '2');
      engine.inputOperator('+');
      enter(engine, '3');
      engine.inputEquals();
      expect(engine.display, '5');
    });

    test(
      'pressing equals repeatedly repeats the last operation with the last operand',
      () {
        enter(engine, '5');
        engine.inputOperator('+');
        enter(engine, '3');
        engine.inputEquals();
        expect(engine.display, '8'); // 5 + 3
        engine.inputEquals();
        expect(engine.display, '11'); // 8 + 3
        engine.inputEquals();
        expect(engine.display, '14'); // 11 + 3
      },
    );

    test('repeat-equals works for multiplication too', () {
      enter(engine, '4');
      engine.inputOperator('×');
      enter(engine, '3');
      engine.inputEquals();
      expect(engine.display, '12');
      engine.inputEquals();
      expect(engine.display, '36');
    });

    test('continuing to build on a result: 2 + 3 = × 4 = yields 20', () {
      enter(engine, '2');
      engine.inputOperator('+');
      enter(engine, '3');
      engine.inputEquals();
      expect(engine.display, '5');
      engine.inputOperator('×');
      enter(engine, '4');
      engine.inputEquals();
      expect(engine.display, '20');
    });

    // AMBIGUITY: the doc does not say what happens when "=" is pressed with
    // no operator ever having been queued. This suite assumes it is a
    // no-op: the display is left showing whatever was already entered.
    test('equals with no pending operator is a no-op', () {
      enter(engine, '7');
      engine.inputEquals();
      expect(engine.display, '7');
    });
  });

  group('divide by zero', () {
    test('n ÷ 0 = sets display to "Error"', () {
      enter(engine, '5');
      engine.inputOperator('÷');
      enter(engine, '0');
      engine.inputEquals();
      expect(engine.display, 'Error');
    });

    // AMBIGUITY: the doc doesn't explicitly call out 0 ÷ 0. This suite
    // assumes it is treated the same as any other division by zero
    // (division by zero is undefined regardless of the numerator).
    test('0 ÷ 0 = is also "Error"', () {
      enter(engine, '0');
      engine.inputOperator('÷');
      enter(engine, '0');
      engine.inputEquals();
      expect(engine.display, 'Error');
    });

    test('further digit input is locked out after Error until clear', () {
      enter(engine, '5');
      engine.inputOperator('÷');
      enter(engine, '0');
      engine.inputEquals();
      expect(engine.display, 'Error');

      engine.inputDigit('9');
      expect(engine.display, 'Error');
    });

    test(
      'further operator/equals input is locked out after Error until clear',
      () {
        enter(engine, '5');
        engine.inputOperator('÷');
        enter(engine, '0');
        engine.inputEquals();

        engine.inputOperator('+');
        expect(engine.display, 'Error');
        engine.inputEquals();
        expect(engine.display, 'Error');
      },
    );

    test('toggleSign and percent are also locked out after Error', () {
      enter(engine, '5');
      engine.inputOperator('÷');
      enter(engine, '0');
      engine.inputEquals();

      engine.toggleSign();
      expect(engine.display, 'Error');
      engine.inputPercent();
      expect(engine.display, 'Error');
    });

    test('clear recovers from Error and resumes normal input', () {
      enter(engine, '5');
      engine.inputOperator('÷');
      enter(engine, '0');
      engine.inputEquals();
      expect(engine.display, 'Error');

      engine.clear();
      expect(engine.display, '0');

      engine.inputDigit('7');
      expect(engine.display, '7');
    });
  });

  group('toggleSign', () {
    test('flips a positive entry to negative', () {
      engine.inputDigit('5');
      engine.toggleSign();
      expect(engine.display, '-5');
    });

    test('flips back to positive on a second toggle', () {
      engine.inputDigit('5');
      engine.toggleSign();
      engine.toggleSign();
      expect(engine.display, '5');
    });

    test('works on decimal entries', () {
      enter(engine, '3.5');
      engine.toggleSign();
      expect(engine.display, '-3.5');
    });

    // AMBIGUITY: whether toggleSign operates on the "current entry" being
    // typed vs. the result just shown after "=" is not distinguished by
    // the doc ("current entry" is used loosely). This suite assumes
    // [display] is the single source of truth toggleSign acts on,
    // regardless of whether it holds a freshly-computed result.
    test('applies to a result just produced by equals', () {
      enter(engine, '2');
      engine.inputOperator('+');
      enter(engine, '3');
      engine.inputEquals();
      expect(engine.display, '5');
      engine.toggleSign();
      expect(engine.display, '-5');
    });

    // NOTE: toggleSign's behavior on the bare initial "0" (does it become
    // "-0" or stay "0"?) is left unspecified by the contract and is
    // intentionally NOT asserted here -- see the accompanying written
    // review.
  });

  group('percent', () {
    test('converts the current entry to value / 100', () {
      enter(engine, '50');
      engine.inputPercent();
      expect(engine.display, '0.5');
    });

    test('works for small values', () {
      enter(engine, '2');
      engine.inputPercent();
      expect(engine.display, '0.02');
    });

    test('percent result can feed into a following operation', () {
      // 50% of nothing in particular, then used as an operand: 200 + 50% -> 200 + 0.5
      enter(engine, '200');
      engine.inputOperator('+');
      enter(engine, '50');
      engine.inputPercent();
      engine.inputEquals();
      expect(engine.display, '200.5');
    });
  });

  group('clear', () {
    test('resets display to "0"', () {
      enter(engine, '123');
      engine.clear();
      expect(engine.display, '0');
    });

    test('resets pending operator state (equals after clear is a no-op)', () {
      enter(engine, '5');
      engine.inputOperator('+');
      enter(engine, '3');
      engine.clear();
      expect(engine.display, '0');

      enter(engine, '7');
      engine.inputEquals();
      expect(engine.display, '7'); // no leftover "+3" to apply
    });

    test('resets decimal-point-present tracking for the new entry', () {
      enter(engine, '1.5');
      engine.clear();
      enter(engine, '2');
      engine.inputDecimalPoint();
      enter(engine, '5');
      expect(engine.display, '2.5');
    });
  });
}
