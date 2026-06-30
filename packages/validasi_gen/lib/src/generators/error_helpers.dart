String generateResultHelper() {
  return r'''
abstract final class _Result {
  static ValidasiResult<T> from<T>(List<ValidationError> errors, T? value) =>
      errors.isEmpty
          ? ValidasiResult(errors: const [], isValid: true, data: value)
          : ValidasiResult(errors: errors, isValid: false);

  static ValidasiResult<T> invalidSingle<T>(ValidationError error) =>
      ValidasiResult(errors: [error], isValid: false);
}
''';
}
