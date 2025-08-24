export 'src/rules/transform.dart';
export 'src/rules/nullable.dart';
export 'src/rules/inline_rule.dart';
export 'src/rules/required.dart';

import 'package:validasi/engine.dart';

import 'src/rules/string/rules.dart' as string_rules;
import 'src/rules/iterable/rules.dart' as iterable_rules;
import 'src/rules/map/rules.dart' as map_rules;
import 'src/rules/numbers/rules.dart' as number_rules;

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

class NumberRules {
  static number_rules.Finite<T> finite<T extends num>({String? message}) {
    return number_rules.Finite(message: message);
  }

  static number_rules.LessThan<T> lessThan<T extends num>(T value,
      {String? message}) {
    return number_rules.LessThan(value, message: message);
  }

  static number_rules.LessThanEqual<T> lessThanEqual<T extends num>(T value,
      {String? message}) {
    return number_rules.LessThanEqual(value, message: message);
  }

  static number_rules.MoreThan<T> moreThan<T extends num>(T value,
      {String? message}) {
    return number_rules.MoreThan(value, message: message);
  }

  static number_rules.MoreThanEqual<T> moreThanEqual<T extends num>(T value,
      {String? message}) {
    return number_rules.MoreThanEqual(value, message: message);
  }
}
