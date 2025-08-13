class ValidasiTransformation<I, O> {
  const ValidasiTransformation(this.transform);

  final O Function(I) transform;

  ValidasiTransformationResult<I, O> tryTransform(I input) {
    try {
      final output = transform(input);
      return ValidasiTransformationResult<I, O>(
        isValid: true,
        data: output,
      );
    } catch (e) {
      return ValidasiTransformationResult<I, O>(
        isValid: false,
        error: e,
      );
    }
  }
}

class ValidasiTransformationResult<I, O> {
  const ValidasiTransformationResult({
    required this.isValid,
    this.data,
    this.error,
  });

  final bool isValid;
  final O? data;
  final Object? error;
}
