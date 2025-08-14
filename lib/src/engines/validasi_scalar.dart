import 'package:validasi/src/engines/validasi_engine.dart';
import 'package:validasi/src/rule.dart';
import 'package:validasi/src/validasi_result.dart';

class ValidasiScalar<T> extends ValidasiEngine<T> {
  const ValidasiScalar({this.rules, super.message});

  final List<Rule<T>>? rules;

  @override
  ValidasiResult<T> run(T? value) {
    List<ValidasiError> errors = [];

    if (rules == null || rules!.isEmpty) {
      return ValidasiResult.success(value);
    }

    for (final rule in rules!) {
      final result = rule.validate(value);

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
      data: value,
    );
  }
}
