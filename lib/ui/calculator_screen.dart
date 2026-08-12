import 'package:flutter/material.dart';

import '../logic/calculator_engine.dart';

/// Top-level screen: a display showing [CalculatorEngine.display] and a
/// standard calculator button grid.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorEngine _engine = CalculatorEngine();

  void _onDigit(String digit) => setState(() => _engine.inputDigit(digit));

  void _onDecimalPoint() => setState(() => _engine.inputDecimalPoint());

  void _onOperator(String operator) =>
      setState(() => _engine.inputOperator(operator));

  void _onEquals() => setState(() => _engine.inputEquals());

  void _onToggleSign() => setState(() => _engine.toggleSign());

  void _onPercent() => setState(() => _engine.inputPercent());

  void _onClear() => setState(() => _engine.clear());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Expanded(child: _DisplayArea(text: _engine.display)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _ButtonGrid(
                    onDigit: _onDigit,
                    onDecimalPoint: _onDecimalPoint,
                    onOperator: _onOperator,
                    onEquals: _onEquals,
                    onToggleSign: _onToggleSign,
                    onPercent: _onPercent,
                    onClear: _onClear,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisplayArea extends StatelessWidget {
  const _DisplayArea({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w300),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

enum _ButtonKind { digit, operator, action, equals }

class _ButtonSpec {
  const _ButtonSpec(this.label, this.kind, {this.flex = 1});

  final String label;
  final _ButtonKind kind;
  final int flex;
}

class _ButtonGrid extends StatelessWidget {
  const _ButtonGrid({
    required this.onDigit,
    required this.onDecimalPoint,
    required this.onOperator,
    required this.onEquals,
    required this.onToggleSign,
    required this.onPercent,
    required this.onClear,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDecimalPoint;
  final ValueChanged<String> onOperator;
  final VoidCallback onEquals;
  final VoidCallback onToggleSign;
  final VoidCallback onPercent;
  final VoidCallback onClear;

  static const _rows = <List<_ButtonSpec>>[
    [
      _ButtonSpec('C', _ButtonKind.action),
      _ButtonSpec('+/-', _ButtonKind.action),
      _ButtonSpec('%', _ButtonKind.action),
      _ButtonSpec('÷', _ButtonKind.operator),
    ],
    [
      _ButtonSpec('7', _ButtonKind.digit),
      _ButtonSpec('8', _ButtonKind.digit),
      _ButtonSpec('9', _ButtonKind.digit),
      _ButtonSpec('×', _ButtonKind.operator),
    ],
    [
      _ButtonSpec('4', _ButtonKind.digit),
      _ButtonSpec('5', _ButtonKind.digit),
      _ButtonSpec('6', _ButtonKind.digit),
      _ButtonSpec('-', _ButtonKind.operator),
    ],
    [
      _ButtonSpec('1', _ButtonKind.digit),
      _ButtonSpec('2', _ButtonKind.digit),
      _ButtonSpec('3', _ButtonKind.digit),
      _ButtonSpec('+', _ButtonKind.operator),
    ],
    [
      _ButtonSpec('0', _ButtonKind.digit, flex: 2),
      _ButtonSpec('.', _ButtonKind.digit),
      _ButtonSpec('=', _ButtonKind.equals),
    ],
  ];

  void _handleTap(String label, _ButtonKind kind) {
    switch (kind) {
      case _ButtonKind.digit:
        if (label == '.') {
          onDecimalPoint();
        } else {
          onDigit(label);
        }
      case _ButtonKind.operator:
        onOperator(label);
      case _ButtonKind.equals:
        onEquals();
      case _ButtonKind.action:
        switch (label) {
          case 'C':
            onClear();
          case '+/-':
            onToggleSign();
          case '%':
            onPercent();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in _rows) ...[
          _ButtonRow(row: row, onTap: _handleTap),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow({required this.row, required this.onTap});

  final List<_ButtonSpec> row;
  final void Function(String label, _ButtonKind kind) onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final spec in row) ...[
          Expanded(
            flex: spec.flex,
            child: AspectRatio(
              aspectRatio: spec.flex == 1 ? 1 : 2.2,
              child: _CalculatorButton(
                label: spec.label,
                kind: spec.kind,
                onPressed: () => onTap(spec.label, spec.kind),
              ),
            ),
          ),
          if (spec != row.last) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.label,
    required this.kind,
    required this.onPressed,
  });

  final String label;
  final _ButtonKind kind;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color background;
    final Color foreground;
    switch (kind) {
      case _ButtonKind.digit:
        background = colorScheme.surfaceContainerHighest;
        foreground = colorScheme.onSurface;
      case _ButtonKind.action:
        background = colorScheme.secondaryContainer;
        foreground = colorScheme.onSecondaryContainer;
      case _ButtonKind.operator:
      case _ButtonKind.equals:
        background = colorScheme.primary;
        foreground = colorScheme.onPrimary;
    }

    return Material(
      color: background,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: foreground),
          ),
        ),
      ),
    );
  }
}
