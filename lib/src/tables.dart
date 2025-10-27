// ignore_for_file: constant_identifier_names

import 'dart:collection';
import 'package:lab5/src/types.dart';

class IdentifierTable {
  final Map<String, Identifier> _table = {};

  UnmodifiableMapView<String, Identifier> get table => UnmodifiableMapView(_table);

  Identifier? operator [](String? key) {
    return _table[key];
  }

  bool has(Identifier identifier) {
    return _table.containsKey(identifier.id);
  }

  void put(Identifier identifier) {
    if(has(identifier)) {
      throw Exception("Идентификатор с таким именем уже существует");
    } else {
      _table[identifier.id] = identifier;
    }
  }

  void tryPut(Identifier identifier) {
    if(!has(identifier)) {
      _table[identifier.id] = identifier;
    }
  }

  @override
  String toString() {
    StringBuffer buf = StringBuffer();
    buf.writeln("Таблица идентификаторов:");
    _table.forEach((key, value) => buf.writeln("$key: $value"));
    return buf.toString();
  }
}

class LexemTable {
  final List<Lexem> _table = [];

  UnmodifiableListView<Lexem> get table => UnmodifiableListView(_table);

  void add(Lexem lexem) {
    _table.add(lexem);
  }

  @override
  String toString() {
    StringBuffer buf = StringBuffer();
    buf.writeln("Таблица лексем:");
    for (var lexem in _table) {
      buf.writeln(lexem.toString());
    }
    return buf.toString();
  }
}
