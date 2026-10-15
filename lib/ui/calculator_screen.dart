import 'package:flutter/material.dart';
import '../engine/calculator_engine.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _preview = '';
  bool _justEvaluated = false;

  static const _rows = [
    ['C', '(', ')', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '⌫', '='],
  ];

  String _format(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    var s = value.toStringAsFixed(10);
    s = s.replaceAll(RegExp(r'0+$'), '');
    return s.endsWith('.') ? s.substring(0, s.length - 1) : s;
  }

  void _updatePreview() {
    try {
      _preview = _expression.isEmpty ? '' : _format(calculate(_expression));
    } on CalculatorException {
      _preview = '';
    }
  }

  void _onKey(String key) {
    setState(() {
      switch (key) {
        case 'C':
          _expression = '';
          _preview = '';
          _justEvaluated = false;
          return;
        case '⌫':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
          }
          _justEvaluated = false;
          break;
        case '=':
          try {
            _expression = _format(calculate(_expression));
            _preview = '';
            _justEvaluated = true;
          } on CalculatorException catch (e) {
            _preview = e.message;
          }
          return;
        default:
          final startsNew = RegExp(r'[0-9.(]').hasMatch(key);
          if (_justEvaluated && startsNew) {
            _expression = key;
          } else {
            _expression += key;
          }
          _justEvaluated = false;
      }
      _updatePreview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: const TextStyle(fontSize: 56),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _preview,
                      style: TextStyle(fontSize: 24, color: scheme.primary),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (final row in _rows)
                      Expanded(
                        child: Row(
                          children: [
                            for (final key in row)
                              Expanded(child: _buildKey(key, scheme)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String key, ColorScheme scheme) {
    final isOperator = '÷×-+'.contains(key);
    final isEquals = key == '=';
    final isClear = key == 'C';

    Color background = scheme.surfaceContainerHighest;
    Color foreground = scheme.onSurface;
    if (isEquals) {
      background = scheme.primary;
      foreground = scheme.onPrimary;
    } else if (isOperator) {
      background = scheme.secondaryContainer;
      foreground = scheme.onSecondaryContainer;
    } else if (isClear) {
      foreground = scheme.error;
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _onKey(key),
          child: Center(
            child: Text(key, style: TextStyle(fontSize: 28, color: foreground)),
          ),
        ),
      ),
    );
  }
}