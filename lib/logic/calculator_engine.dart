/// Core arithmetic engine for the calculator, independent of any UI.
///
/// Behavior contract (used by both the implementation and the test suite,
/// developed in parallel against this interface):
///
/// - [display] always reflects what should be shown to the user.
/// - Digits are appended to the current entry. Leading zeros are collapsed
///   (e.g. "0" + "5" -> "5"), except a single "0" stays "0".
/// - [inputDecimalPoint] adds a "." to the current entry if one isn't
///   already present in it.
/// - [inputOperator] queues a pending binary operation. If an operator is
///   already pending and a new operand has been entered, the pending
///   operation is evaluated first (chaining), then the new operator is
///   queued (e.g. "2 + 3 ×" evaluates "2+3=5" then queues "5 ×").
/// - [inputEquals] evaluates the pending operation (if any) and shows the
///   result. Pressing "=" again with no new input repeats the last
///   operation with the last operand (standard calculator behavior).
/// - Division by zero sets [display] to "Error" and requires [clear] before
///   any further input is accepted (except [clear] itself).
/// - [toggleSign] flips the sign of the current entry.
/// - [inputPercent] converts the current entry to `value / 100`.
/// - [clear] resets all state back to the initial state ([display] == "0").
class CalculatorEngine {
  String get display => throw UnimplementedError();

  void inputDigit(String digit) => throw UnimplementedError();

  void inputDecimalPoint() => throw UnimplementedError();

  void inputOperator(String operator) => throw UnimplementedError();

  void inputEquals() => throw UnimplementedError();

  void toggleSign() => throw UnimplementedError();

  void inputPercent() => throw UnimplementedError();

  void clear() => throw UnimplementedError();
}
