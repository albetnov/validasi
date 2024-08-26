import 'package:meta/meta.dart';
import 'package:validasi/src/field_error.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validator_rule.dart';

abstract class Validator<T> {
  final List<ValidatorRule<T>> _rules = [];

  @protected
  void addRule({
    required String name,
    required bool Function(T? value) test,
    required String message,
  }) {
    _rules.add(ValidatorRule(name: name, test: test, message: message));
  }

  Result<T> parse(T? value, {String path = 'field'}) {
    for (var rule in _rules) {
      rule.check(value);

      if (!rule.passed) {
        throw rule.toFieldError(path);
      }
    }

    return Result(value: value);
  }

  Result<T> tryParse(T? value, {String path = 'field'}) {
    final List<FieldError> errors = [];

    for (var rule in _rules) {
      rule.check(value);

      if (!rule.passed) {
        errors.add(rule.toFieldError(path));
      }
    }

    return Result(value: value, errors: errors);
  }
}
