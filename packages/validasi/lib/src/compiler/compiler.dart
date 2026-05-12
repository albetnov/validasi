import 'dart:collection';
import 'dart:typed_data';

import 'package:validasi/src/compiler/compiled_rule.dart';
import 'package:validasi/src/compiler/compiled_schema.dart';
import 'package:validasi/src/rules/list_rules.dart';
import 'package:validasi/src/rules/rule.dart';
import 'package:validasi/src/rules/string_rules.dart';

class Compiler {
  final List<String> _stringTable = [];
  final HashMap<String, int> _stringIndex = HashMap<String, int>();
  final List<List<CompiledRule>> _nestedRules = [];

  CompiledSchema compile<T>(List<Rule<T>> rules) {
    final compiled = <CompiledRule>[];
    for (final rule in rules) {
      compiled.add(_compileRule(rule as Rule<Object>));
    }
    return CompiledSchema(
      rules: compiled,
      stringTable: List.unmodifiable(_stringTable),
      nestedRules: List.unmodifiable(_nestedRules),
    );
  }

  CompiledRule _compileRule(Rule<Object> rule) {
    if (rule is StringMinLengthRule) {
      return CompiledRule(rule.opcode, Int32List(1)..[0] = rule.min);
    }
    if (rule is StringMaxLengthRule) {
      return CompiledRule(rule.opcode, Int32List(1)..[0] = rule.max);
    }
    if (rule is StringOneOfRule) {
      return _compileOneOf(rule);
    }
    if (rule is ListMinLengthRule) {
      return CompiledRule(rule.opcode, Int32List(1)..[0] = rule.min);
    }
    if (rule is ListForEachRule) {
      return _compileForEach(rule);
    }
    throw ArgumentError('Unknown rule type: ${rule.runtimeType}');
  }

  CompiledRule _compileOneOf(StringOneOfRule rule) {
    final indices = Int32List(rule.options.length);
    for (var i = 0; i < rule.options.length; i++) {
      indices[i] = _addString(rule.options[i]);
    }
    return CompiledRule(rule.opcode, indices);
  }

  int _addString(String value) {
    return _stringIndex.putIfAbsent(value, () {
      _stringTable.add(value);
      return _stringTable.length - 1;
    });
  }

  CompiledRule _compileForEach(ListForEachRule rule) {
    final nestedIndex = _nestedRules.length;
    final nested = <CompiledRule>[];
    for (final r in rule.rules) {
      nested.add(_compileRule(r as Rule<Object>));
    }
    _nestedRules.add(nested);
    return CompiledRule(rule.opcode, Int32List(1)..[0] = nestedIndex);
  }
}
