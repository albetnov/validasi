import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/validator.dart';

/// Responsible for validating arrays/[List] based on provided [validator].
class ArrayValidator<V extends Validator, T> extends Validator<List<T>> {
  final V validator;

  ArrayValidator(this.validator);

  @override
  ArrayValidator nullable() => super.nullable();

  @override
  ArrayValidator custom(CustomCallback<List<T>> callback) =>
      super.custom(callback);

  @override
  ArrayValidator customFor(CustomRule<List<T>> customRule) =>
      super.customFor(customRule);

  /// Check if the value length is more or equal to [min].
  ArrayValidator<V, T> min(int min, {String? message}) {
    addRule(
      name: 'min',
      test: (value) => value.length >= min,
      message: message ?? ':name must have at least $min items',
    );

    return this;
  }

  /// Check if the value length is less or equal to [max].
  ArrayValidator<V, T> max(int max, {String? message}) {
    addRule(
      name: 'max',
      test: (value) => value.length <= max,
      message: message ?? ':name must have at most $max items',
    );

    return this;
  }

  /// Ensure the value not contains any of the provided [values].
  ArrayValidator<V, T> notContains(List<T> values, {String? message}) {
    addRule(
      name: 'notContains',
      test: (value) => !value.any((element) => values.contains(element)),
      message: message ?? ':name must not contain $values',
    );

    return this;
  }

  /// Ensure the value should only contains the provided values. If
  /// the value contains other values, it will be considered invalid.
  ArrayValidator<V, T> contains(List<T> values, {String? message}) {
    addRule(
      name: 'contains',
      test: (value) => value.every((element) => values.contains(element)),
      message: message ?? ':name must contain $values',
    );

    return this;
  }

  /// Ensure the value are all unique.
  ArrayValidator<V, T> unique({String? message}) {
    addRule(
      name: 'unique',
      test: (value) => value.toSet().length == value.length,
      message: message ?? ':name must contain unique items',
    );

    return this;
  }

  @override
  Result<List<T>> tryParse(dynamic value, {String path = 'field'}) {
    var result = super.tryParse(value, path: path);

    if (result.value == null) {
      return result;
    }

    final List<T> values = [];

    for (var (i, row) in result.value!.indexed) {
      var currentResult = validator.tryParse(row, path: "$path.$i");
      values.add(currentResult.value);

      if (!currentResult.isValid) {
        result.errors.addAll(currentResult.errors);
      }
    }

    return Result(value: values, errors: result.errors);
  }

  @override
  Future<Result<List<T>>> tryParseAsync(dynamic value,
      {String path = 'field'}) async {
    var result = await super.tryParseAsync(value, path: path);

    if (result.value == null) {
      return result;
    }

    final List<T> values = [];

    for (var (i, row) in result.value!.indexed) {
      var currentResult = await validator.tryParseAsync(row, path: "$path.$i");
      values.add(currentResult.value);

      if (!currentResult.isValid) {
        result.errors.addAll(currentResult.errors);
      }
    }

    return Result(value: values, errors: result.errors);
  }
}
