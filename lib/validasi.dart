library;

import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/rule.dart';

class Validasi {
  static ValidasiEngine<String> string([List<Rule<String>>? rules]) =>
      ValidasiEngine(rules: rules);

  static ValidasiEngine<List<T>> list<T>([List<Rule<List<T>>>? rules]) =>
      ValidasiEngine(rules: rules);

  static ValidasiEngine<Map<String, T>> map<T>(
      [List<Rule<Map<String, T>>>? rules]) {
    return ValidasiEngine(rules: rules);
  }
}
