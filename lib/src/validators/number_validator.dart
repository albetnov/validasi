import 'package:validasi/src/field_error.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/validator.dart';

class NumberValidator extends Validator<num> {
  final bool strict;

  NumberValidator({this.strict = true});

  NumberValidator required() {
    addRule(
      name: 'required',
      test: (value) => value != null,
      message: ':name is required',
    );

    return this;
  }

  @override
  Result<num> parse(dynamic value, {String path = 'field'}) {
    if (strict && value is! num && value != null) {
      throw FieldError(
        name: 'invalidType',
        message: "$path is not a valid number",
        path: path,
      );
    }

    return super.parse(
      value is! num && value != null ? num.parse(value) : value,
      path: path,
    );
  }

  @override
  Result<num> tryParse(dynamic value, {String path = 'field'}) {
    var result = super.tryParse(
        value != num && value != null ? num.tryParse(value) : value,
        path: path);

    if (strict && value is! num && value != null) {
      result.addError(FieldError(
        name: 'invalidType',
        message: "$path is not a valid number",
        path: path,
      ));
    }

    return result;
  }
}
