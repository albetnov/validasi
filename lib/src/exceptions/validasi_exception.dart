/// The base exception used for stuff related to Validasi error.
class ValidasiException extends Error {
  final String message;

  ValidasiException(this.message);

  @override
  String toString() => message;
}
