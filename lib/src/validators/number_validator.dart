import 'package:validasi/src/mixins/strict_check.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/validator.dart';

class NumberValidator extends Validator<num> with StrictCheck<num> {
  @override
  final bool strict;
  @override
  final String? message;

  NumberValidator({this.strict = true, this.message});

  NumberValidator required({String? message}) {
    addRule(
      name: 'required',
      test: (value) => value != null,
      message: message ?? ':name is required',
    );

    return this;
  }

  num? _valueToNum(dynamic value) =>
      value is! num && value != null ? num.parse(value) : value;

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
  Future<Result<num>> parseAsync(num? value, {String path = 'field'}) {
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
