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
  String _display = '0';

  /// The left-hand operand captured when an operator is queued (or the
  /// running result while chaining).
  double? _pendingValue;

  /// The operator waiting for its right-hand operand.
  String? _pendingOperator;

  /// The operand used the last time "=" produced a result, kept around so
  /// pressing "=" again with no new input can repeat the operation.
  double? _lastOperand;

  /// The operator used the last time "=" produced a result.
  String? _lastOperator;

  /// True when the next digit/decimal input should start a brand new entry
  /// instead of appending to [_display] (e.g. right after an operator or
  /// "=").
  bool _shouldResetDisplay = false;

  /// True once a division by zero has occurred; locks out all input except
  /// [clear].
  bool _error = false;

  String get display => _display;

  void inputDigit(String digit) {
    if (_error) return;

    if (_shouldResetDisplay) {
      _display = '0';
      _shouldResetDisplay = false;
    }

    if (_display == '0') {
      _display = digit == '0' ? '0' : digit;
    } else {
      _display += digit;
    }
  }

  void inputDecimalPoint() {
    if (_error) return;

    if (_shouldResetDisplay) {
      _display = '0';
      _shouldResetDisplay = false;
    }

    if (!_display.contains('.')) {
      _display += '.';
    }
  }

  void inputOperator(String operator) {
    if (_error) return;

    if (_pendingOperator != null && !_shouldResetDisplay) {
      // A new operand was entered since the last operator: evaluate the
      // pending operation first (chaining) before queuing the new one.
      final result = _apply(_pendingValue!, _pendingOperator!, _currentValue());
      if (result == null) {
        _setError();
        return;
      }
      _display = _format(result);
      _pendingValue = result;
    } else if (_pendingOperator == null) {
      _pendingValue = _currentValue();
    }
    // Otherwise an operator is already pending but no new operand was
    // entered (e.g. "2 + ×"): just swap the queued operator below.

    _pendingOperator = operator;
    _lastOperand = null;
    _lastOperator = null;
    _shouldResetDisplay = true;
  }

  void inputEquals() {
    if (_error) return;

    if (_pendingOperator != null) {
      final left = _pendingValue!;
      final operator = _pendingOperator!;
      final right = _currentValue();

      final result = _apply(left, operator, right);
      if (result == null) {
        _setError();
        return;
      }

      _display = _format(result);
      _lastOperand = right;
      _lastOperator = operator;
      _pendingValue = result;
      _pendingOperator = null;
      _shouldResetDisplay = true;
    } else if (_lastOperator != null && _lastOperand != null) {
      // Repeat the last operation with the last operand.
      final left = _currentValue();
      final result = _apply(left, _lastOperator!, _lastOperand!);
      if (result == null) {
        _setError();
        return;
      }

      _display = _format(result);
      _shouldResetDisplay = true;
    }
    // Otherwise there is nothing to evaluate yet; leave display unchanged.
  }

  void toggleSign() {
    if (_error) return;

    if (_display == '0') return;

    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else {
      _display = '-$_display';
    }
    _shouldResetDisplay = false;
  }

  void inputPercent() {
    if (_error) return;

    final result = _currentValue() / 100;
    _display = _format(result);
    _shouldResetDisplay = false;
  }

  void clear() {
    _display = '0';
    _pendingValue = null;
    _pendingOperator = null;
    _lastOperand = null;
    _lastOperator = null;
    _shouldResetDisplay = false;
    _error = false;
  }

  /// Parses [_display] as a double, tolerating a trailing decimal point
  /// (e.g. "3.") which [double.parse] would otherwise reject.
  double _currentValue() {
    var text = _display;
    if (text.endsWith('.')) {
      text = '${text}0';
    }
    return double.tryParse(text) ?? 0;
  }

  /// Applies [operator] to [left] and [right]. Returns `null` to signal a
  /// division-by-zero error.
  double? _apply(double left, String operator, double right) {
    switch (operator) {
      case '+':
        return left + right;
      case '-':
        return left - right;
      case '×':
        return left * right;
      case '÷':
        if (right == 0) return null;
        return left / right;
      default:
        return right;
    }
  }

  void _setError() {
    _display = 'Error';
    _error = true;
    _pendingValue = null;
    _pendingOperator = null;
    _lastOperand = null;
    _lastOperator = null;
    _shouldResetDisplay = true;
  }

  /// Formats a [double] result for display, trimming floating-point noise
  /// and unnecessary trailing zeros/decimal points.
  String _format(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';

    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.truncate().toString();
    }

    var text = value.toStringAsFixed(10);
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'0+$'), '');
      if (text.endsWith('.')) {
        text = text.substring(0, text.length - 1);
      }
    }
    return text;
  }
}
