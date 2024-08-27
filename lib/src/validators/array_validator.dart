import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/utils/message.dart';
import 'package:validasi/src/validators/validator.dart';

class ArrayValidator<V extends Validator, T extends List> extends Validator<T> {
  final V validator;
  final String? message;

  ArrayValidator(this.validator, {this.message});

  _typeCheck(dynamic value, String path) {
    if (value == null || value is! List) {
      throw FieldError(
        name: 'invalidType',
        message: Message(path, "$path is not type of Array", message).message,
        path: path,
      );
    }
  }

  Result<T>? _tryTypeCheck(dynamic value, String path) {
    try {
      _typeCheck(value, path);
      return null;
    } on FieldError catch (e) {
      return Result(value: null, errors: [e]);
    }
  }

  @override
  Result<T> parse(dynamic value, {String path = 'field'}) {
    _typeCheck(value, path);

    final values = [] as T;

    for (var (i, row) in value.indexed) {
      var result = validator.parse(row, path: "$path.$i");
      values.add(result.value);
    }

    return Result(value: values);
  }

  @override
  Future<Result<T>> parseAsync(dynamic value, {String path = 'field'}) async {
    _typeCheck(value, path);

    final values = [] as T;

    for (var (i, row) in value.indexed) {
      var result = await validator.parseAsync(row, path: "$path.$i");
      values.add(result.value);
    }

    return Result(value: values);
  }

  @override
  Result<T> tryParse(dynamic value, {String path = 'field'}) {
    var check = _tryTypeCheck(value, path);

    if (check != null) {
      return check;
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

  @override
  Future<Result<T>> tryParseAsync(dynamic value,
      {String path = 'field'}) async {
    var check = _tryTypeCheck(value, path);

    if (check != null) {
      return check;
    }

    final values = [] as T;
    final List<FieldError> errors = [];

    for (var (i, row) in value.indexed) {
      var result = await validator.tryParseAsync(row, path: "$path.$i");
      values.add(result.value);

      if (!result.isValid) {
        errors.addAll(result.errors);
      }
    }

    return Result(value: values, errors: errors);
  }
}
