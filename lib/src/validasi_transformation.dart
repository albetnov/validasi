class ValidasiTransformation<I, O> {
  const ValidasiTransformation(this.transform, {this.message});

  final String? message;
  final O Function(I) transform;

  ValidasiTransformationResult<I, O> tryTransform(I input) {
    try {
      final output = transform(input);
      return ValidasiTransformationResult<I, O>.success(
        output,
        message: message,
      );
    } catch (e) {
      return ValidasiTransformationResult<I, O>.error(
        e,
        message: message ?? 'Failed to transform value',
      );
    }
  }
}

class ValidasiTransformationResult<I, O> {
  const ValidasiTransformationResult({
    required this.isValid,
    this.data,
    this.error,
    this.message,
  });

  final bool isValid;
  final O? data;
  final Object? error;
  final String? message;

  factory ValidasiTransformationResult.success(O data, {String? message}) {
    return ValidasiTransformationResult<I, O>(
      isValid: true,
      data: data,
      message: message,
    );
  }

  factory ValidasiTransformationResult.error(Object error, {String? message}) {
    return ValidasiTransformationResult<I, O>(
      isValid: false,
      error: error,
      message: message,
    );
  }
}
