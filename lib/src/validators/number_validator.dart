import 'package:validasi/src/mixins/strict_check.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/validator.dart';

/// Responsible for validating [num] for both [double] and [int] also
/// support type conversion from [String] based on [num.tryParse].
class NumberValidator extends Validator<num> with StrictCheck<num> {
  @override
  final bool strict;
  @override
  final String? message;

  NumberValidator({this.strict = true, this.message});

  /// [required] indicate that the [value] cannot be `null`
  NumberValidator required({String? message}) {
    addRule(
      name: 'required',
      test: (value) => value != null,
      message: message ?? ':name is required',
    );

    return this;
  }

  @override
  NumberValidator custom(callback) => super.custom(callback);

  @override
  NumberValidator customFor(customRule) => super.customFor(customRule);

  num? _valueToNum(dynamic value) {
    if (value is String) {
      return num.tryParse(value);
    }

    if (value is num || value == null) {
      return value;
    }

    return null;
  }

  @override
  Result<num> parse(dynamic value, {String path = 'field'}) {
    strictCheck(value, path, type: 'number');

    return super.parse(_valueToNum(value), path: path);
  }

  @override
  Result<num> tryParse(dynamic value, {String path = 'field'}) {
    var result = super.tryParse(_valueToNum(value), path: path);

    tryStrictCheck(result, value, path, type: 'number');

    return result;
  }

  @override
  Future<Result<num>> parseAsync(dynamic value, {String path = 'field'}) {
    strictCheck(value, path, type: 'number');

    return super.parseAsync(value, path: path);
  }

  @override
  Future<Result<num>> tryParseAsync(dynamic value,
      {String path = 'field'}) async {
    var result = await super.tryParseAsync(_valueToNum(value), path: path);

    tryStrictCheck(result, value, path, type: 'number');

    return result;
  }
}
