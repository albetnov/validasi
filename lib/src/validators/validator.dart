import 'dart:async';

import 'package:meta/meta.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validator_rule.dart';

abstract class Validator<T> {
  final Map<String, ValidatorRule<T>> _rules = {};

  @protected
  void addRule({
    required String name,
    required FutureOr<bool> Function(T? value) test,
    required String message,
  }) {
    _rules[name] = ValidatorRule(name: name, test: test, message: message);
  }

  Result<T> parse(T? value, {String path = 'field'}) {
    for (var rule in _rules.values) {
      rule.check(value);

      if (!rule.passed) {
        throw rule.toFieldError(path);
      }
    }

    return Result(value: value);
  }

  Future<Result<T>> parseAsync(T? value, {String path = 'field'}) async {
    for (var rule in _rules.values) {
      await rule.checkAsync(value);

      if (!rule.passed) {
        throw rule.toFieldError(path);
      }
    }

    return Result(value: value);
  }

  Result<T> tryParse(T? value, {String path = 'field'}) {
    final List<FieldError> errors = [];

    for (var rule in _rules.values) {
      rule.check(value);

      if (!rule.passed) {
        errors.add(rule.toFieldError(path));
      }
    }

    return Result(value: value, errors: errors);
  }

  Future<Result<T>> tryParseAsync(T? value, {String path = 'field'}) async {
    final List<FieldError> errors = [];

    for (var rule in _rules.values) {
      await rule.checkAsync(value);

      if (!rule.passed) {
        errors.add(rule.toFieldError(path));
      }
    }

    return Result(value: value, errors: errors);
  }
}
