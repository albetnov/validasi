import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/validators/validator.dart';

/// [FieldValidator] is a inline wrapper for single validator.
///
/// The wrapper expose [validate] and [validateAsync] method both for returning
/// first error message on error, or return [null] if success.
class FieldValidator<T> {
  /// The [Validator] to be wrapped
  final Validator validator;

  const FieldValidator(this.validator);

  /// Perform the validation and catch the [message]. Return [null] if success
  /// instead.
  String? validate(T? value, {String path = 'field'}) {
    try {
      validator.parse(value, path: path);
      return null;
    } on FieldError catch (e) {
      return e.message;
    }
  }

  /// Similar to [validate] but running on Asyncronous Context.
  Future<String?> validateAsync(T? value, {String path = 'field'}) async {
    try {
      await validator.parseAsync(value, path: path);
      return null;
    } on FieldError catch (e) {
      return e.message;
    }
  }
}
