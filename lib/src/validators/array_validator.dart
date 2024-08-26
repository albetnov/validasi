import 'package:validasi/src/field_error.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/validator.dart';

class ArrayValidator<V extends Validator, T extends List> extends Validator<T> {
  final V validator;

  ArrayValidator(this.validator);

  @override
  Result<T> parse(dynamic value, {String path = 'field'}) {
    if (value == null || value is! List) {
      throw FieldError(
        name: 'invalidType',
        message: "$path is not type of Array",
        path: path,
      );
    }

    final values = [] as T;

    for (var (i, row) in value.indexed) {
      var result = validator.parse(row, path: "$path.$i");
      values.add(result.value);
    }

    return Result(value: values);
  }

  @override
  Result<T> tryParse(dynamic value, {String path = 'field'}) {
    if (value == null || value is! List) {
      return Result(value: null, errors: [
        FieldError(
          name: 'invalidType',
          message: "$path is not type of Array",
          path: path,
        )
      ]);
    }

    final values = [] as T;
    final List<FieldError> errors = [];

    for (var (i, row) in value.indexed) {
      var result = validator.tryParse(row, path: "$path.$i");
      values.add(result.value);

      if (!result.isValid) {
        errors.addAll(result.errors);
      }
    }

    return Result(value: values, errors: errors);
  }
}
