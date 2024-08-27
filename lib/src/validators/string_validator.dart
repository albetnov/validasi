import 'dart:async';

import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/utils/message.dart';
import 'package:validasi/src/validators/validator.dart';

class StringValidator extends Validator<String> {
  final bool strict;
  final String? message;

  StringValidator({this.strict = true, this.message});

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

  StringValidator custom(
      FutureOr<bool> Function(String?) callback, String message) {
    addRule(name: 'custom', test: callback, message: message);

    return this;
  }

  String _valueToString(dynamic value) =>
      value != null && value is! String ? value.toString() : value;

  void _strictCheck(dynamic value, String path) {
    if (strict && value is! String && value != null) {
      throw FieldError(
        path: path,
        name: 'invalidType',
        message: Message(path, "$path is not a valid string", message).message,
      );
    }
  }

  @override
  parse(dynamic value, {String path = 'field'}) {
    _strictCheck(value, path);

    return super.parse(_valueToString(value), path: path);
  }

  @override
  Future<Result<String>> parseAsync(String? value, {String path = 'field'}) {
    _strictCheck(value, path);

    return super.parseAsync(_valueToString(value), path: path);
  }

  void _tryStrictCheck(Result result, dynamic value, String path) {
    try {
      _strictCheck(value, path);
    } on FieldError catch (e) {
      result.addError(e);
    }
  }

  @override
  tryParse(dynamic value, {String path = 'field'}) {
    var result = super.tryParse(_valueToString(value), path: path);

    _tryStrictCheck(result, value, path);

    return result;
  }

  @override
  Future<Result<String>> tryParseAsync(String? value,
      {String path = 'field'}) async {
    var result = await super.tryParseAsync(_valueToString(value), path: path);

    _tryStrictCheck(result, value, path);

    return result;
  }
}
