import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/validators/array_validator.dart';
import 'package:validasi/src/validators/object_validator.dart';

/// The [Result] responsible for returning a value with errors
/// (under `try` method) and the converted [value] to target type
/// based on runned Validators.
class Result<T> {
  /// The [value] is generic and is nullable considering the behavior of Validasi
  /// to always handle nullable value.
  final T? value;

  /// The [errors] value contains all [FieldError].
  List<FieldError> errors = [];

  Result({this.value, List<FieldError>? errors}) : errors = errors ?? [];

  /// The checks for validity is as simple as ensuring that [errors] is empty.
  bool get isValid => errors.isEmpty;

  /// The [addError] allow public access to append an error to [errors].
  /// This is useful for create a custom Validation logic but still
  /// inherting the Validator behaviour.
  /// see [ArrayValidator] and [ObjectValidator] for example.
  void addError(FieldError error) => errors.add(error);
}
