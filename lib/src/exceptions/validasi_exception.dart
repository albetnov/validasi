class ValidasiException extends Error {
  final String message;

  ValidasiException(this.message);

  @override
  String toString() => message;
}
