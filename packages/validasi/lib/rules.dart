import 'src/rules/transform.dart';
import 'src/rules/async_transform.dart';
import 'src/rules/nullable.dart';
import 'src/rules/required.dart';
import 'src/rules/inline_rule.dart';
import 'src/rules/async_inline_rule.dart';
import 'src/rules/having.dart';
import 'src/rules/equals.dart';
import 'src/rules/not_equals.dart';
import 'src/rules/any_of.dart';

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

import 'src/rules/numbers/between.dart';
import 'src/rules/numbers/decimal.dart';
import 'src/rules/numbers/finite.dart';
import 'src/rules/numbers/integer.dart';
import 'src/rules/numbers/less_than.dart';
import 'src/rules/numbers/less_than_equal.dart';
import 'src/rules/numbers/more_than.dart';
import 'src/rules/numbers/more_than_equal.dart';
import 'src/rules/numbers/negative.dart';
import 'src/rules/numbers/non_negative.dart';
import 'src/rules/numbers/non_positive.dart';
import 'src/rules/numbers/positive.dart';

import 'src/rules/map/has_fields.dart';
import 'src/rules/map/has_field_keys.dart';
import 'src/rules/map/conditional_field.dart';
import 'src/rules/map/async_conditional_field.dart';
import 'src/rules/map/allowed_keys.dart';
import 'src/rules/map/forbidden_keys.dart';
import 'src/rules/map/min_keys.dart';
import 'src/rules/map/max_keys.dart';
import 'src/rules/map/all_values.dart';
import 'src/rules/map/required_any.dart';
import 'src/rules/map/required_one_of.dart';
import 'src/rules/map/required_all.dart';
import 'src/rules/map/depends_on.dart';
import 'src/rules/map/mutually_exclusive.dart';
import 'src/rules/map/matches_field.dart';

import 'src/engine/rule.dart';
import 'src/rules/map/field_rules.dart';

import 'src/rules/string/min_length.dart' as string_min_len;
import 'src/rules/iterable/min_length.dart' as iterable_min_len;
import 'src/rules/iterable/max_length.dart' as iterable_max_len;
import 'src/rules/iterable/contains.dart' as iterable_contains;

export 'src/rules/map/field_rules.dart';
export 'src/rules/map/conditional_field.dart' show ConditionalFieldCallback;
export 'src/rules/map/async_conditional_field.dart'
    show AsyncConditionalFieldCallback;
export 'src/engine/rule.dart' show Rule, AsyncRule;
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

  static AsyncTransform<T> transformAsync<T>(
          Future<T?> Function(T? value) transformer,
          {String? message}) =>
      AsyncTransform<T>(transformer, message: message);

  static InlineRule<T> inline<T>(
    bool Function(T? value) validator, {
    String? message,
    String name = 'inline_rule',
  }) =>
      InlineRule<T>(validator, message: message, name: name);

  static AsyncInlineRule<T> inlineAsync<T>(
    Future<bool> Function(T? value) validator, {
    String? message,
    String name = 'async_inline_rule',
  }) =>
      AsyncInlineRule<T>(validator, message: message, name: name);

  static Having<T> having<T>(List<T> validValues, {String? message}) =>
      Having<T>(validValues, message: message);

  static Equals<T> equals<T>(
    T expected, {
    bool Function(T a, T b)? equals,
    String? message,
  }) =>
      Equals<T>(expected, equals: equals, message: message);

  static NotEquals<T> notEquals<T>(
    T unexpected, {
    bool Function(T a, T b)? equals,
    String? message,
  }) =>
      NotEquals<T>(unexpected, equals: equals, message: message);

  static AnyOf<T> anyOf<T>(
    List<List<Rule<T>>> ruleSets, {
    String? message,
  }) =>
      AnyOf<T>(ruleSets, message: message);

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

  Between<T> between<T extends num>(T min, T max, {String? message}) =>
      Between<T>(min, max, message: message);

  Decimal decimal({String? message}) => Decimal(message: message);

  Finite finite({String? message}) => Finite(message: message);

  Integer integer({String? message}) => Integer(message: message);

  LessThan<T> lessThan<T extends num>(T value, {String? message}) =>
      LessThan<T>(value, message: message);

  LessThanEqual<T> lessThanEqual<T extends num>(T value, {String? message}) =>
      LessThanEqual<T>(value, message: message);

  MoreThan<T> moreThan<T extends num>(T value, {String? message}) =>
      MoreThan<T>(value, message: message);

  MoreThanEqual<T> moreThanEqual<T extends num>(T value, {String? message}) =>
      MoreThanEqual<T>(value, message: message);

  Negative<T> negative<T extends num>({String? message}) =>
      Negative<T>(message: message);

  NonNegative<T> nonNegative<T extends num>({String? message}) =>
      NonNegative<T>(message: message);

  NonPositive<T> nonPositive<T extends num>({String? message}) =>
      NonPositive<T>(message: message);

  Positive<T> positive<T extends num>({String? message}) =>
      Positive<T>(message: message);
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
    Object? Function(T)? keySelector,
    String? message,
  }) =>
      iterable_contains.Contains<T>(
        element,
        keySelector: keySelector,
        message: message,
      );

  NotContains<T> notContains<T>(
    T element, {
    Object? Function(T)? keySelector,
    String? message,
  }) =>
      NotContains<T>(
        element,
        keySelector: keySelector,
        message: message,
      );

  Unique<T> unique<T>({
    bool Function(T a, T b)? equals,
    int Function(T)? hasher,
    Object? Function(T)? keySelector,
    String? message,
  }) =>
      Unique<T>(
        equals: equals,
        hasher: hasher,
        keySelector: keySelector,
        message: message,
      );

  ContainsAll<T> containsAll<T>(
    List<T> elements, {
    Object? Function(T)? keySelector,
    String? message,
  }) =>
      ContainsAll<T>(elements, keySelector: keySelector, message: message);

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

  AsyncConditionalField<T> conditionalFieldAsync<T>(
          String field, AsyncConditionalFieldCallback<T> callback) =>
      AsyncConditionalField<T>(field, callback);

  AllowedKeys<T> allowedKeys<T>(Set<String> keys, {String? message}) =>
      AllowedKeys<T>(keys, message: message);

  ForbiddenKeys<T> forbiddenKeys<T>(Set<String> keys, {String? message}) =>
      ForbiddenKeys<T>(keys, message: message);

  MinKeys<T> minKeys<T>(int min, {String? message}) =>
      MinKeys<T>(min, message: message);

  MaxKeys<T> maxKeys<T>(int max, {String? message}) =>
      MaxKeys<T>(max, message: message);

  AllValues<T> allValues<T>(List<Rule<T>> rules) => AllValues<T>(rules);

  RequiredAny<T> requiredAny<T>(List<String> fields, {String? message}) =>
      RequiredAny<T>(fields, message: message);

  RequiredOneOf<T> requiredOneOf<T>(List<String> fields, {String? message}) =>
      RequiredOneOf<T>(fields, message: message);

  RequiredAll<T> requiredAll<T>(List<String> fields, {String? message}) =>
      RequiredAll<T>(fields, message: message);

  DependsOn<T> dependsOn<T>(String field, String dependsOn,
          {String? message}) =>
      DependsOn<T>(field, dependsOn, message: message);

  MutuallyExclusive<T> mutuallyExclusive<T>(String fieldA, String fieldB,
          {String? message}) =>
      MutuallyExclusive<T>(fieldA, fieldB, message: message);

  MatchesField<T> matchesField<T>(
    String field,
    String matchesField, {
    bool Function(T a, T b)? equals,
    String? message,
  }) =>
      MatchesField<T>(field, matchesField, equals: equals, message: message);
}
