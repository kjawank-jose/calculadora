import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/calculator_engine.dart';
import '../services/sound_bank.dart';
import 'cat_widgets.dart';

class CatculatorScreen extends StatefulWidget {
  const CatculatorScreen({super.key});

  @override
  State<CatculatorScreen> createState() => _CatculatorScreenState();
}

class _CatculatorScreenState extends State<CatculatorScreen> {
  final _sounds = SoundBank();
  String _expression = '';
  String _preview = '';
  bool _justEvaluated = false;
  bool _soundOn = true;

  static const _rows = [
    ['C', '(', ')', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '⌫', '='],
  ];

  @override
  void initState() {
    super.initState();
    _sounds.init();
  }

  @override
  void dispose() {
    _sounds.dispose();
    super.dispose();
  }

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

  bool _isDigit(String k) => RegExp(r'^[0-9]$').hasMatch(k);

  void _onKey(String key) {
    if (_soundOn) _sounds.play(key);

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

  // El logo completo como fondo de la app
  Widget _background() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.75),
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: Opacity(
                  opacity: 0.85, // baja a 0.6 si tapa los números
                  child: Image.asset(
                    'assets/images/cat_bg.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // oscurece abajo para que las teclas se lean
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00012060),
                    Color(0x66012060),
                    Color(0xCC01143D),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
              child: SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavyDark,
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Column(
              children: [
                // Botón de sonido
                SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: _soundOn ? 'Silenciar' : 'Activar sonido',
                      icon: Icon(_soundOn ? Icons.volume_up : Icons.volume_off),
                      color: kAmber,
                      onPressed: () => setState(() => _soundOn = !_soundOn),
                    ),
                  ),
                ),
                // Pantalla
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: kNavyDark.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kCream.withValues(alpha: 0.25)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _expression.isEmpty ? '0' : _expression,
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w600,
                              color: kCream,
                            ),
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _preview.isEmpty ? ' ' : _preview,
                            style: const TextStyle(fontSize: 24, color: kAmber),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Teclado
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      children: [
                        for (final row in _rows)
                          Expanded(
                            child: Row(
                              children: [
                                for (final key in row)
                                  Expanded(child: _buildKey(key)),
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
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    if (_isDigit(key)) {
      return PawButton(label: key, onTap: () => _onKey(key));
    }

    final isEquals = key == '=';
    final isOperator = '÷×-+'.contains(key);

    final Color background = isEquals
        ? kAmber
        : isOperator
        ? kBlue
        : Colors.white.withValues(alpha: 0.10);
    final Color foreground = isEquals
        ? kBrown
        : key == 'C'
        ? const Color(0xFFFF8A7A)
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isEquals
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.18),
          ),
          boxShadow: [
            if (isEquals)
              BoxShadow(color: kAmber.withValues(alpha: 0.55), blurRadius: 18),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => _onKey(key),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
