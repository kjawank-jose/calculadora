import 'package:flutter_test/flutter_test.dart';
import 'package:calculadora/engine/calculator_engine.dart';

void main() {
  test('tokeniza una expresión simple', () {
    final tokens = tokenize('3 + 4.5');
    expect(tokens.length, 3);
    expect(tokens[0].value, '3');
    expect(tokens[1].type, TokenType.operator);
    expect(tokens[2].value, '4.5');
  });

  test('rechaza caracteres inválidos', () {
    expect(() => tokenize('3 & 4'), throwsA(isA<CalculatorException>()));
  });

  test('respeta la precedencia', () {
    expect(calculate('2 + 3 × 4'), 14);
    expect(calculate('(2 + 3) × 4'), 20);
    expect(calculate('10 - 4 - 3'), 3);
    expect(calculate('100 ÷ 10 ÷ 2'), 5);
  });

  test('maneja negativos', () {
    expect(calculate('-5 + 3'), -2);
    expect(calculate('2 × (-4)'), -8);
    expect(calculate('--3'), 3);
  });

  test('maneja decimales', () {
    expect(calculate('0.5 + 0.25'), 0.75);
  });

  test('errores controlados', () {
    expect(() => calculate('5 ÷ 0'), throwsA(isA<CalculatorException>()));
    expect(() => calculate('(2 + 3'), throwsA(isA<CalculatorException>()));
    expect(() => calculate('2 + 3)'), throwsA(isA<CalculatorException>()));
    expect(() => calculate('2 +'), throwsA(isA<CalculatorException>()));
    expect(() => calculate(''), throwsA(isA<CalculatorException>()));
  });

}