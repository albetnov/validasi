typedef TransformFn<TInput, TOutput> = TOutput Function(TInput input);

class ValidasiTransformation<TInput, TOutput> {
  const ValidasiTransformation(this.transform, {this.message});

  final String? message;
  final TransformFn<TInput, TOutput> transform;

  ValidasiTransformationResult<TInput, TOutput> tryTransform(TInput input) {
    try {
      return ValidasiTransformationResult<TInput, TOutput>.success(
        transform(input),
        message: message,
      );
    } catch (e) {
      return ValidasiTransformationResult<TInput, TOutput>.error(
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
