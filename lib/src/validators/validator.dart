import 'dart:async';

import 'package:meta/meta.dart';
import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/utils/message.dart';
import 'package:validasi/src/validator_rule.dart';

/// The base [Validator] class that every validators must extends from.
/// This class responsible to tracking rules and performing custom callback.
///
/// This class contains [tryParse], [parse], [tryParseAsync], [parseAsync]
/// implementions. Inheritors are free to override or not to
/// override these methods to perform their own validation logic.
///
/// The Validator accepts Generic [T]. This generic used to infer the return
/// type from [parse] and it's variants.
abstract class Validator<T> {
  /// The [_rules] contains all rules required to run
  final List<ValidatorRule<T>> _rules = [];

  /// The [_customCallback] responsible to execute custom in-line or user-defined
  /// class validation logic.
  CustomCallback<T?>? _customCallback;

  /// The [addRule] responsible to append value to [_rules]. This method should
  /// only be used internally by the inheritors, hence the [protected]
  /// attributes.
  @protected
  void addRule({
    required String name,
    required bool Function(T? value) test,
    required String message,
  }) {
    _rules.add(ValidatorRule(name: name, test: test, message: message));
  }

  /// [custom] add custom callback to be executed after all rules executed.
  custom(CustomCallback<T> callback) {
    _customCallback = callback;

    return this;
  }

  /// [customFor] add a Custom Rule based on the instance inheriting [CustomRule].
  ///
  /// Check [CustomRule] for implementation details.
  @mustBeOverridden
  customFor(CustomRule<T> customRule) {
    _customCallback = customRule.handle;

    return this;
  }

  /// This is the custom runner implementation, responsible to run
  /// [_customCallback] in syncronous context. The [runCustom] by default,
  /// are already included in `parse` variants methods. The inheritor should
  /// include this implementation to each of their overriden `parse` variants
  /// if `super` were not used.
  @protected
  void runCustom(T? value, String path) {
    if (_customCallback == null) return;

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

  /// Similar to [runCustom] but run on async context. This function
  /// should be called by the inheritors whose not include `super`.
  @protected
  Future<void> runCustomAsync(T? value, String path) async {
    if (_customCallback == null) return;

    String error = 'Field is not valid';

    var result = await _customCallback!.call(value, (message) {
      error = message;
      return false;
    });

    // not error
    if (result) return;

    throw FieldError(name: 'custom', message: error, path: path);
  }

  /// This is the base parse implementation.
  /// This function will run through all [_rules] and throw
  /// [FieldError] if any errors encountered thoughout the [_rules].
  void _parseImpl(T? value, String path) {
    for (var rule in _rules) {
      rule.check(value);

      if (!rule.passed) {
        throw rule.toFieldError(path);
      }
    }
  }

  /// [parse] run the validation
  ///
  /// throw [FieldError] if any error encountered and stop execution afterwards.
  Result<T> parse(T? value, {String path = 'field'}) {
    _parseImpl(value, path);
    runCustom(value, path);

    return Result(value: value);
  }

  /// [parseAsync] run validation with asyncronous context
  ///
  /// throw [FieldError] if any error encountered and stop execution afterwards.
  Future<Result<T>> parseAsync(T? value, {String path = 'field'}) async {
    _parseImpl(value, path);

    await runCustomAsync(value, path);

    return Result(value: value);
  }

  /// [_tryParseImpl] is a rules runner similar to [parse] but instead of
  /// throwing an error, each errors from [_rules] will be captured and
  /// appended to array and then returned as [List<FieldError>].
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

  /// [tryParse] run validation without throwing any errors.
  /// All the recorded errors will be contained in the [Result] itself.
  Result<T> tryParse(T? value, {String path = 'field'}) {
    var errors = _tryParseImpl(value, path);

    try {
      runCustom(value, path);
    } on FieldError catch (e) {
      errors.add(e);
    }

    return Result(value: value, errors: errors);
  }

  /// [tryParseAsync] run validation without throwing any errors on
  /// asyncronous context.
  ///
  /// All the recorded errors will be contained in the [Result] itself.
  Future<Result<T>> tryParseAsync(T? value, {String path = 'field'}) async {
    var errors = _tryParseImpl(value, path);

    try {
      await runCustomAsync(value, path);
    } on FieldError catch (e) {
      errors.add(e);
    }

    return Result(value: value, errors: errors);
  }
}
