import 'package:validasi/src/validasi_transformation.dart';

class ValidasiResult<T> {
  const ValidasiResult({
    required this.errors,
    required this.isValid,
    this.data,
  });

  final List<ValidasiError> errors;
  final bool isValid;
  final T? data;

  factory ValidasiResult.error(ValidasiError error) {
    return ValidasiResult(
      errors: [error],
      isValid: false,
    );
  }

  factory ValidasiResult.success(T? data) {
    return ValidasiResult(
      errors: [],
      isValid: true,
      data: data,
    );
  }

  ValidasiResult<R> transform<R>(R Function(T? value) f) {
    if (!isValid) {
      return ValidasiResult(errors: errors, isValid: false);
    }

    final result = ValidasiTransformation(f).tryTransform(data);
    if (!result.isValid) {
      return ValidasiResult.error(
        ValidasiError(
          rule: 'Transformation',
          message: 'Failed to transform value',
          details: {
            'exception': result.error?.toString() ?? 'Unknown error',
          },
        ),
      );
    }

    return ValidasiResult(errors: errors, isValid: isValid, data: f(data));
  }

  T? requireValue() {
    if (!isValid) {
      throw StateError('Cannot require value from invalid result');
    }

    return data;
  }
}

class ValidasiError {
  const ValidasiError({
    required this.rule,
    required this.message,
    this.path = const [],
    this.details,
  });

  final String rule;
  final String message;
  final Map<String, String>? details;
  final List<int> path;
}
