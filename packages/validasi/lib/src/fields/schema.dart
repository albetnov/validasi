import 'package:validasi/src/fields/field_reader.dart';

/// Allocates a typed model [T] from a [ValidasiFieldReader].
///
/// Generated schemas implement this class and expose it as a `schema` constant
/// on the generated field class, e.g. `UserFields.schema`.
abstract class ValidasiSchema<T> {
  const ValidasiSchema();

  /// Builds a [T] instance by reading field values from [reader].
  T allocate(ValidasiFieldReader<T> reader);
}
