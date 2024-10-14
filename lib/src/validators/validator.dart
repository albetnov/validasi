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
abstract class Validator<T> {
  /// The [rules] contains all rules required to run
  @visibleForTesting
  @internal
  final Map<String, ValidatorRule<T>> rules = {};

  /// The [customCallback] responsible to execute custom in-line or user-defined
  /// class validation logic.
  @visibleForTesting
  @internal
  CustomCallback<T?>? customCallback;

  /// The [_isOptional] flag to mark the field as nullable.
  /// If the field is `null`, then the rules will not be executed.
  bool _isOptional = false;

  /// The [transformer] responsible to transform the value to the desired type.
  /// If the value is not the expected type, the transformer will be used.
  /// If no transformer provided, the validator will throw [FieldError].
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
    rules[name] = ValidatorRule(name: name, test: test, message: message);
  }

  /// Mark the field as nullable. If the field is `null`, then the rules
  /// will not be executed, resulting in the validation passes when null
  /// provided.
  @mustCallSuper
  @mustBeOverridden
  nullable() {
    _isOptional = true;

    return this;
  }

  /// [custom] add custom callback to be executed after all rules executed.
  @mustCallSuper
  @mustBeOverridden
  custom(CustomCallback<T> callback) {
    customCallback = callback;

    return this;
  }

  /// [customFor] add a Custom Rule based on the instance inheriting [CustomRule].
  ///
  /// Check [CustomRule] for implementation details.
  @mustCallSuper
  @mustBeOverridden
  customFor(CustomRule<T> customRule) {
    customCallback = customRule.handle;

    return this;
  }

  /// This is the custom runner implementation, responsible to run
  /// [customCallback] in syncronous context. The [runCustom] by default,
  /// are already included in `parse` variants methods.
  ///
  /// If the custom rule requires async context, it will throw [ValidasiException].
  /// IF the custom rule return `false`, it will throw [FieldError].
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

  /// This is the custom runner implementation, responsible to run asyncronous
  /// [customCallback].
  ///
  /// If the custom rule return `false`, it will throw [FieldError].
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

  FieldError? _required(String path, T? value) {
    if (value == null) {
      return FieldError(
        name: 'required',
        message: Message(path, message: ':name is required').parse,
        path: path,
      );
    }

    return null;
  }

  /// the base runner for all parse. Each errors from [rules] will be captured
  /// and appended to array and then returned as [List<FieldError>].
  List<FieldError> _parseImpl(T? value, String path) {
    final List<FieldError> errors = [];

    /// If [_isOptional] is `true`, then no reason to run the rules since
    /// we have nothing to test against.
    if (_isOptional && value == null) return errors;

    var requiredErr = _required(path, value);

    if (requiredErr != null) {
      return errors..add(requiredErr);
    }

    for (var rule in rules.values) {
      // ignore: null_check_on_nullable_type_parameter
      rule.check(value!);

      if (!rule.passed) {
        errors.add(rule.toFieldError(path));
      }
    }

    return errors;
  }

  /// [_typeCheck] is a helper function to check the type of the value.
  /// If the value is not the expected type, it will throw [FieldError].
  ///
  /// If the [transformer] is set, it will transform the value and return
  /// the transformed value.
  T? _typeCheck(dynamic value, String path) {
    if (value is T?) return value;

    if (transformer != null) {
      return transformer!.transform(
          value,
          (message) => throw FieldError(
              name: 'invalidType',
              message: Message(path, message: message).parse,
              path: path));
    }

    throw FieldError(
        name: 'invalidType',
        message:
            "Expected type ${T.toString()}. Got ${value.runtimeType} instead.",
        path: path);
  }

  /// Run validation without throwing any [FieldError] based errors.
  ///
  /// throw [ValidasiException] if your custom rule requires
  /// async context.
  ///
  /// All the recorded errors will be contained in the [Result] itself.
  @mustCallSuper
  Result<T> tryParse(dynamic value, {String path = 'field'}) {
    try {
      T? finalValue = _typeCheck(value, path);

      var err = _parseImpl(finalValue, path);

      try {
        runCustom(finalValue, path);
      } on FieldError catch (e) {
        err.add(e);
      }

      return Result(value: finalValue, errors: err);
    } on FieldError catch (e) {
      return Result(value: null, errors: [e]);
    }
  }

  /// [tryParseAsync] run validation without throwing any errors on
  /// asyncronous context.
  ///
  /// All the recorded errors will be contained in the [Result] itself.
  @mustCallSuper
  Future<Result<T>> tryParseAsync(dynamic value,
      {String path = 'field'}) async {
    try {
      T? finalValue = _typeCheck(value, path);

      var errors = _parseImpl(finalValue, path);

      try {
        await runCustomAsync(finalValue, path);
      } on FieldError catch (e) {
        errors.add(e);
      }

      return Result(value: finalValue, errors: errors);
    } on FieldError catch (e) {
      return Result(value: null, errors: [e]);
    }
  }

  /// [_getResultOrThrow] is a helper function to get the result from [tryParse]
  /// and [tryParseAsync] and throw the first error if any.
  Result<T> _getResultOrThrow(Result<T> result) {
    var err = result.errors.firstOrNull;

    if (err != null) {
      throw err;
    }

    return result;
  }

  /// [parse] run the validation
  ///
  /// throw [FieldError] if any error encountered.
  /// throw [ValidasiException] if the custom rule requires async context
  @mustCallSuper
  Result<T> parse(dynamic value, {String path = 'field'}) =>
      _getResultOrThrow(tryParse(value, path: path));

  /// [parseAsync] run validation with asyncronous context
  ///
  /// throw [FieldError] if any error encountered.
  @mustCallSuper
  Future<Result<T>> parseAsync(dynamic value, {String path = 'field'}) async =>
      _getResultOrThrow(await tryParseAsync(value, path: path));
}
