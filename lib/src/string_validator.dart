import 'package:validasi/src/field_error.dart';
import 'package:validasi/src/validator.dart';

class StringValidator extends Validator<String> {
  final bool strict;

  StringValidator({this.strict = true});

  StringValidator required({String? message}) {
    addRule(
      name: 'required',
      test: (text) => text != null && text.trim() != '' && text.isNotEmpty,
      message: message ?? ":name is required",
    );

    return this;
  }

  StringValidator minLength(int length, {String? message}) {
    addRule(
      name: 'minLength',
      test: (text) {
        if (text == null) return false;

        return text.length >= length;
      },
      message: message ?? ":name must be at least contains $length characters",
    );

    return this;
  }

  StringValidator maxLength(int length, {String? message}) {
    addRule(
      name: 'maxLength',
      test: (text) {
        if (text == null) return false;

        return text.length <= length;
      },
      message: message ?? ":name must not be longer than $length characters",
    );

    return this;
  }

  @override
  parse(dynamic value, {String path = 'field'}) {
    if (strict && value is! String) {
      throw FieldError(
        path: path,
        name: 'invalidType',
        message: "$path is not a valid string",
      );
    }

    return super.parse(value != null ? value.toString() : value, path: path);
  }

  @override
  tryParse(dynamic value, {String path = 'field'}) {
    var result =
        super.tryParse(value != null ? value.toString() : value, path: path);

    if (strict && value is! String && value != null) {
      result.addError(FieldError(
        path: path,
        name: 'invalidType',
        message: "$path is not a valid string",
      ));
    }

    return result;
  }
}
