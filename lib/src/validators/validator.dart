import 'dart:async';

import 'package:meta/meta.dart';
import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/transformers/transformer.dart';
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
abstract class Validator<T, R extends Validator<T, R>> {
  /// The [rules] contains all rules required to run
  @visibleForTesting
  @internal
  final List<ValidatorRule<T>> rules = [];

  /// The [customCallback] responsible to execute custom in-line or user-defined
  /// class validation logic.
  @visibleForTesting
  @internal
  CustomCallback<T?>? customCallback;

  bool _isOptional = false;

  Transformer<T>? transformer;

  Validator({this.transformer, String? message});

  /// The [addRule] responsible to append value to [rules]. This method should
  /// only be used internally by the inheritors, hence the [protected]
  /// attributes.
  @protected
  void addRule({
    required String name,
    required bool Function(T value) test,
    required String message,
  }) {
    rules.add(ValidatorRule(name: name, test: test, message: message));
  }

  /// Mark the field as optional. If the field is empty, then the rules
  /// will not be executed.
  R optional() {
    _isOptional = true;

    return this as R;
  }

  /// [custom] add custom callback to be executed after all rules executed.
  @mustCallSuper
  R custom(CustomCallback<T> callback) {
    customCallback = callback;

    return this as R;
  }

  /// [customFor] add a Custom Rule based on the instance inheriting [CustomRule].
  ///
  /// Check [CustomRule] for implementation details.
  @mustCallSuper
  R customFor(CustomRule<T> customRule) {
    customCallback = customRule.handle;

    return this as R;
  }

  /// This is the custom runner implementation, responsible to run
  /// [customCallback] in syncronous context. The [runCustom] by default,
  /// are already included in `parse` variants methods. The inheritor should
  /// include this implementation to each of their overriden `parse` variants
  /// if `super` were not used.
  @protected
  void runCustom(T? value, String path) {
    if (customCallback == null) return;

    String? error;

    var result = customCallback!(value, (message) {
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
    if (customCallback == null) return;

    String? error;

    var result = await customCallback!.call(value, (message) {
      error = message;
      return false;
    });

    // not error
    if (result) return;

    throw FieldError(
        name: 'custom',
        message:
            Message(path, fallback: ':name is not valid', message: error).parse,
        path: path);
  }

  /// This is the base parse implementation.
  /// This function will run through all [rules] and throw
  /// [FieldError] if any errors encountered thoughout the [rules].
  void _parseImpl(T? value, String path) {
    /// If [_isOptional] is `true`, then no reason to run the rules since
    /// we have nothing to test against.
    if (_isOptional && value == null) return;

    for (var rule in rules) {
      _required(path, value);

      // ignore: null_check_on_nullable_type_parameter
      rule.check(value!);

      if (!rule.passed) {
        throw rule.toFieldError(path);
      }
    }
  }

  /// [_typeCheck] is a helper function to check the type of the value.
  /// If the value is not the expected type, it will throw [FieldError].
  ///
  /// If the [transformer] is set, it will transform the value and return
  /// the transformed value.
  T? _typeCheck(dynamic value, String path) {
    if (value != null && value is! T) {
      String fallbackMessage =
          "Expected type ${T.toString()}. Got ${value.runtimeType} instead.";
      if (transformer != null) {
        return transformer!.transform(
            value,
            (message) => throw FieldError(
                name: 'invalidType',
                message:
                    Message(path, message: message, fallback: message).parse,
                path: path));
      }

      throw FieldError(
          name: 'invalidType', message: fallbackMessage, path: path);
    }

    return value;
  }

  void _required(String path, T? value) {
    if (value == null) {
      throw FieldError(
        name: 'required',
        message: Message(path, fallback: ':name is required').parse,
        path: path,
      );
    }
  }

  /// [parse] run the validation
  ///
  /// throw [FieldError] if any error encountered and stop execution afterwards.
  /// throw [ValidasiException] if the custom rule requires async context
  @mustCallSuper
  Result<T> parse(dynamic value, {String path = 'field'}) {
    T? finalValue = _typeCheck(value, path);

    _parseImpl(finalValue, path);
    runCustom(finalValue, path);

    return Result(value: finalValue);
  }

  /// [parseAsync] run validation with asyncronous context
  ///
  /// throw [FieldError] if any error encountered and stop execution afterwards.
  @mustCallSuper
  Future<Result<T>> parseAsync(dynamic value, {String path = 'field'}) async {
    T? finalValue = _typeCheck(value, path);

    _parseImpl(finalValue, path);
    await runCustomAsync(finalValue, path);

    return Result(value: finalValue);
  }

  /// [_tryParseImpl] is a rules runner similar to [parse] but instead of
  /// throwing an error, each errors from [rules] will be captured and
  /// appended to array and then returned as [List<FieldError>].
  List<FieldError> _tryParseImpl(T? value, String path) {
    final List<FieldError> errors = [];

    /// If [_isOptional] is `true`, then no reason to run the rules since
    /// we have nothing to test against.
    if (_isOptional && value == null) return errors;

    for (var rule in rules) {
      try {
        _required(path, value);
      } on FieldError catch (e) {
        errors.add(e);

        // stop execution if the field is required
        break;
      }

      // ignore: null_check_on_nullable_type_parameter
      rule.check(value!);

      if (!rule.passed) {
        errors.add(rule.toFieldError(path));
      }
    }

    return errors;
  }

  /// Run validation without throwing any [FieldError] based errors.
  ///
  /// throw [ValidasiException] if your custom rule requires
  /// async context.
  ///
  /// All the recorded errors will be contained in the [Result] itself.
  @mustCallSuper
  Result<T> tryParse(dynamic value, {String path = 'field'}) {
    List<FieldError> errors = [];
    T? finalValue;

    try {
      finalValue = _typeCheck(value, path);
    } on FieldError catch (e) {
      errors.add(e);
    }

    errors.addAll(_tryParseImpl(finalValue, path));

    try {
      runCustom(finalValue, path);
    } on FieldError catch (e) {
      errors.add(e);
    }

    return Result(value: finalValue, errors: errors);
  }

  /// [tryParseAsync] run validation without throwing any errors on
  /// asyncronous context.
  ///
  /// All the recorded errors will be contained in the [Result] itself.
  @mustCallSuper
  Future<Result<T>> tryParseAsync(dynamic value,
      {String path = 'field'}) async {
    List<FieldError> errors = [];
    T? finalValue;

    try {
      finalValue = _typeCheck(value, path);
    } on FieldError catch (e) {
      errors.add(e);
    }

    errors.addAll(_tryParseImpl(finalValue, path));

    try {
      await runCustomAsync(finalValue, path);
    } on FieldError catch (e) {
      errors.add(e);
    }

    return Result(value: finalValue, errors: errors);
  }
}
