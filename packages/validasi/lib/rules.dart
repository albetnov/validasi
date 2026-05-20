export 'src/rules/transform.dart';
export 'src/rules/nullable.dart';
export 'src/rules/inline_rule.dart';
export 'src/rules/required.dart';
export 'src/rules/having.dart';
export 'src/rules/iterable/foreach.dart';
export 'src/rules/numbers/finite.dart';
export 'src/rules/numbers/less_than.dart';
export 'src/rules/numbers/less_than_equal.dart';
export 'src/rules/numbers/more_than.dart';
export 'src/rules/numbers/more_than_equal.dart';
export 'src/rules/map/field_rules.dart';
export 'src/rules/map/has_fields.dart';
export 'src/rules/map/has_field_keys.dart';
export 'src/rules/map/conditional_field.dart';

import 'package:validasi/engine.dart';
import 'package:validasi/src/rules/map/conditional_field.dart';

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

  static string_rules.OneOf oneOf(List<String> validValues, {String? message}) {
    return string_rules.OneOf(validValues, message: message);
  }
}

class IterableRules {
  static iterable_rules.MinLength<T> minLength<T>(int length,
      {String? message}) {
    return iterable_rules.MinLength(length, message: message);
  }

  static iterable_rules.ForEach<T> forEach<T>(
      List<Rule<T>> rules) {
    return iterable_rules.ForEach(rules);
  }
}

class MapRules {
  static map_rules.HasFields hasFields(
      Map<String, map_rules.FieldRules<Object?>> fields) {
    return map_rules.HasFields(fields);
  }

  static map_rules.HasFieldKeys<T> hasFieldKeys<T>(Set<String> keys) {
    return map_rules.HasFieldKeys(keys);
  }

  static map_rules.ConditionalField<T> conditionalField<T>(
      String field, ConditionalFieldCallback<T> callback) {
    return map_rules.ConditionalField(field, callback);
  }
}

class NumberRules {
  static number_rules.Finite finite({String? message}) {
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
