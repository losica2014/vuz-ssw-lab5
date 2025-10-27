import 'package:args/args.dart';
import 'package:lab5/lab5.dart';
import 'dart:io';

void main(List<String> arguments) {
  final parser = ArgParser()
  ..addOption('input', abbr: 'i', mandatory: true, help: 'Входной файл')
  ..addFlag('verbose', abbr: 'v', negatable: false, help: 'Вывод отладочной информации')
  ..addFlag('help', abbr: 'h', negatable: false, help: 'Помощь');
  final result = parser.parse(arguments);

  if (result['help'] == true) {
    print(parser.usage);
    return;
  }

  String input;
  bool debug;

  try {
    input = File(result['input']).readAsStringSync();
    debug = result['verbose'];
  } catch (e) {
    print(e);
    return;
  }

  Lexer lexer = Lexer(debug);

  try {
    lexer.parse(input);
  } catch (e) {
    print(e);
  }
  
  print(lexer.lexemTable);
  print(lexer.identifierTable);
}
