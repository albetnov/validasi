import 'package:validasi/src/validasi_result.dart';
import 'package:validasi/src/transformer/validasi_transformation.dart';

abstract class ValidasiEngine<T> {
  const ValidasiEngine({this.message});

  final String? message;

  ValidasiResult<T> run(T? value);

  ValidasiResult<T> validate<TValue>(
    TValue value, {
    TransformFn<TValue, T>? transform,
  }) {
    T? finalValue;
    bool processed = false;

    if (value is T?) {
      finalValue = value;
      processed = true;
    }

    if (transform != null) {
      final result =
          ValidasiTransformation<TValue, T>(transform).tryTransform(value);
      processed = result.isValid;

      if (!processed) {
        return ValidasiResult.error(
          ValidasiError(
            rule: 'Preprocess',
            message: result.message!,
            details: {
              'exception': result.error?.toString() ?? 'Unknown error',
            },
          ),
        );
      }

      finalValue = result.data;
    }

    if (!processed) {
      return ValidasiResult.error(
        ValidasiError(
          rule: 'TypeCheck',
          message: message ??
              'Expected type ${T.toString()}, got ${value.runtimeType}',
        ),
      );
    }

    return run(finalValue);
  }
}
