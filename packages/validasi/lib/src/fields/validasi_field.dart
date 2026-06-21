import 'package:validasi/src/engine/result.dart';

/// A descriptor for a single field on a typed model [T].
///
/// This interface carries no validation logic; it only describes
/// how to identify and extract a field value.
abstract class FieldDescriptor<T, V> {
  const FieldDescriptor();

  /// The field name as it appears in the model (e.g. `"email"`).
  String get name;

  /// Extract the field value from a concrete model instance.
  V? extract(T owner);
}

/// A [FieldDescriptor] that can validate its own values.
abstract class ValidasiField<T, V> extends FieldDescriptor<T, V> {
  const ValidasiField();

  /// Validate [value] using the rules defined for this field.
  ValidasiResult<V> validate(V? value);

  /// Async counterpart of [validate]. By default it delegates to [validate];
  /// generated classes override this to support async rules (e.g. `@AsyncInline`).
  Future<ValidasiResult<V>> validateAsync(V? value) async {
    return validate(value);
  }
}
