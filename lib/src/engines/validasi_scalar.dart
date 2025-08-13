import 'package:validasi/src/engines/validasi_engine.dart';
import 'package:validasi/src/rule.dart';
import 'package:validasi/src/validasi_result.dart';
import 'package:validasi/src/validasi_transformation.dart';

class ValidasiScalar<T> extends ValidasiEngine<T> {
  const ValidasiScalar({this.rules, super.preprocess});

  final List<Rule<T>>? rules;

  ValidasiScalar<T> withPreprocess(T Function(dynamic value) preprocess) {
    return ValidasiScalar<T>(
      rules: rules,
      preprocess: ValidasiTransformation<dynamic, T>(preprocess),
    );
  }

  @override
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

    if (rules == null || rules!.isEmpty) {
      return ValidasiResult.success(finalValue);
    }

    for (final rule in rules!) {
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
