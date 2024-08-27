import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/validator.dart';

class ObjectValidator<T extends Map> extends Validator<T> {
  final Map<String, Validator> schema;

  ObjectValidator(this.schema);

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

  @override
  Result<T> parse(T? value, {String path = 'field'}) {
    final T results = {} as T;

    for (var row in schema.entries) {
      var result = row.value.parse(value?[row.key], path: path);

      results[row.key] = _parse(result);
    }

    return Result(value: results);
  }

  @override
  Future<Result<T>> parseAsync(T? value, {String path = 'field'}) async {
    final T results = {} as T;

    for (var row in schema.entries) {
      var result = await row.value.parseAsync(value?[row.key], path: path);

      results[row.key] = _parse(result);
    }

    return Result(value: results);
  }

  @override
  Result<T> tryParse(T? value, {String path = 'field'}) {
    final T results = {} as T;
    final List<FieldError> errors = [];

    for (var row in schema.entries) {
      var result =
          row.value.tryParse(value?[row.key], path: "$path.${row.key}");

      results[row.key] = _parse(result);

      if (!result.isValid) {
        errors.addAll(result.errors);
      }
    }

    return Result(value: results, errors: errors);
  }

  @override
  Future<Result<T>> tryParseAsync(T? value, {String path = 'field'}) async {
    final T results = {} as T;
    final List<FieldError> errors = [];

    for (var row in schema.entries) {
      var result = await row.value
          .tryParseAsync(value?[row.key], path: "$path.${row.key}");

      results[row.key] = _parse(result);

      if (!result.isValid) {
        errors.addAll(result.errors);
      }
    }

    return Result(value: results, errors: errors);
  }
}
