import 'package:validasi/src/fields/validasi_field.dart';

/// Reads the current value of a [ValidasiField] from a typed model context.
///
/// This abstraction lets generated schemas live in `validasi` core without
/// depending on the Flutter-specific controller in `validasi_ui`.
abstract class ValidasiFieldReader<T> {
  V? getValue<V>(ValidasiField<T, V> field);
}
