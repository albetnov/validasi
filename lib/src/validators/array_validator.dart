import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/utils/message.dart';
import 'package:validasi/src/validators/validator.dart';

/// Responsible for validating arrays based on [validator].
class ArrayValidator<V extends Validator, T extends dynamic>
    extends Validator<List<T>> {
  final V validator;
  final String? message;

  ArrayValidator(this.validator, {this.message});

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

  _typeCheck(dynamic value, String path) {
    if (value != null && value is! List) {
      throw FieldError(
        name: 'invalidType',
        message:
            Message(path, fallback: ":name must be an array", message: message)
                .parse,
        path: path,
      );
    }
  }

  Result<List<T>>? _tryTypeCheck(dynamic value, String path) {
    try {
      _typeCheck(value, path);
      return null;
    } on FieldError catch (e) {
      return Result(value: null, errors: [e]);
    }
  }

  @override
  Result<List<T>> parse(dynamic value, {String path = 'field'}) {
    _typeCheck(value, path);

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
    _typeCheck(value, path);

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
    var typeCheck = _tryTypeCheck(value, path);
    if (typeCheck != null) {
      return typeCheck;
    }

    var result = super.tryParse(value, path: path);

    if (result.value == null) {
      return result;
    }

    final List<T> values = [];

    for (var (i, row) in result.value!.indexed) {
      var result = validator.tryParse(row, path: "$path.$i");
      values.add(result.value);

      if (!result.isValid) {
        result.errors.addAll(result.errors);
      }
    }

    return Result(value: values, errors: result.errors);
  }

  @override
  Future<Result<List<T>>> tryParseAsync(dynamic value,
      {String path = 'field'}) async {
    var typeCheck = _tryTypeCheck(value, path);
    if (typeCheck != null) {
      return typeCheck;
    }

    var result = await super.tryParseAsync(value, path: path);

    if (result.value == null) {
      return result;
    }

    final List<T> values = [];

    for (var (i, row) in result.value!.indexed) {
      var result = await validator.tryParseAsync(row, path: "$path.$i");
      values.add(result.value);

      if (!result.isValid) {
        result.errors.addAll(result.errors);
      }
    }

    return Result(value: values, errors: result.errors);
  }
}
