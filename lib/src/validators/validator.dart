import 'dart:async';

import 'package:meta/meta.dart';
import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/utils/message.dart';
import 'package:validasi/src/validator_rule.dart';

abstract class Validator<T> {
  final List<ValidatorRule<T>> _rules = [];
  CustomCallback<T?>? _customCallback;

  @protected
  void addRule({
    required String name,
    required bool Function(T? value) test,
    required String message,
  }) {
    _rules.add(ValidatorRule(name: name, test: test, message: message));
  }

  @mustBeOverridden
  custom(CustomCallback<T> callback) {
    _customCallback = callback;

    return this;
  }

  @mustBeOverridden
  customFor(CustomRule<T> customRule) {
    _customCallback = customRule.handle;

    return this;
  }

  void _runCustom(T? value, String path) {
    if (_customCallback == null) return null;

    String? error;

    var result = _customCallback!.call(value, (message) {
      error = message;
      return false;
    });

    if (result is Future) {
      throw ValidasiException(
          'The custom function require async context, please use `async` equivalent for parse.');
    }

    // not error
    if (result) return;

    throw FieldError(
      name: 'custom',
      message:
          Message(path, fallback: ':name is not valid', message: error).parse,
      path: path,
    );
  }

  Future<void> _runCustomAsync(T? value, String path) async {
    if (_customCallback == null) return null;

    String error = 'Field is not valid';

    var result = await _customCallback!.call(value, (message) {
      error = message;
      return false;
    });

    // not error
    if (result) return;

    throw FieldError(name: 'custom', message: error, path: path);
  }

  void _parseImpl(T? value, String path) {
    for (var rule in _rules) {
      rule.check(value);

      if (!rule.passed) {
        throw rule.toFieldError(path);
      }
    }
  }

  Result<T> parse(T? value, {String path = 'field'}) {
    _parseImpl(value, path);
    _runCustom(value, path);

    return Result(value: value);
  }

  Future<Result<T>> parseAsync(T? value, {String path = 'field'}) async {
    _parseImpl(value, path);

    await _runCustomAsync(value, path);

    return Result(value: value);
  }

  List<FieldError> _tryParseImpl(T? value, String path) {
    final List<FieldError> errors = [];

    for (var rule in _rules) {
      rule.check(value);

      if (!rule.passed) {
        errors.add(rule.toFieldError(path));
      }
    }

    return errors;
  }

  Result<T> tryParse(T? value, {String path = 'field'}) {
    var errors = _tryParseImpl(value, path);

    try {
      _runCustom(value, path);
    } on FieldError catch (e) {
      errors.add(e);
    }

    return Result(value: value, errors: errors);
  }

  Future<Result<T>> tryParseAsync(T? value, {String path = 'field'}) async {
    var errors = _tryParseImpl(value, path);

    try {
      await _runCustomAsync(value, path);
    } on FieldError catch (e) {
      errors.add(e);
    }

    return Result(value: value, errors: errors);
  }
}
