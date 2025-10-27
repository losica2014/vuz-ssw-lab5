// ignore_for_file: constant_identifier_names

import 'package:lab5/src/types.dart';

class UnexpectedCharacterException implements Exception {
  UnexpectedCharacterException({required this.character, required this.line, required this.column, required this.state, this.expected});
  final String character;
  final int line;
  final int column;
  final LexerState state;
  final String? expected;

  @override
  String toString() => "[$state] Неожиданный символ ($line:$column): \"$character\". ${(expected != null && expected!.isNotEmpty) ? "Ожидался: $expected." : ""}";
}
