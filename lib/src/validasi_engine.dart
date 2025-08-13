import 'package:validasi/src/rule.dart';
import 'package:validasi/src/validasi_result.dart';
import 'package:validasi/src/validasi_transformation.dart';

class ValidasiEngine<T> {
  const ValidasiEngine._(this.rules, this.preprocess);

  factory ValidasiEngine.withRules(List<Rule<T>> rules) =>
      ValidasiEngine<T>._(rules, null);

  final List<Rule<T>> rules;
  final ValidasiTransformation<dynamic, T>? preprocess;

  ValidasiEngine<T> withPreprocess(T Function(dynamic value) preprocess) {
    return ValidasiEngine<T>._(
        rules, ValidasiTransformation<dynamic, T>(preprocess));
  }

  ValidasiResult<T> validate(dynamic value) {
    T? finalValue;
    bool processed = false;

    if (value is T?) {
      finalValue = value;
      processed = true;
    }

    if (preprocess != null) {
      final result = preprocess!.tryTransform(value);
      processed = result.isValid;

      if (!processed) {
        return ValidasiResult.error(
          error: ValidasiError(
            rule: 'Preprocess',
            message: 'Failed to preprocess value',
            details: {
              'exception': result.error?.toString() ?? 'Unknown error',
            },
          ),
        );
      }

      finalValue = result.data;
    }

    if (!processed) {
      return ValidasiResult(
        errors: [
          ValidasiError(
            rule: 'TypeCheck',
            message: 'Expected type ${T.toString()}, got ${value.runtimeType}',
          )
        ],
        isValid: false,
      );
    }

    List<ValidasiError> errors = [];

    for (final rule in rules) {
      final result = rule.validate(finalValue);

      if (result.isStop) {
        break;
      }

      if (!result.isValid) {
        errors.add(ValidasiError(
            rule: rule.name,
            message: result.message!,
            details: result.details));
      }
    }

    return ValidasiResult<T>(
        errors: errors, isValid: errors.isEmpty, data: finalValue);
  }
}
