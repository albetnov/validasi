import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/compiler/compiler.dart';
import 'package:validasi/src/executor/executor.dart';
import 'package:validasi/src/rules/rule.dart' as new_rules;

class Validasi {
  static ValidasiEngine<String, String> string([List<Rule<String>>? rules]) =>
      ValidasiEngine(rules: rules);

  static ValidasiEngine<List<T>, List<T>> list<T>(
          [List<Rule<List<T>>>? rules]) =>
      ValidasiEngine(rules: rules);

  static ValidasiEngine<Map<String, T>, Map<String, T>> map<T>(
      [List<Rule<Map<String, T>>>? rules]) {
    return ValidasiEngine(rules: rules);
  }

  static ValidasiEngine<T, T> number<T extends num>([List<Rule<T>>? rules]) =>
      ValidasiEngine(rules: rules);

  static ValidasiEngine<T, T> any<T>([List<Rule<T>>? rules]) =>
      ValidasiEngine(rules: rules);
}

class ValidasiExecutor {
  static Executor<String> string([List<new_rules.StringRule>? rules]) {
    final compiled = Compiler().compile<String>(rules ?? []);
    return Executor<String>(
      rules: compiled.rules,
      stringTable: compiled.stringTable,
      nestedRules: compiled.nestedRules,
    );
  }

  static Executor<List> list([List<new_rules.ListRule>? rules]) {
    final compiled = Compiler().compile<List>(rules ?? []);
    return Executor<List>(
      rules: compiled.rules,
      stringTable: compiled.stringTable,
      nestedRules: compiled.nestedRules,
    );
  }
}
