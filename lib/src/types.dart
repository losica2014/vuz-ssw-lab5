// ignore_for_file: constant_identifier_names

enum LexerState {
  H, F,
  IDENT,
  ASGN,
  FOR1,
  FOR2,
  FOR3,
  DO1,
  DO2,
  CMT1,
  CMT,
  CMT2,
  STR,
  STR1
}

enum TokenType {
  IDENTIFIER,
  ASSIGNMENT,
  FOR,
  DO,
  STRING_LITERAL,
  COMPARISON_MORE,
  COMPARISON_LESS,
  COMPARISON_EQUAL,
  OPEN_PARENTHESIS,
  CLOSE_PARENTHESIS,
  SEMICOLON
}

class Lexem {
  Lexem({required this.type, required this.value, required this.line, required this.column}) : assert(line > 0), assert(column > 0);

  final String value;
  final TokenType type;
  
  final int line;
  final int column;

  Lexem.identifier({required String value, required int line, required int column}) : this(type: TokenType.IDENTIFIER, value: value, line: line, column: column);
  Lexem.forKeyword({required int line, required int column}) : this(type: TokenType.FOR, value: "for", line: line, column: column);
  Lexem.doKeyword({required int line, required int column}) : this(type: TokenType.DO, value: "do", line: line, column: column);
  Lexem.assignmentOperator({required int line, required int column}) : this(type: TokenType.ASSIGNMENT, value: ":=", line: line, column: column);
  Lexem.comparisonMore({required int line, required int column}) : this(type: TokenType.COMPARISON_MORE, value: ">", line: line, column: column);
  Lexem.comparisonLess({required int line, required int column}) : this(type: TokenType.COMPARISON_LESS, value: "<", line: line, column: column);
  Lexem.comparisonEqual({required int line, required int column}) : this(type: TokenType.COMPARISON_EQUAL, value: "=", line: line, column: column);
  Lexem.stringLiteral({required String value, required int line, required int column}) : this(type: TokenType.STRING_LITERAL, value: value, line: line, column: column);
  Lexem.openParenthesis({required int line, required int column}) : this(type: TokenType.OPEN_PARENTHESIS, value: "(", line: line, column: column);
  Lexem.closeParenthesis({required int line, required int column}) : this(type: TokenType.CLOSE_PARENTHESIS, value: ")", line: line, column: column);
  Lexem.semicolon({required int line, required int column}) : this(type: TokenType.SEMICOLON, value: ";", line: line, column: column);

  @override
  String toString() => "[$line:$column] $type (value=\"$value\")";
}

class Identifier {
  const Identifier(this.id, {required this.line, required this.column});
  final String id;
  final int line;
  final int column;

  @override
  String toString() => "[$line:$column] $id";
}
