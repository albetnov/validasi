import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/validator.dart';

/// Responsible for validating the object based on [schema].
class ObjectValidator<T extends Map> extends Validator<T> {
  final Map<String, Validator> schema;

  ObjectValidator(this.schema);

  @override
  ObjectValidator nullable() => super.nullable();

  @override
  ObjectValidator custom(CustomCallback<T> callback) => super.custom(callback);

  @override
  ObjectValidator customFor(CustomRule<T> customRule) =>
      super.customFor(customRule);

  /// Extend the schema with the provided [key] and [validator].
  /// Return new instance of [ObjectValidator].
  ObjectValidator<T> extend(Map<String, Validator> newSchema) {
    var schema = Map<String, Validator>.from(this.schema);
    schema.addAll(newSchema);

    return ObjectValidator(schema);
  }

  /// Remove the [key] from the schema.
  /// Return new instance of [ObjectValidator].
  ObjectValidator<T> without(List<String> key) {
    var newSchema = Map<String, Validator>.from(schema);

    for (var element in key) {
      newSchema.remove(element);
    }

    return ObjectValidator(newSchema);
  }

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
  Result<T> tryParse(dynamic value, {String path = 'field'}) {
    var values = super.tryParse(value, path: path);

    if (values.value == null) {
      return values;
    }

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

  @override
  Future<Result<T>> tryParseAsync(dynamic value,
      {String path = 'field'}) async {
    var values = await super.tryParseAsync(value, path: path);

    if (values.value == null) {
      return values;
    }

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
