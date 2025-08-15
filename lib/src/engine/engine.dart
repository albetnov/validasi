import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/result.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/transformer/validasi_transformation.dart';

class ValidasiEngine<T> {
  const ValidasiEngine({this.rules, this.preprocess});

  final List<Rule<T>>? rules;
  final ValidasiTransformation<dynamic, T>? preprocess;

  ValidasiEngine<T> withPreprocess(
      ValidasiTransformation<dynamic, T> preprocess) {
    return ValidasiEngine<T>(
      rules: rules,
      preprocess: preprocess,
    );
  }

  ValidasiResult<T> validate(dynamic value) {
    if (preprocess != null) {
      final result = preprocess!.tryTransform(value);
      if (!result.isValid) {
        return ValidasiResult.error(
          ValidationError(
            rule: 'Preprocess',
            message: 'Failed to preprocess value',
            details: {
              'exception': result.error?.toString() ?? 'Unknown error',
            },
          ),
        );
      }

      value = result.data;
    }

    if (value is! T) {
      return ValidasiResult.error(ValidationError(
        rule: 'TypeCheck',
        message: 'Expected type $T, got ${value.runtimeType}',
        details: {'value': value},
      ));
    }

    final context = ValidationContext(value: value);

    for (final rule in rules ?? []) {
      rule.apply(context);

      if (context.isStopped) {
        break;
      }
    }

    return ValidasiResult(
      isValid: context.errors.isEmpty,
      data: context.value,
      errors: context.errors
          .map(
            (error) => ValidationError(
              rule: error.rule,
              message: error.message,
              details: error.details,
            ),
          )
          .toList(),
    );
  }
}
