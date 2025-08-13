import 'package:meta/meta.dart';
import 'package:validasi/src/validasi_result.dart';
import 'package:validasi/src/validasi_transformation.dart';

abstract class ValidasiEngine<T> {
  const ValidasiEngine({this.preprocess, this.message});

  final ValidasiTransformation<dynamic, T>? preprocess;
  final String? message;

  ValidasiResult<T> validate(dynamic data);

  @protected
  ValidasiResult<T> getValue(dynamic value) {
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

    return ValidasiResult.success(finalValue);
  }
}
