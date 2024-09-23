import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/validator.dart';

/// Responsible for validating arrays based on [validator].
class ArrayValidator<V extends Validator, T> extends Validator<List<T>> {
  final V validator;

  ArrayValidator(this.validator);

  /// [required] indicate that the [value] cannot be `null`
  ArrayValidator<V, T> required({String? message}) {
    addRule(
      name: 'required',
      test: (value) => value != null,
      message: message ?? ':name is required',
    );

    return this;
  }

  @override
  ArrayValidator custom(callback) => super.custom(callback);

  @override
  ArrayValidator customFor(customRule) => super.customFor(customRule);

  @override
  Result<List<T>> parse(dynamic value, {String path = 'field'}) {
    var result = super.parse(value, path: path);

    if (result.value == null) {
      return result;
    }

    final List<T> values = [];

    for (var (i, row) in result.value!.indexed) {
      var result = validator.parse(row, path: "$path.$i");
      values.add(result.value);
    }

    return Result(value: values);
  }

  @override
  Future<Result<List<T>>> parseAsync(dynamic value,
      {String path = 'field'}) async {
    var result = await super.parseAsync(value, path: path);

    if (result.value == null) {
      return result;
    }

    final List<T> values = [];

    for (var (i, row) in result.value!.indexed) {
      var result = await validator.parseAsync(row, path: "$path.$i");
      values.add(result.value);
    }

    return Result(value: values);
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
