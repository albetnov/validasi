import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/validator.dart';

class ObjectValidator<T extends Map> extends Validator<T> {
  final Map<String, Validator> schema;

  ObjectValidator(this.schema);

  /// [required] indicate that the object cannot be [null].
  ObjectValidator required({String? message}) {
    addRule(
      name: 'required',
      test: (value) => value != null,
      message: message ?? ':name is required',
    );

    return this;
  }

  @override
  ObjectValidator custom(callback) => super.custom(callback);

  @override
  ObjectValidator customFor(customRule) => super.customFor(customRule);

  _parse(Result result) {
    if (result.value is Map) {
      Map<String, dynamic> results = {};

      for (var entry in result.value.entries) {
        results[entry.key] = entry.value;
      }

      return results;
    }

    return result.value;
  }

  /// [parse] will run recursively validating each values from the [schema].
  ///
  /// throw [FieldError] if any error encountered, return freshly recreated
  /// [Result] if success (alongside with the type-casts if available).
  @override
  Result<T> parse(T? value, {String path = 'field'}) {
    var values = super.parse(value, path: path);

    if (values.value == null) {
      return values;
    }

    final T results = {} as T;

    for (var row in schema.entries) {
      var result = row.value.parse(values.value?[row.key], path: path);

      results[row.key] = _parse(result);
    }

    return Result(value: results);
  }

  /// Similar to [parse]. [parseAsync] however will run in asyncronous context.
  ///
  /// throw [FieldError] if any error encountered, return freshly recreated
  /// [Result] if success (alongside with the type-casts if available).
  @override
  Future<Result<T>> parseAsync(T? value, {String path = 'field'}) async {
    var values = await super.parseAsync(value, path: path);

    if (values.value == null) {
      return values;
    }

    final T results = {} as T;

    for (var row in schema.entries) {
      var result =
          await row.value.parseAsync(values.value?[row.key], path: path);

      results[row.key] = _parse(result);
    }

    return Result(value: results);
  }

  /// [tryParse] will return [Result] and contains [errors] if any error
  /// encountered.
  @override
  Result<T> tryParse(T? value, {String path = 'field'}) {
    var values = super.tryParse(value, path: path);

    final T results = {} as T;

    for (var row in schema.entries) {
      var result =
          row.value.tryParse(values.value?[row.key], path: "$path.${row.key}");

      results[row.key] = _parse(result);

      if (!result.isValid) {
        values.errors.addAll(result.errors);
      }
    }

    return Result(value: results, errors: values.errors);
  }

  /// Similar to [tryParse]. But, The [tryParseAsync] will run on Asyncronous
  /// context instead.
  @override
  Future<Result<T>> tryParseAsync(T? value, {String path = 'field'}) async {
    var values = await super.tryParseAsync(value, path: path);

    final T results = {} as T;

    for (var row in schema.entries) {
      var result = await row.value
          .tryParseAsync(values.value?[row.key], path: "$path.${row.key}");

      results[row.key] = _parse(result);

      if (!result.isValid) {
        values.errors.addAll(result.errors);
      }
    }

    return Result(value: results, errors: values.errors);
  }
}
