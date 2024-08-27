import 'dart:async';

import 'package:validasi/src/mixins/strict_check.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/validator.dart';

class StringValidator extends Validator<String> with StrictCheck<String> {
  @override
  final bool strict;
  @override
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

  String? _valueToString(dynamic value) =>
      value != null && value is! String ? value.toString() : value;

  @override
  parse(dynamic value, {String path = 'field'}) {
    strictCheck(value, path);

    return super.parse(_valueToString(value), path: path);
  }

  @override
  Future<Result<String>> parseAsync(String? value, {String path = 'field'}) {
    strictCheck(value, path);

    return super.parseAsync(_valueToString(value), path: path);
  }

  @override
  tryParse(dynamic value, {String path = 'field'}) {
    var result = super.tryParse(_valueToString(value), path: path);

    tryStrictCheck(result, value, path);

    return result;
  }

  @override
  Future<Result<String>> tryParseAsync(String? value,
      {String path = 'field'}) async {
    var result = await super.tryParseAsync(_valueToString(value), path: path);

    tryStrictCheck(result, value, path);

    return result;
  }
}
