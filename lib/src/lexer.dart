import 'package:lab5/src/exceptions.dart';
import 'package:lab5/src/types.dart';
import 'package:lab5/src/tables.dart';

class Lexer {
  Lexer([this.debug = false]);
  
  /// Выводить ли отладочную информацию по ходу анализа.
  final bool debug;

  LexerState _state = LexerState.H;
  final LexemTable lexemTable = LexemTable();
  final IdentifierTable identifierTable = IdentifierTable();

  final StringBuffer _buf = StringBuffer();

  int _line = 1;
  int _column = 1;

  int _trueLine = 1;
  int _trueColumn = 1;

  static const eof = "EOF";

  void parse(String text) {
    _line = _trueLine = 1;
    _column = _trueColumn = 1;
    for(int i = 0; i < text.length; i++) {
      String character = text[i];
      if(debug) print("[$_trueLine:$_trueColumn] Символ \"$character\" (${character.runes.map((e) => e.toRadixString(16)).join(" ")}). Состояние до: $_state. Буфер до: \"$_buf\".");
      process(character);
      if(character == '\n') {
        _trueLine++;
        _trueColumn = 1;
      } else {
        _trueColumn++;
      }
    }
    process(eof);
    if(_state != LexerState.F && _state != LexerState.H) {
      throw Exception("[$_trueLine:$_trueColumn] Неожиданный конец текста.");
    }
  }

  void process(String character) {
    if(_state == LexerState.F) {
      _state = LexerState.H;
      _line = _trueLine;
      _column = _trueColumn;
      _buf.clear();
    }
    switch(_state) {
      case LexerState.H:
        switch(character) {
          case 'f':
            _state = LexerState.FOR1;
            break;
          case 'd':
            _state = LexerState.DO1;
            break;
          case '/':
            _state = LexerState.CMT1;
            break;
          case '(':
            lexemTable.add(Lexem.openParenthesis(line: _line, column: _column));
            _state = LexerState.F;
            break;
          case ')':
            lexemTable.add(Lexem.closeParenthesis(line: _line, column: _column));
            _state = LexerState.F;
            break;
          case ';':
            lexemTable.add(Lexem.semicolon(line: _line, column: _column));
            _state = LexerState.F;
            break;
          case '"':
            _state = LexerState.STR;
            break;
          case ':':
            _state = LexerState.ASGN;
            break;
          case '>':
            lexemTable.add(Lexem.comparisonMore(line: _line, column: _column));
            _state = LexerState.F;
            break;
          case '<':
            lexemTable.add(Lexem.comparisonLess(line: _line, column: _column));
            _state = LexerState.F;
            break;
          case '=':
            lexemTable.add(Lexem.comparisonEqual(line: _line, column: _column));
            _state = LexerState.F;
            break;
          default:
            if(_B(character, {'f', 'd'})) {
              _state = LexerState.IDENT;
              _buf.write(character);
              break;
            }
            if(_S(character)) {
              _state = LexerState.F;
              break;
            }
            throw UnexpectedCharacterException(character: character, line: _line, column: _column, state: _state);
        }
        break;
      case LexerState.IDENT:
        if(_B(character) || _D(character)) {
          _buf.write(character);
          break;
        }
        switch(character) {
          case ':':
            identifierTable.tryPut(Identifier(_buf.toString(), line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: _buf.toString(), line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            _state = LexerState.ASGN;
            break;
          case '/':
            identifierTable.tryPut(Identifier(_buf.toString(), line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: _buf.toString(), line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            _state = LexerState.CMT1;
            break;
          case '(':
            identifierTable.tryPut(Identifier(_buf.toString(), line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: _buf.toString(), line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.openParenthesis(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case ')':
            identifierTable.tryPut(Identifier(_buf.toString(), line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: _buf.toString(), line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.closeParenthesis(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case ';':
            identifierTable.tryPut(Identifier(_buf.toString(), line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: _buf.toString(), line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.semicolon(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '>':
            identifierTable.tryPut(Identifier(_buf.toString(), line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: _buf.toString(), line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.comparisonMore(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '<':
            identifierTable.tryPut(Identifier(_buf.toString(), line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: _buf.toString(), line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.comparisonLess(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '=':
            identifierTable.tryPut(Identifier(_buf.toString(), line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: _buf.toString(), line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.comparisonEqual(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          default:
            if(_S(character)) {
              identifierTable.tryPut(Identifier(_buf.toString(), line: _line, column: _column));
              lexemTable.add(Lexem.identifier(value: _buf.toString(), line: _line, column: _column));
              _buf.clear();
              _line = _trueLine;
              _column = _trueColumn;
              _state = LexerState.F;
              break;
            } else {
              throw UnexpectedCharacterException(character: character, line: _line, column: _column, state: _state, expected: "Б | Ц | : | / | П");
            }
        }
        break;
      case LexerState.ASGN:
        if(character == '=') {
          lexemTable.add(Lexem.assignmentOperator(line: _line, column: _column));
          _state = LexerState.F;
        } else {
          throw UnexpectedCharacterException(character: character, line: _line, column: _column, state: _state, expected: "=");
        }
        break;
      case LexerState.FOR1:
        switch(character) {
          case 'o':
            _state = LexerState.FOR2;
            break;
          case '/':
            identifierTable.tryPut(Identifier("f", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "f", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            _state = LexerState.CMT1;
            break;
          case ':':
            identifierTable.tryPut(Identifier("f", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "f", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            _state = LexerState.ASGN;
            break;
          case '>':
            identifierTable.tryPut(Identifier("f", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "f", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.comparisonMore(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '<':
            identifierTable.tryPut(Identifier("f", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "f", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.comparisonLess(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '=':
            identifierTable.tryPut(Identifier("f", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "f", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.comparisonEqual(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case ';':
            identifierTable.tryPut(Identifier("f", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "f", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.semicolon(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '(':
            identifierTable.tryPut(Identifier("f", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "f", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.openParenthesis(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case ')':
            identifierTable.tryPut(Identifier("f", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "f", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.closeParenthesis(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          default:
            if(_B(character, {'o'}) || _D(character)) {
              _state = LexerState.IDENT;
              _buf
                ..write('f')
                ..write(character);
              break;
            } else if(_S(character)) {
              identifierTable.tryPut(Identifier("f", line: _line, column: _column));
              lexemTable.add(Lexem.identifier(value: "f", line: _line, column: _column));
              _buf.clear();
              _line = _trueLine;
              _column = _trueColumn;
              _state = LexerState.F;
              break;
            } else {
              throw UnexpectedCharacterException(character: character, line: _line, column: _column, state: _state, expected: "Б(o) | Ц | o | : | / | П");
            }
        }
        break;
      case LexerState.FOR2:
        switch(character) {
          case 'r':
            _state = LexerState.FOR3;
            break;
          case '/':
            identifierTable.tryPut(Identifier("fo", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "fo", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            _state = LexerState.CMT1;
            break;
          case ':':
            identifierTable.tryPut(Identifier("fo", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "fo", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            _state = LexerState.ASGN;
            break;
          case '>':
            identifierTable.tryPut(Identifier("fo", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "fo", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.comparisonMore(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '<':
            identifierTable.tryPut(Identifier("fo", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "fo", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.comparisonLess(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '=':
            identifierTable.tryPut(Identifier("fo", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "fo", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.comparisonEqual(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case ';':
            identifierTable.tryPut(Identifier("fo", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "fo", line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            lexemTable.add(Lexem.semicolon(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          default:
            if(_B(character, {'r'}) || _D(character)) {
              _state = LexerState.IDENT;
              _buf
                ..write('fo')
                ..write(character);
              break;
            } else if(_S(character)) {
              identifierTable.tryPut(Identifier("fo", line: _line, column: _column));
              lexemTable.add(Lexem.identifier(value: "fo", line: _line, column: _column));
              _buf.clear();
              _line = _trueLine;
              _column = _trueColumn;
              _state = LexerState.F;
              break;
            } else {
              throw UnexpectedCharacterException(character: character, line: _line, column: _column, state: _state);
            }
        }
        break;
      case LexerState.FOR3:
        switch(character) {
          case '(':
            lexemTable.add(Lexem.forKeyword(line: _line, column: _column));
            lexemTable.add(Lexem.openParenthesis(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case ')':
            lexemTable.add(Lexem.forKeyword(line: _line, column: _column));
            lexemTable.add(Lexem.closeParenthesis(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case ';':
            lexemTable.add(Lexem.forKeyword(line: _line, column: _column));
            lexemTable.add(Lexem.semicolon(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '/':
            lexemTable.add(Lexem.forKeyword(line: _line, column: _column));
            _state = LexerState.CMT1;
            break;
          default:
            if(_B(character) || _D(character)) {
              _state = LexerState.IDENT;
              _buf
                ..write('for')
                ..write(character);
              break;
            } else if(_S(character)) {
              lexemTable.add(Lexem.forKeyword(line: _line, column: _column));
              _state = LexerState.F;
              break;
            } else {
              throw UnexpectedCharacterException(character: character, line: _line, column: _column, state: _state);
            }
        }
        break;
      case LexerState.DO1:
        switch(character) {
          case 'o':
            _state = LexerState.DO2;
            break;
          case '/':
            identifierTable.tryPut(Identifier("d", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "d", line: _line, column: _column));
            _state = LexerState.CMT1;
            break;
          case ':':
            identifierTable.tryPut(Identifier("d", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "d", line: _line, column: _column));
            _state = LexerState.ASGN;
            break;
          case ';':
            identifierTable.tryPut(Identifier("d", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "d", line: _line, column: _column));
            lexemTable.add(Lexem.semicolon(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '(':
            identifierTable.tryPut(Identifier("d", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "d", line: _line, column: _column));
            lexemTable.add(Lexem.openParenthesis(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case ')':
            identifierTable.tryPut(Identifier("d", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "d", line: _line, column: _column));
            lexemTable.add(Lexem.closeParenthesis(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '>':
            identifierTable.tryPut(Identifier("d", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "d", line: _line, column: _column));
            lexemTable.add(Lexem.comparisonMore(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '<':
            identifierTable.tryPut(Identifier("d", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "d", line: _line, column: _column));
            lexemTable.add(Lexem.comparisonLess(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '=':
            identifierTable.tryPut(Identifier("d", line: _line, column: _column));
            lexemTable.add(Lexem.identifier(value: "d", line: _line, column: _column));
            lexemTable.add(Lexem.comparisonEqual(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          default:
            if(_B(character, {'o'}) || _D(character)) {
              _state = LexerState.IDENT;
              _buf
                ..write('d')
                ..write(character);
              break;
            } else if(_S(character)) {
              identifierTable.tryPut(Identifier("d", line: _line, column: _column));
              lexemTable.add(Lexem.identifier(value: "d", line: _line, column: _column));
              _state = LexerState.F;
              break;
            } else {
              throw UnexpectedCharacterException(character: character, line: _line, column: _column, state: _state);
            }
        }
        break;
      case LexerState.DO2:
        switch(character) {
          case '(':
            lexemTable.add(Lexem.doKeyword(line: _line, column: _column));
            lexemTable.add(Lexem.openParenthesis(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case ')':
            lexemTable.add(Lexem.doKeyword(line: _line, column: _column));
            lexemTable.add(Lexem.closeParenthesis(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case ';':
            lexemTable.add(Lexem.doKeyword(line: _line, column: _column));
            lexemTable.add(Lexem.semicolon(line: _trueLine, column: _trueColumn));
            _state = LexerState.F;
            break;
          case '/':
            lexemTable.add(Lexem.doKeyword(line: _line, column: _column));
            _state = LexerState.CMT1;
            break;
          default:
            if(_B(character) || _D(character)) {
              _state = LexerState.IDENT;
              _buf
                ..write('do')
                ..write(character);
              break;
            } else if(_S(character)) {
              lexemTable.add(Lexem.doKeyword(line: _line, column: _column));
              _state = LexerState.F;
              break;
            } else {
              throw UnexpectedCharacterException(character: character, line: _line, column: _column, state: _state);
            }
        }
        break;
      case LexerState.CMT1:
        switch(character) {
          case '*':
            _state = LexerState.CMT;
            break;
          default:
            throw UnexpectedCharacterException(character: character, line: _line, column: _column, state: _state);
        }
        break;
      case LexerState.CMT:
        switch(character) {
          case '*':
            _state = LexerState.CMT2;
            break;
          default:
            break;            
        }
        break;
      case LexerState.CMT2:
        switch(character) {
          case '/':
            _state = LexerState.F;
            break;
          default:
            _state = LexerState.CMT;
            break;
        }
        break;
      case LexerState.STR:
        switch(character) {
          case '"':
            lexemTable.add(Lexem.stringLiteral(value: _buf.toString(), line: _line, column: _column));
            _buf.clear();
            _line = _trueLine;
            _column = _trueColumn;
            _state = LexerState.F;
            break;
          case '\\':
            _state = LexerState.STR1;
            break;
          default:
            _buf.write(character);
            break;
        }
        break;
      case LexerState.STR1:
        switch(character) {
          case '"':
          case '\\':
            _buf.write(character);
            _state = LexerState.STR;
            break;
          default:
            throw UnexpectedCharacterException(character: character, line: _line, column: _column, state: _state);
        }
        break;
      case LexerState.F:
        throw Error();
    }
  }

  /// Б(исключения)
  /// 
  /// Проверяет, является ли символ буквой или нижним подчеркиванием, кроме символов, указанных в [exclude].
  // ignore: non_constant_identifier_names
  bool _B(String character, [Set<String> exclude = const {}]) {
    return (character.codeUnitAt(0) >= 'A'.runes.single && character.codeUnitAt(0) <= 'Z'.runes.single
    || character.codeUnitAt(0) >= 'a'.runes.single && character.codeUnitAt(0) <= 'z'.runes.single
    || character == '_') && !exclude.contains(character) && character != eof;
  }

  /// Ц()
  /// 
  /// Проверяет, является ли символ цифрой.
  // ignore: non_constant_identifier_names
  bool _D(String character) {
    return character.codeUnitAt(0) >= '0'.runes.single && character.codeUnitAt(0) <= '9'.runes.single;
  }

  /// П()
  /// 
  /// Проверяет, является ли символ пробелом или иным незначащим символом.
  // ignore: non_constant_identifier_names
  bool _S(String character) {
    return character == ' ' || character == '\t' || character == '\n' || character == '\r' || character == eof;
  }
}