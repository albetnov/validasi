import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/transformer/validasi_transformation.dart';

class ValidasiResult<T> {
  const ValidasiResult({
    required this.errors,
    required this.isValid,
    this.data,
  });

  final List<ValidationError> errors;
  final bool isValid;
  final T? data;

  factory ValidasiResult.error(ValidationError error) {
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
        ValidationError(
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

  Map<String, Object?> toToolResponse() {
    return <String, Object?>{
      'isValid': isValid,
      'data': normalizeToolValue(data),
      'errorCount': errors.length,
      'errors': errors
          .map((error) => error.toToolMap())
          .toList(growable: false),
    };
  }
}
