import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/rule.dart';

class Validasi {
  static bool withCache = true;

  static T withoutCache<T>(T Function() callback) {
    final previousState = withCache;

    try {
      withCache = false;
      final result = callback();
      return result;
    } finally {
      withCache = previousState;
    }
  }

  static ValidasiEngine<String> string([List<Rule<String>>? rules]) =>
      ValidasiEngine(rules: rules, cacheEnabled: withCache);

  static ValidasiEngine<List<T>> list<T>([List<Rule<List<T>>>? rules]) =>
      ValidasiEngine(rules: rules, cacheEnabled: withCache);

  static ValidasiEngine<Map<String, T>> map<T>(
      [List<Rule<Map<String, T>>>? rules]) {
    return ValidasiEngine(rules: rules, cacheEnabled: withCache);
  }

  static ValidasiEngine<T> any<T>([List<Rule<T>>? rules]) =>
      ValidasiEngine(rules: rules, cacheEnabled: withCache);
}
