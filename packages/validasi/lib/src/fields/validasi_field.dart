import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/result.dart';

/// A typed key identifying a cross-field validator on [T].
///
/// Generated classes extend this to produce typed constants
/// (e.g. `UserCrossFields.passwordMatch`), one per `@ValidateWith` annotation.
class CrossFieldKey<T> {
  final String name;
  const CrossFieldKey(this.name);
}

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

  /// If this field has a `@ValidateWith` cross-field validator,
  /// this returns the key used to identify it. Otherwise `null`.
  CrossFieldKey<T>? get crossFieldKey => null;

  /// If this field has a `@ValidateWith` cross-field validator,
  /// this returns the validator function. Otherwise `null`.
  ///
  /// The function receives a `getField` callback that reads field values
  /// from the controller, enabling cross-field logic without a `T` instance.
  List<ValidationError> Function(
    TValue? Function<TValue>(ValidasiField<T, TValue>) getField,
  )? get crossValidator => null;

  /// If this field is referenced by a `@ValidateWith(dependsOn:)` on
  /// another field, returns the fields whose cross-validators depend on
  /// this field's value. Otherwise an empty set.
  Set<ValidasiField<T, dynamic>> get crossDependsOn => const {};
}
