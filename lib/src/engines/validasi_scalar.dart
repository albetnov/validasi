import 'package:validasi/src/engines/validasi_engine.dart';
import 'package:validasi/src/rule.dart';
import 'package:validasi/src/validasi_result.dart';
import 'package:validasi/src/validasi_transformation.dart';

class ValidasiScalar<T> extends ValidasiEngine<T> {
  const ValidasiScalar({this.rules, super.preprocess, super.message});

  final List<Rule<T>>? rules;

  ValidasiScalar<T> withPreprocess(T Function(dynamic value) preprocess) {
    return ValidasiScalar<T>(
      rules: rules,
      preprocess: ValidasiTransformation<dynamic, T>(
        preprocess,
        message: message,
      ),
    );
  }

  @override
  ValidasiResult<T> validate(dynamic data) {
    final transformedValue = getValue(data);
    if (!transformedValue.isValid) {
      return transformedValue;
    }

    final finalValue = transformedValue.data;

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
          details: result.details,
        ));
      }
    }

    return ValidasiResult<T>(
      errors: errors,
      isValid: errors.isEmpty,
      data: finalValue,
    );
  }
}
