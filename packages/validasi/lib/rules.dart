import 'src/rules/transform.dart';
import 'src/rules/nullable.dart';
import 'src/rules/required.dart';
import 'src/rules/inline_rule.dart';
import 'src/rules/having.dart';

import 'src/rules/string/alpha.dart';
import 'src/rules/string/alphanumeric.dart';
import 'src/rules/string/case.dart';
import 'src/rules/string/contains.dart';
import 'src/rules/string/email.dart';
import 'src/rules/string/ends_with.dart';
import 'src/rules/string/ip.dart';
import 'src/rules/string/max_length.dart';
import 'src/rules/string/numeric.dart';
import 'src/rules/string/one_of.dart';
import 'src/rules/string/regex.dart';
import 'src/rules/string/starts_with.dart';
import 'src/rules/string/ulid.dart';
import 'src/rules/string/url.dart';
import 'src/rules/string/uuid.dart';

import 'src/rules/iterable/foreach.dart';
import 'src/rules/iterable/exact_length.dart';
import 'src/rules/iterable/is_empty.dart';
import 'src/rules/iterable/is_not_empty.dart';
import 'src/rules/iterable/not_contains.dart';
import 'src/rules/iterable/unique.dart';
import 'src/rules/iterable/contains_all.dart';

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
import 'src/rules/iterable/max_length.dart' as iterable_max_len;
import 'src/rules/iterable/contains.dart' as iterable_contains;

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

  Alpha alpha({String? message}) => Alpha(message: message);

  Alphanumeric alphanumeric({String? message}) =>
      Alphanumeric(message: message);

  Contains contains(String substring, {String? message}) =>
      Contains(substring, message: message);

  Email email({
    bool allowTopLevelDomain = false,
    bool allowInternational = false,
    List<String>? domains,
    String? message,
  }) =>
      Email(
        allowTopLevelDomain: allowTopLevelDomain,
        allowInternational: allowInternational,
        domains: domains,
        message: message,
      );

  EndsWith endsWith(String suffix, {String? message}) =>
      EndsWith(suffix, message: message);

  Ip ip({String? message}) => Ip(message: message);

  Ipv4 ipv4({String? message}) => Ipv4(message: message);

  Ipv6 ipv6({String? message}) => Ipv6(message: message);

  Lowercase lowercase({String? message}) => Lowercase(message: message);

  string_min_len.MinLength minLength(int length, {String? message}) =>
      string_min_len.MinLength(length, message: message);

  MaxLength maxLength(int length, {String? message}) =>
      MaxLength(length, message: message);

  Numeric numeric({String? message}) => Numeric(message: message);

  OneOf oneOf(List<String> validValues, {String? message}) =>
      OneOf(validValues, message: message);

  Regex regex(String pattern, {String? message}) =>
      Regex(pattern, message: message);

  StartsWith startsWith(String prefix, {String? message}) =>
      StartsWith(prefix, message: message);

  Ulid ulid({String? message}) => Ulid(message: message);

  Url url({
    bool requireScheme = true,
    bool requireHost = true,
    bool httpsOnly = false,
    String? message,
  }) =>
      Url(
        requireScheme: requireScheme,
        requireHost: requireHost,
        httpsOnly: httpsOnly,
        message: message,
      );

  Uppercase uppercase({String? message}) => Uppercase(message: message);

  Uuid uuid({List<int> versions = const [4, 7], String? message}) =>
      Uuid(versions: versions, message: message);
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

  iterable_max_len.MaxLength<T> maxLength<T>(int length, {String? message}) =>
      iterable_max_len.MaxLength<T>(length, message: message);

  ExactLength<T> exactLength<T>(int length, {String? message}) =>
      ExactLength<T>(length, message: message);

  IsEmpty<T> isEmpty<T>({String? message}) => IsEmpty<T>(message: message);

  IsNotEmpty<T> isNotEmpty<T>({String? message}) =>
      IsNotEmpty<T>(message: message);

  iterable_contains.Contains<T> contains<T>(
    T element, {
    bool Function(T a, T b)? equals,
    String? message,
  }) =>
      iterable_contains.Contains<T>(element, equals: equals, message: message);

  NotContains<T> notContains<T>(
    T element, {
    bool Function(T a, T b)? equals,
    String? message,
  }) =>
      NotContains<T>(element, equals: equals, message: message);

  Unique<T> unique<T>({bool Function(T a, T b)? equals, String? message}) =>
      Unique<T>(equals: equals, message: message);

  ContainsAll<T> containsAll<T>(
    List<T> elements, {
    bool Function(T a, T b)? equals,
    String? message,
  }) =>
      ContainsAll<T>(elements, equals: equals, message: message);

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
