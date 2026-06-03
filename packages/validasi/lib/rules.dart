import 'src/rules/transform.dart';
import 'src/rules/nullable.dart';
import 'src/rules/required.dart';
import 'src/rules/inline_rule.dart';
import 'src/rules/having.dart';

import 'src/rules/string/max_length.dart';
import 'src/rules/string/one_of.dart';

import 'src/rules/iterable/foreach.dart';

import 'src/rules/numbers/finite.dart';
import 'src/rules/numbers/less_than.dart';
import 'src/rules/numbers/less_than_equal.dart';
import 'src/rules/numbers/more_than.dart';
import 'src/rules/numbers/more_than_equal.dart';

import 'src/rules/map/has_fields.dart';
import 'src/rules/map/has_field_keys.dart';
import 'src/rules/map/conditional_field.dart';

import 'src/engine/rule.dart';
import 'src/rules/map/field_rules.dart';

import 'src/rules/string/min_length.dart' as string_min_len;
import 'src/rules/iterable/min_length.dart' as iterable_min_len;

export 'src/rules/map/field_rules.dart';
export 'src/rules/map/conditional_field.dart' show ConditionalFieldCallback;
export 'src/engine/rule.dart' show Rule;
export 'src/engine/result.dart' show ValidasiResult;
export 'src/engine/error.dart' show ValidationError;

final class Rules {
  const Rules._();

  static Required<T> required<T>({String? message}) =>
      Required<T>(message: message);

  static Nullable<T> nullable<T>() => Nullable<T>();

  static Transform<T> transform<T>(T? Function(T? value) transformer,
          {String? message}) =>
      Transform<T>(transformer, message: message);

  static InlineRule<T> inline<T>(
    bool Function(T? value) validator, {
    String? message,
    String name = 'inline_rule',
  }) =>
      InlineRule<T>(validator, message: message, name: name);

  static Having<T> having<T>(List<T> validValues, {String? message}) =>
      Having<T>(validValues, message: message);

  static const string = _StringRules();
  static const number = _NumberRules();
  static const iterable = _IterableRules();
  static const map = _MapRules();
}

class _StringRules {
  const _StringRules();

  string_min_len.MinLength minLength(int length, {String? message}) =>
      string_min_len.MinLength(length, message: message);

  MaxLength maxLength(int length, {String? message}) =>
      MaxLength(length, message: message);

  OneOf oneOf(List<String> validValues, {String? message}) =>
      OneOf(validValues, message: message);
}

class _NumberRules {
  const _NumberRules();

  Finite finite({String? message}) => Finite(message: message);

  LessThan<T> lessThan<T extends num>(T value, {String? message}) =>
      LessThan<T>(value, message: message);

  LessThanEqual<T> lessThanEqual<T extends num>(T value, {String? message}) =>
      LessThanEqual<T>(value, message: message);

  MoreThan<T> moreThan<T extends num>(T value, {String? message}) =>
      MoreThan<T>(value, message: message);

  MoreThanEqual<T> moreThanEqual<T extends num>(T value, {String? message}) =>
      MoreThanEqual<T>(value, message: message);
}

class _IterableRules {
  const _IterableRules();

  iterable_min_len.MinLength<T> minLength<T>(int length, {String? message}) =>
      iterable_min_len.MinLength<T>(length, message: message);

  ForEach<T> forEach<T>(List<Rule<T>> rules) => ForEach<T>(rules);
}

class _MapRules {
  const _MapRules();

  HasFields hasFields(Map<String, FieldRules<Object?>> fields) =>
      HasFields(fields);

  HasFieldKeys<T> hasFieldKeys<T>(Set<String> keys) => HasFieldKeys<T>(keys);

  ConditionalField<T> conditionalField<T>(
          String field, ConditionalFieldCallback<T> callback) =>
      ConditionalField<T>(field, callback);
}
