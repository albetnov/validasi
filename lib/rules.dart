export 'src/rules/transform.dart';
export 'src/rules/nullable.dart';
export 'src/rules/inline_rule.dart';
export 'src/rules/required.dart';

import 'package:validasi/engine.dart';

import 'src/rules/string/rules.dart' as string_rules;
import 'src/rules/iterable/rules.dart' as iterable_rules;
import 'src/rules/map/rules.dart' as map_rules;

class StringRules {
  static string_rules.MinLength minLength(int length, {String? message}) {
    return string_rules.MinLength(length, message: message);
  }

  static string_rules.MaxLength maxLength(int length, {String? message}) {
    return string_rules.MaxLength(length, message: message);
  }
}

class IterableRules {
  static iterable_rules.MinLength<T> minLength<T>(int length,
      {String? message}) {
    return iterable_rules.MinLength(length, message: message);
  }

  static iterable_rules.ForEach<T> forEach<T>(ValidasiEngine<T> validator) {
    return iterable_rules.ForEach(validator);
  }
}

class MapRules {
  static map_rules.HasFields<T> hasFields<T>(
      Map<String, ValidasiEngine<T>> validator) {
    return map_rules.HasFields(validator);
  }
}
