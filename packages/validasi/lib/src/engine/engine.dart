import 'package:meta/meta.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/result.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/transformer/validasi_transformation.dart';

class ValidasiEngine<T, TInput> {
  const ValidasiEngine({this.rules, this.preprocess});

  final List<Rule<T>>? rules;
  final ValidasiTransformation<dynamic, T>? preprocess;

  ValidasiEngine<T, TNextInput> withPreprocess<TNextInput>(
      ValidasiTransformation<TNextInput, T> preprocess) {
    final wrappedPreprocess = ValidasiTransformation<dynamic, T>(
      (input) => preprocess.transform(input as TNextInput),
      message: preprocess.message,
    );

    return ValidasiEngine<T, TNextInput>(
      rules: rules,
      preprocess: wrappedPreprocess,
    );
  }

  @internal
  @pragma('vm:prefer-inline')
  T? execute(dynamic rawValue, ValidationState state) {
    Object? processedValue = rawValue;

    if (preprocess != null) {
      final result = preprocess!.tryTransform(processedValue);
      if (!result.isValid) {
        state.addError(ValidationError(
          rule: 'Preprocess',
          message: 'Failed to preprocess value',
          details: {
            'exception': result.error?.toString() ?? 'Unknown error',
          },
        ));
        return null;
      }

      processedValue = result.data;
    }

    if (processedValue is! T?) {
      state.addError(ValidationError(
        rule: 'TypeCheck',
        message: 'Expected type $T, got ${processedValue.runtimeType}',
        details: {'value': processedValue},
      ));
      return null;
    }

    var value = processedValue;

    value = applyRules(value, rules, state);

    return value;
  }

  ValidasiResult<T> validate(TInput? value) {
    final state = ValidationState();
    final finalValue = execute(value, state);
    return ValidasiResult<T>(
      isValid: state.isValid,
      data: finalValue,
      errors: state.errors,
    );
  }

}
