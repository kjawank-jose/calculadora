enum TokenType { number, operator, leftParen, rightParen }

class Token {
  final TokenType type;
  final String value;

  const Token(this.type, this.value);

  @override
  String toString() => 'Token($type, $value)';
}

class CalculatorException implements Exception {
  final String message;
  const CalculatorException(this.message);

  @override
  String toString() => message;
}

List<Token> tokenize(String input) {
  final tokens = <Token>[];
  var i = 0;

  while (i < input.length) {
    final c = input[i];

    if (c == ' ') {
      i++;
    } else if (_isDigit(c) || c == '.') {
      final start = i;
      var dots = 0;
      while (i < input.length && (_isDigit(input[i]) || input[i] == '.')) {
        if (input[i] == '.') dots++;
        i++;
      }
      if (dots > 1) {
        throw const CalculatorException('Número con demasiados puntos');
      }
      tokens.add(Token(TokenType.number, input.substring(start, i)));
    } else if ('+-×÷*/'.contains(c)) {
      tokens.add(Token(TokenType.operator, c));
      i++;
    } else if (c == '(') {
      tokens.add(const Token(TokenType.leftParen, '('));
      i++;
    } else if (c == ')') {
      tokens.add(const Token(TokenType.rightParen, ')'));
      i++;
    } else {
      throw CalculatorException('Carácter no válido: $c');
    }
  }

  return tokens;
}

bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

// Normaliza símbolos y marca los menos unarios como 'u-'.
List<Token> _markUnary(List<Token> tokens) {
  final result = <Token>[];
  for (var i = 0; i < tokens.length; i++) {
    final t = tokens[i];
    var value = t.value;
    if (t.type == TokenType.operator) {
      if (value == '*') value = '×';
      if (value == '/') value = '÷';

      final prev = i == 0 ? null : tokens[i - 1];
      final isUnaryContext = prev == null ||
          prev.type == TokenType.operator ||
          prev.type == TokenType.leftParen;

      if (isUnaryContext) {
        if (value == '-') {
          value = 'u-';
        } else if (value == '+') {
          continue; // un + unario no cambia nada
        } else {
          throw CalculatorException('Operador mal ubicado: $value');
        }
      }
    }
    result.add(Token(t.type, value));
  }
  return result;
}

int _precedence(String op) {
  switch (op) {
    case 'u-':
      return 3;
    case '×':
    case '÷':
      return 2;
    default: // + y -
      return 1;
  }
}

// Shunting-yard: convierte tokens a notación postfija (RPN).
List<Token> toPostfix(List<Token> tokens) {
  final output = <Token>[];
  final stack = <Token>[];

  for (final t in _markUnary(tokens)) {
    switch (t.type) {
      case TokenType.number:
        output.add(t);
        break;
      case TokenType.operator:
        final rightAssoc = t.value == 'u-';
        while (stack.isNotEmpty &&
            stack.last.type == TokenType.operator &&
            (_precedence(stack.last.value) > _precedence(t.value) ||
                (_precedence(stack.last.value) == _precedence(t.value) &&
                    !rightAssoc))) {
          output.add(stack.removeLast());
        }
        stack.add(t);
        break;
      case TokenType.leftParen:
        stack.add(t);
        break;
      case TokenType.rightParen:
        while (stack.isNotEmpty && stack.last.type != TokenType.leftParen) {
          output.add(stack.removeLast());
        }
        if (stack.isEmpty) {
          throw const CalculatorException('Paréntesis sin abrir');
        }
        stack.removeLast(); // descarta el '('
        break;
    }
  }

  while (stack.isNotEmpty) {
    final t = stack.removeLast();
    if (t.type == TokenType.leftParen) {
      throw const CalculatorException('Paréntesis sin cerrar');
    }
    output.add(t);
  }
  return output;
}

// Evalúa la expresión postfija con una pila.
double evaluatePostfix(List<Token> postfix) {
  final stack = <double>[];

  for (final t in postfix) {
    if (t.type == TokenType.number) {
      final n = double.tryParse(t.value);
      if (n == null) throw CalculatorException('Número inválido: ${t.value}');
      stack.add(n);
    } else if (t.value == 'u-') {
      if (stack.isEmpty) throw const CalculatorException('Expresión incompleta');
      stack.add(-stack.removeLast());
    } else {
      if (stack.length < 2) {
        throw const CalculatorException('Expresión incompleta');
      }
      final b = stack.removeLast();
      final a = stack.removeLast();
      switch (t.value) {
        case '+':
          stack.add(a + b);
          break;
        case '-':
          stack.add(a - b);
          break;
        case '×':
          stack.add(a * b);
          break;
        case '÷':
          if (b == 0) {
            throw const CalculatorException('División entre cero');
          }
          stack.add(a / b);
          break;
      }
    }
  }

  if (stack.length != 1) throw const CalculatorException('Expresión inválida');
  return stack.single;
}

// Función pública que usará la interfaz.
double calculate(String expression) {
  if (expression.trim().isEmpty) {
    throw const CalculatorException('Expresión vacía');
  }
  return evaluatePostfix(toPostfix(tokenize(expression)));
}